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
    static int _lastB = -1, _lastM = -1, _lastT = -1;
    static Thread _thread;
    static bool _running;
    static string _dir;
    static readonly object _lock = new object();

    public static void StartMeter(string dir) {
        _dir = dir;
        if (_running) return;
        _running = true;
        _thread = new Thread(Loop) { IsBackground = true, Priority = ThreadPriority.BelowNormal };
        _thread.Start();
    }

    static _IAudioMeterInformation GetMeter() {
        _IMMDeviceEnumerator e = null; _IMMDevice d = null;
        try {
            e = (_IMMDeviceEnumerator)new _MMDeviceEnumerator();
            e.GetDefaultAudioEndpoint(0, 0, out d);
            if (d == null) return null;
            Guid iid = new Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064");
            _IAudioMeterInformation m;
            d.Activate(ref iid, 0, IntPtr.Zero, out m);
            return m;
        } catch { return null; }
        finally {
            if (d != null) Marshal.ReleaseComObject(d);
            if (e != null) Marshal.ReleaseComObject(e);
        }
    }

    static void Loop() {
        while (_running) {
            var meter = GetMeter();
            if (meter == null) { Thread.Sleep(2000); continue; }
            while (_running) {
                try {
                    float peak = 0;
                    meter.GetPeakValue(out peak);
                    float ps = (float)Math.Sqrt(peak);
                    float b = Math.Min(100, peak * 130f), m = Math.Min(100, ps * 120f), t = Math.Min(100, peak * 110f);
                    int ib = (int)b, im = (int)m, it = (int)t;
                    lock (_lock) { _b = b; _m = m; _t = t; }

                    // Only write if values changed meaningfully
                    if (Math.Abs(ib - _lastB) > 0 || Math.Abs(im - _lastM) > 0 || Math.Abs(it - _lastT) > 0)
                    {
                        _lastB = ib; _lastM = im; _lastT = it;
                        if (_dir != null)
                            try { File.WriteAllText(Path.Combine(_dir, "eq_data.json"), "{\"b\":" + ib + ",\"m\":" + im + ",\"t\":" + it + "}"); } catch { }
                    }
                } catch {
                    Thread.Sleep(1000);
                    break;
                }
                Thread.Sleep(100);
            }
            if (meter != null) { try { Marshal.ReleaseComObject(meter); } catch { } }
        }
    }

    public static float GetEQBass() { lock (_lock) { return _b; } }
    public static float GetEQMid() { lock (_lock) { return _m; } }
    public static float GetEQTreble() { lock (_lock) { return _t; } }
    public static int GetMasterVolume(out bool muted) { muted = false; try { var m = GetMeter(); if (m == null) return -1; float p; m.GetPeakValue(out p); Marshal.ReleaseComObject(m); return (int)Math.Round(p * 100); } catch { return -1; } }

    // Window title fallback
    public static string GetNowPlaying(out string title, out string artist, out string album) {
        title = null; artist = null; album = null;
        var procs = new Tuple<string, bool>[] { Tuple.Create("qqmusic",true),Tuple.Create("qqmusicexternal",true),Tuple.Create("qmbrowser",true),Tuple.Create("cloudmusic",true),Tuple.Create("kwmusic",true),Tuple.Create("kugou",true),Tuple.Create("kugoumusic",true),Tuple.Create("netease",true),Tuple.Create("spotify",false),Tuple.Create("tidal",false),Tuple.Create("deezer",false),Tuple.Create("msedge",false),Tuple.Create("chrome",false),Tuple.Create("firefox",false),Tuple.Create("opera",false),Tuple.Create("wmplayer",false),Tuple.Create("vlc",false),Tuple.Create("foobar2000",false),Tuple.Create("groove",false),Tuple.Create("music.ui",false) };
        try { foreach (var en in procs) { var name = en.Item1; var tf = en.Item2; Process[] pl; try { pl = Process.GetProcessesByName(name); } catch { continue; } if (pl == null || pl.Length == 0) continue; foreach (var p in pl) { string wt; try { wt = p.MainWindowTitle; } catch { continue; } if (string.IsNullOrEmpty(wt)) continue; string tl = wt.ToLower().Trim(); if (tl == "program manager" || tl == "start" || tl == "search" || tl == "settings" || tl.StartsWith("microsoft")) continue; int idx = wt.IndexOf(" - "); if (idx <= 0 || idx >= wt.Length - 3) continue; string first = wt.Substring(0, idx).Trim(), rest = wt.Substring(idx + 3).Trim(); if (first.Contains("://") || rest.Contains("://") || first.Length > 120 || rest.Length > 120) continue; if (first.Contains(" - ") || first.StartsWith("http")) continue; int sep = rest.LastIndexOf(" - "); string second, third = null; if (sep > 0) { second = rest.Substring(0, sep).Trim(); third = rest.Substring(sep + 3).Trim(); } else { second = rest; } if (tf) { title = first; artist = second; album = third; } else { artist = first; title = second; album = third; } return name; } } } catch { }
        return null;
    }
}
