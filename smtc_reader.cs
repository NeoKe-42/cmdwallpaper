using System;
using System.IO;
using System.Threading;
using Windows.Media.Control;

class Program
{
    static string Esc(string s) { return s.Replace("\\","\\\\").Replace("\"","\\\""); }

    static void Main(string[] args)
    {
        string dir = args.Length > 0 ? args[0] : ".";
        string file = Path.Combine(dir, "smtc_data.json");

        while (true)
        {
            string json = "{\"status\":\"no_media\"}";
            try
            {
                // Init SMTC on STA thread
                GlobalSystemMediaTransportControlsSessionManager mgr = null;
                var ready = new ManualResetEvent(false);
                var t = new Thread(() => {
                    try {
                        var op = GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
                        while (op.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(50);
                        if (op.Status == Windows.Foundation.AsyncStatus.Completed) mgr = op.GetResults();
                    } catch { }
                    ready.Set();
                });
                t.SetApartmentState(ApartmentState.STA); t.Start();
                if (!ready.WaitOne(5000) || mgr == null) { json = "{\"status\":\"no_media\"}"; continue; }
                while (true)
                {
                    try
                    {
                        var session = mgr.GetCurrentSession();
                        if (session == null) { json = "{\"status\":\"no_media\"}"; }

                        var mpOp = session.TryGetMediaPropertiesAsync();
                        while (mpOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(50);
                        var props = mpOp.Status == Windows.Foundation.AsyncStatus.Completed ? mpOp.GetResults() : null;

                        var tl = session.GetTimelineProperties();
                        double pos = -1, dur = -1;
                        if (tl != null) { pos = tl.Position.TotalSeconds; dur = tl.EndTime.TotalSeconds; }

                        if (props != null && !string.IsNullOrEmpty(props.Title))
                        {
                            json = "{\"status\":\"playing\"";
                            json += ",\"title\":\"" + Esc(props.Title) + "\"";
                            if (!string.IsNullOrEmpty(props.Artist)) json += ",\"artist\":\"" + Esc(props.Artist) + "\"";
                            if (!string.IsNullOrEmpty(props.AlbumTitle)) json += ",\"album\":\"" + Esc(props.AlbumTitle) + "\"";
                            if (pos >= 0) json += ",\"pos\":" + pos.ToString("F1");
                            if (dur > 0) json += ",\"dur\":" + dur.ToString("F1");
                            json += "}";

                            // Album art
                            if (props.Thumbnail != null)
                            {
                                try
                                {
                                    var artOp = props.Thumbnail.OpenReadAsync();
                                    while (artOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(30);
                                    if (artOp.Status == Windows.Foundation.AsyncStatus.Completed)
                                    {
                                        var stream = artOp.GetResults();
                                        var buf = new Windows.Storage.Streams.Buffer((uint)stream.Size);
                                        var rOp = stream.GetType().GetMethod("ReadAsync").Invoke(stream, new object[] { buf, (uint)stream.Size, 0 });
                                        while ((int)rOp.GetType().GetProperty("Status").GetValue(rOp) == 0) Thread.Sleep(30);
                                        var reader = Windows.Storage.Streams.DataReader.FromBuffer(buf);
                                        var bytes = new byte[stream.Size]; reader.ReadBytes(bytes);
                                        string ext = "png";
                                        if (bytes.Length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) ext = "jpg";
                                        string artFile = "album_art." + ext;
                                        File.WriteAllBytes(Path.Combine(dir, artFile), bytes);
                                    }
                                } catch { }
                            }
                        }
                    }
                    catch { json = "{\"status\":\"error\"}"; }

                    try { File.WriteAllText(file, json); } catch { }
                    Thread.Sleep(1000);
                }
            }
            catch
            {
                // If anything fails, wait and re-init
                try { File.WriteAllText(file, "{\"status\":\"error\"}"); } catch { }
                Thread.Sleep(5000);
            }
        }
    }
}
