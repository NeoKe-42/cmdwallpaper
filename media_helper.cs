using System;
using System.IO;
using System.Runtime.InteropServices;

// ============================================================
// CoreAudio COM interfaces
// ============================================================

[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
public class MMDeviceEnumerator { }

[ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IMMDeviceEnumerator {
    int GetDefaultAudioEndpoint(int dataFlow, int role, [Out] out IntPtr ppEndpoint);
}

[ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IMMDevice {
    int Activate([MarshalAs(UnmanagedType.LPStruct)] Guid iid, uint dwClsCtx,
                 IntPtr pActivationParams, [Out, MarshalAs(UnmanagedType.IUnknown)] out object ppInterface);
}

[ComImport, Guid("5CDF2C82-841E-4546-9722-0CF74078229A")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IAudioEndpointVolume {
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int GetMute(out int pbMute);
}

[ComImport, Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IAudioMeterInformation {
    int GetPeakValue(out float pfPeak);
    int GetMeteringChannelCount(out int pnChannelCount);
    int GetChannelsPeakValues(int u32ChannelCount, [Out] float[] afPeakValues);
    int QueryHardwareSupport(out int pdwHardwareSupportMask);
}

// ============================================================
// Static helpers
// ============================================================

public static class MediaHelper
{
    static readonly Guid IID_IAudioEndpointVolume  = new Guid("5CDF2C82-841E-4546-9722-0CF74078229A");
    static readonly Guid IID_IAudioMeterInformation = new Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064");

    private static bool TryGetDevice(out IMMDevice device)
    {
        device = null;
        try
        {
            var e = (IMMDeviceEnumerator)new MMDeviceEnumerator();
            IntPtr p;
            int hr = e.GetDefaultAudioEndpoint(0, 0, out p);
            if (hr != 0 || p == IntPtr.Zero) return false;
            device = (IMMDevice)Marshal.GetObjectForIUnknown(p);
            return device != null;
        }
        catch { return false; }
    }

    // ---------- Audio Volume ----------

    public static int GetMasterVolume(out bool muted)
    {
        muted = false;
        try
        {
            IMMDevice device;
            if (!TryGetDevice(out device)) return -1;

            object volObj;
            device.Activate(IID_IAudioEndpointVolume, 0, IntPtr.Zero, out volObj);
            var volume = (IAudioEndpointVolume)volObj;
            float level;
            volume.GetMasterVolumeLevelScalar(out level);
            int m;
            volume.GetMute(out m);
            muted = (m != 0);
            return (int)Math.Round(level * 100f);
        }
        catch { return -1; }
    }

    // ---------- Audio Peak Level ----------

    public static float GetAudioPeakLevel()
    {
        try
        {
            IMMDevice device;
            if (!TryGetDevice(out device)) return -1f;

            object meterObj;
            device.Activate(IID_IAudioMeterInformation, 0, IntPtr.Zero, out meterObj);
            var meter = (IAudioMeterInformation)meterObj;
            float peak;
            meter.GetPeakValue(out peak);
            return peak;
        }
        catch { return -1f; }
    }

    // ---------- Now Playing via window titles ----------

    public static string GetNowPlayingInfo(out string title, out string artist,
                                            out string album, out double pos, out double dur)
    {
        title = null; artist = null; album = null; pos = -1; dur = -1;

        // (processName, titleFirst)
        // titleFirst=true: window title is "Title - Artist" (Chinese apps)
        // titleFirst=false: window title is "Artist - Title" (Western apps)
        var procs = new Tuple<string, bool>[] {
            Tuple.Create("qqmusic",          true),
            Tuple.Create("qqmusicexternal",  true),
            Tuple.Create("qmbrowser",        true),
            Tuple.Create("cloudmusic",       true),
            Tuple.Create("kwmusic",          true),
            Tuple.Create("kugou",            true),
            Tuple.Create("kugoumusic",       true),
            Tuple.Create("baidumusic",       true),
            Tuple.Create("xiami",            true),
            Tuple.Create("netease",          true),
            Tuple.Create("spotify",          false),
            Tuple.Create("tidal",            false),
            Tuple.Create("deezer",           false),
            Tuple.Create("applemusic",       false),
            Tuple.Create("msedge",           false),
            Tuple.Create("chrome",           false),
            Tuple.Create("firefox",          false),
            Tuple.Create("opera",            false),
            Tuple.Create("wmplayer",         false),
            Tuple.Create("vlc",              false),
            Tuple.Create("foobar2000",       false),
            Tuple.Create("groove",           false),
            Tuple.Create("music.ui",         false),
            Tuple.Create("aimp",             false),
            Tuple.Create("winamp",           false),
            Tuple.Create("mediamonkey",      false),
            Tuple.Create("musicbee",         false),
            Tuple.Create("thunderbird",      false),
        };

        try
        {
            foreach (var entry in procs)
            {
                var name = entry.Item1;
                var titleFirst = entry.Item2;

                System.Diagnostics.Process[] plist;
                try { plist = System.Diagnostics.Process.GetProcessesByName(name); }
                catch { continue; }
                if (plist == null || plist.Length == 0) continue;

                foreach (var p in plist)
                {
                    string wt;
                    try { wt = p.MainWindowTitle; } catch { continue; }
                    if (string.IsNullOrEmpty(wt)) continue;

                    string tl = wt.ToLower().Trim();
                    if (tl == "program manager" || tl == "start" || tl == "search" ||
                        tl == "settings" || tl.StartsWith("microsoft")) continue;

                    int idx = wt.IndexOf(" - ");
                    if (idx > 0 && idx < wt.Length - 3)
                    {
                        string first = wt.Substring(0, idx).Trim();
                        string rest = wt.Substring(idx + 3).Trim();
                        int sep = rest.LastIndexOf(" - ");
                        string second, third = null;
                        if (sep > 0) {
                            second = rest.Substring(0, sep).Trim();
                            third = rest.Substring(sep + 3).Trim();
                        } else {
                            second = rest;
                        }

                        if (titleFirst) { title = first; artist = second; album = third; }
                        else             { artist = first; title = second; album = third; }
                        return name;
                    }

                    if (wt.Length >= 2 && wt.IndexOfAny(new char[]{'/', '\\', ':'}) < 0)
                    {
                        title = wt.Trim();
                        return name;
                    }
                }
            }
        }
        catch { }
        return null;
    }
}
