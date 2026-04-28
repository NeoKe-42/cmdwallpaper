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
        string lastJson = "";
        string lastTitle = "";

        while (true)
        {
            string json = "{\"status\":\"no_media\"}";
            try
            {
                var op = GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
                while (op.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(50);
                if (op.Status != Windows.Foundation.AsyncStatus.Completed) { Thread.Sleep(5000); continue; }
                var mgr = op.GetResults();

                while (true)
                {
                    try
                    {
                        var session = mgr.GetCurrentSession();
                        if (session == null) { json = "{\"status\":\"no_media\"}"; goto write; }

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

                            // Only extract album art when title changes
                            if (props.Thumbnail != null && props.Title != lastTitle)
                            {
                                lastTitle = props.Title;
                                try
                                {
                                    var artOp = props.Thumbnail.OpenReadAsync();
                                    while (artOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(30);
                                    if (artOp.Status == Windows.Foundation.AsyncStatus.Completed)
                                    {
                                        var stream = artOp.GetResults();
                                        using (var ms = new MemoryStream())
                                        {
                                            stream.AsStreamForRead().CopyTo(ms);
                                            var bytes = ms.ToArray();
                                            if (bytes.Length > 128)
                                            {
                                                string ext = "png";
                                                if (bytes.Length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) ext = "jpg";
                                                File.WriteAllBytes(Path.Combine(dir, "album_art." + ext), bytes);
                                            }
                                        }
                                    }
                                } catch { }
                            }
                        }

                    write:
                        if (json != lastJson)
                        {
                            lastJson = json;
                            try { File.WriteAllText(file, json); } catch { }
                        }
                    }
                    catch { json = "{\"status\":\"error\"}"; if (json != lastJson) { lastJson = json; try { File.WriteAllText(file, json); } catch { } } }
                    Thread.Sleep(1000);
                }
            }
            catch
            {
                try { File.WriteAllText(file, "{\"status\":\"error\"}"); } catch { }
                Thread.Sleep(5000);
            }
        }
    }
}
