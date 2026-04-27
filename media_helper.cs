using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

// CoreAudio COM - minimal correct definitions
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
internal class _MMDeviceEnumerator { }

[ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface _IMMDeviceEnumerator {
    int f0(); // EnumAudioEndpoints stub
    int GetDefaultAudioEndpoint(int dataFlow, int role, [Out, MarshalAs(UnmanagedType.Interface)] out _IMMDevice endpoint);
}

[ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface _IMMDevice {
    int Activate([In] ref Guid iid, uint clsCtx, [In] IntPtr activationParams, [Out, MarshalAs(UnmanagedType.Interface)] out _IAudioMeterInformation meterInterface);
    int f1(); // OpenPropertyStore stub
    int f2(); // GetId stub
    int f3(); // GetState stub
}

[ComImport, Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface _IAudioMeterInformation {
    int GetPeakValue(out float pfPeak);
    int GetMeteringChannelCount(out int pnChannelCount);
    int GetChannelsPeakValues(int u32ChannelCount, [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex=0)] float[] afPeakValues);
    int QueryHardwareSupport(out int pdwHardwareSupportMask);
}

public static class MediaHelper
{
    static float _bass, _mid, _treble;
    static Thread _thread;
    static bool _running;
    static string _dir;
    static DateTime _lastWrite = DateTime.MinValue;

    public static void StartMeter(string dir) {
        _dir = dir;
        if (_running) return;
        _running = true;
        _thread = new Thread(MeterLoop) { IsBackground = true, Priority = ThreadPriority.BelowNormal };
        _thread.Start();
    }

    static _IAudioMeterInformation GetMeter() {
        try {
            var enumerator = (_IMMDeviceEnumerator)new _MMDeviceEnumerator();
            _IMMDevice device;
            enumerator.GetDefaultAudioEndpoint(0, 0, out device); // eRender, eConsole
            if (device == null) return null;
            Guid iid = new Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064");
            _IAudioMeterInformation meter;
            device.Activate(ref iid, 0, IntPtr.Zero, out meter);
            return meter;
        } catch { return null; }
    }

    static void MeterLoop() {
        var meter = GetMeter();
        if (meter == null) return;

        while (_running) {
            try {
                float peak = 0;
                int cc = 0;
                meter.GetPeakValue(out peak);
                meter.GetMeteringChannelCount(out cc);
                float[] chPeaks = new float[Math.Max(2, Math.Min(8, cc))];
                if (cc > 0) {
                    try { meter.GetChannelsPeakValues(cc, chPeaks); } catch { }
                }

                float b = cc >= 1 ? chPeaks[0] * 100 : peak * 100;
                float m = cc >= 2 ? chPeaks[1] * 100 : peak * 85;
                float t = cc >= 3 ? chPeaks[2] * 100 : peak * 70;
                b = Math.Min(100, b); m = Math.Min(100, m); t = Math.Min(100, t);
                lock (typeof(MediaHelper)) { _bass = b; _mid = m; _treble = t; }

                var now = DateTime.UtcNow;
                if (_dir != null && (now - _lastWrite).TotalMilliseconds > 80) {
                    _lastWrite = now;
                    try { File.WriteAllText(Path.Combine(_dir, "eq_data.json"),
                        "{\"b\":" + ((int)b) + ",\"m\":" + ((int)m) + ",\"t\":" + ((int)t) + "}"); } catch { }
                }
            } catch { }
            Thread.Sleep(80);
        }
    }

    public static float GetEQBass()   { lock (typeof(MediaHelper)) return _bass; }
    public static float GetEQMid()    { lock (typeof(MediaHelper)) return _mid; }
    public static float GetEQTreble() { lock (typeof(MediaHelper)) return _treble; }

    public static int GetMasterVolume(out bool muted) {
        muted = false;
        try { var m = GetMeter(); if (m == null) return -1; float p; m.GetPeakValue(out p); return (int)Math.Round(p * 100); } catch { return -1; }
    }

    // ----- Now Playing (window titles) -----
    public static string GetNowPlaying(out string title, out string artist, out string album) {
        title = null; artist = null; album = null;
        var procs = new Tuple<string, bool>[] { Tuple.Create("qqmusic",true),Tuple.Create("qqmusicexternal",true),Tuple.Create("qmbrowser",true),Tuple.Create("cloudmusic",true),Tuple.Create("kwmusic",true),Tuple.Create("kugou",true),Tuple.Create("kugoumusic",true),Tuple.Create("netease",true),Tuple.Create("spotify",false),Tuple.Create("tidal",false),Tuple.Create("deezer",false),Tuple.Create("msedge",false),Tuple.Create("chrome",false),Tuple.Create("firefox",false),Tuple.Create("opera",false),Tuple.Create("wmplayer",false),Tuple.Create("vlc",false),Tuple.Create("foobar2000",false),Tuple.Create("groove",false),Tuple.Create("music.ui",false) };
        try { foreach (var en in procs) { var name = en.Item1; var tf = en.Item2; Process[] pl; try { pl = Process.GetProcessesByName(name); } catch { continue; } if (pl == null || pl.Length == 0) continue; foreach (var p in pl) { string wt; try { wt = p.MainWindowTitle; } catch { continue; } if (string.IsNullOrEmpty(wt)) continue; string tl = wt.ToLower().Trim(); if (tl == "program manager" || tl == "start" || tl == "search" || tl == "settings" || tl.StartsWith("microsoft")) continue; int idx = wt.IndexOf(" - "); if (idx <= 0 || idx >= wt.Length - 3) continue; string first = wt.Substring(0, idx).Trim(), rest = wt.Substring(idx + 3).Trim(); if (first.Contains("://") || rest.Contains("://") || first.Length > 120 || rest.Length > 120) continue; if (first.Contains(" - ") || first.StartsWith("http")) continue; int sep = rest.LastIndexOf(" - "); string second, third = null; if (sep > 0) { second = rest.Substring(0, sep).Trim(); third = rest.Substring(sep + 3).Trim(); } else { second = rest; } if (tf) { title = first; artist = second; album = third; } else { artist = first; title = second; album = third; } return name; } } } catch { }
        return null;
    }
}
