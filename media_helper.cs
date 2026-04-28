using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] internal class _MMDeviceEnumerator { }
[ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")][InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface _IMMDeviceEnumerator { int f0(); int GetDefaultAudioEndpoint(int dataFlow, int role, [Out, MarshalAs(UnmanagedType.Interface)] out _IMMDevice endpoint); }
[ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F")][InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface _IMMDevice { int Activate([In] ref Guid iid, uint clsCtx, [In] IntPtr activationParams, [Out, MarshalAs(UnmanagedType.Interface)] out _IAudioMeterInformation meterInterface); int f1(); int f2(); int f3(); }
[ComImport, Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064")][InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface _IAudioMeterInformation { int GetPeakValue(out float pfPeak); int GetMeteringChannelCount(out int pnChannelCount); int GetChannelsPeakValues(int u32ChannelCount, [Out, MarshalAs(UnmanagedType.LPArray, SizeParamIndex=0)] float[] afPeakValues); int QueryHardwareSupport(out int pdwHardwareSupportMask); }

public static class MediaHelper
{
    static float _b, _m, _t;
    static Thread _thread;
    static bool _running;
    static string _dir;
    static DateTime _lastWrite = DateTime.MinValue;

    public static void StartMeter(string dir) {
        _dir = dir;
        if (_running) return;
        _running = true;
        _thread = new Thread(Loop) { IsBackground = true, Priority = ThreadPriority.BelowNormal };
        _thread.Start();
    }

    static _IAudioMeterInformation GetMeter() {
        try { var e = (_IMMDeviceEnumerator)new _MMDeviceEnumerator(); _IMMDevice d; e.GetDefaultAudioEndpoint(0, 0, out d); if (d == null) return null; Guid iid = new Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064"); _IAudioMeterInformation m; d.Activate(ref iid, 0, IntPtr.Zero, out m); return m; } catch { return null; }
    }

    static void Loop() {
        while (_running) {
            var meter = GetMeter();
            if (meter == null) { Thread.Sleep(2000); continue; }
            while (_running) {
                try {
                    float peak = 0; int cc = 0;
                    meter.GetPeakValue(out peak); meter.GetMeteringChannelCount(out cc);
                    float[] ch = new float[Math.Max(2, Math.Min(8, cc))];
                    if (cc > 0) try { meter.GetChannelsPeakValues(cc, ch); } catch { }
                    float ps = (float)Math.Sqrt(peak);
                    float b = Math.Min(100, peak * 130f), m = Math.Min(100, ps * 120f), t = Math.Min(100, peak * 110f);
                    lock (typeof(MediaHelper)) { _b = b; _m = m; _t = t; }
                    var now = DateTime.UtcNow;
                    if (_dir != null && (now - _lastWrite).TotalMilliseconds > 80) {
                        _lastWrite = now;
                        try { File.WriteAllText(Path.Combine(_dir, "eq_data.json"), "{\"b\":" + ((int)b) + ",\"m\":" + ((int)m) + ",\"t\":" + ((int)t) + "}"); } catch { }
                    }
                } catch {
                    // COM error, device may have changed — re-acquire
                    Thread.Sleep(1000);
                    break;
                }
                Thread.Sleep(80);
            }
        }
    }

    public static float GetEQBass() { return _b; }
    public static float GetEQMid() { return _m; }
    public static float GetEQTreble() { return _t; }
    public static int GetMasterVolume(out bool muted) { muted = false; try { var m = GetMeter(); if (m == null) return -1; float p; m.GetPeakValue(out p); return (int)Math.Round(p * 100); } catch { return -1; } }

    // Window title fallback
    public static string GetNowPlaying(out string title, out string artist, out string album) {
        title = null; artist = null; album = null;
        var procs = new Tuple<string, bool>[] { Tuple.Create("qqmusic",true),Tuple.Create("qqmusicexternal",true),Tuple.Create("qmbrowser",true),Tuple.Create("cloudmusic",true),Tuple.Create("kwmusic",true),Tuple.Create("kugou",true),Tuple.Create("kugoumusic",true),Tuple.Create("netease",true),Tuple.Create("spotify",false),Tuple.Create("tidal",false),Tuple.Create("deezer",false),Tuple.Create("msedge",false),Tuple.Create("chrome",false),Tuple.Create("firefox",false),Tuple.Create("opera",false),Tuple.Create("wmplayer",false),Tuple.Create("vlc",false),Tuple.Create("foobar2000",false),Tuple.Create("groove",false),Tuple.Create("music.ui",false) };
        try { foreach (var en in procs) { var name = en.Item1; var tf = en.Item2; Process[] pl; try { pl = Process.GetProcessesByName(name); } catch { continue; } if (pl == null || pl.Length == 0) continue; foreach (var p in pl) { string wt; try { wt = p.MainWindowTitle; } catch { continue; } if (string.IsNullOrEmpty(wt)) continue; string tl = wt.ToLower().Trim(); if (tl == "program manager" || tl == "start" || tl == "search" || tl == "settings" || tl.StartsWith("microsoft")) continue; int idx = wt.IndexOf(" - "); if (idx <= 0 || idx >= wt.Length - 3) continue; string first = wt.Substring(0, idx).Trim(), rest = wt.Substring(idx + 3).Trim(); if (first.Contains("://") || rest.Contains("://") || first.Length > 120 || rest.Length > 120) continue; if (first.Contains(" - ") || first.StartsWith("http")) continue; int sep = rest.LastIndexOf(" - "); string second, third = null; if (sep > 0) { second = rest.Substring(0, sep).Trim(); third = rest.Substring(sep + 3).Trim(); } else { second = rest; } if (tf) { title = first; artist = second; album = third; } else { artist = first; title = second; album = third; } return name; } } } catch { }
        return null;
    }
}
