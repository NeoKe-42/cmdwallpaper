using System;
using System.IO;
using System.Threading;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Media.Control;

class Program
{
    static void Main(string[] args)
    {
        string dir = args.Length > 0 ? args[0] : ".";
        try
        {
            GlobalSystemMediaTransportControlsSessionManager mgr = null;

            // Use STA thread + polling for WinRT async
            var ready = new ManualResetEvent(false);
            Exception err = null;
            var t = new Thread(() =>
            {
                try
                {
                    var op = GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
                    while (op.Status == Windows.Foundation.AsyncStatus.Started)
                        Thread.Sleep(50);
                    if (op.Status == Windows.Foundation.AsyncStatus.Completed)
                        mgr = op.GetResults();
                }
                catch (Exception ex) { err = ex; }
                ready.Set();
            });
            t.SetApartmentState(ApartmentState.STA);
            t.Start();
            if (!ready.WaitOne(4000) || err != null || mgr == null)
            {
                Console.WriteLine("{\"status\":\"no_media\"}");
                return;
            }

            var session = mgr.GetCurrentSession();
            if (session == null) { Console.WriteLine("{\"status\":\"no_media\"}"); return; }

            // Get media properties
            var mpOp = session.TryGetMediaPropertiesAsync();
            while (mpOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(50);
            var props = mpOp.Status == Windows.Foundation.AsyncStatus.Completed ? mpOp.GetResults() : null;

            // Timeline
            var tl = session.GetTimelineProperties();
            double pos = -1, dur = -1;
            if (tl != null) { pos = tl.Position.TotalSeconds; dur = tl.EndTime.TotalSeconds; }

            // Album art
            string artFile = null;
            if (props != null && props.Thumbnail != null)
            {
                try
                {
                    var streamOp = props.Thumbnail.OpenReadAsync();
                    while (streamOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(30);
                    if (streamOp.Status == Windows.Foundation.AsyncStatus.Completed)
                    {
                        var stream = streamOp.GetResults();
                        var size = (ulong)stream.GetType().GetProperty("Size").GetValue(stream);
                        // Read bytes via Buffer
                        var buf = new Windows.Storage.Streams.Buffer((uint)size);
                        var readOp = stream.GetType().GetMethod("ReadAsync").Invoke(stream, new object[] { buf, (uint)size, 0 });
                        while ((int)readOp.GetType().GetProperty("Status").GetValue(readOp) == 0) Thread.Sleep(30);
                        var reader = Windows.Storage.Streams.DataReader.FromBuffer(buf);
                        var bytes = new byte[size];
                        reader.ReadBytes(bytes);

                        string ext = "png";
                        if (bytes.Length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) ext = "jpg";
                        else if (bytes.Length >= 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) ext = "gif";

                        artFile = "album_art." + ext;
                        File.WriteAllBytes(Path.Combine(dir, artFile), bytes);
                    }
                }
                catch { }
            }

            string json = "{\"status\":\"playing\"";
            if (props != null)
            {
                if (!string.IsNullOrEmpty(props.Title)) json += ",\"title\":\"" + Esc(props.Title) + "\"";
                if (!string.IsNullOrEmpty(props.Artist)) json += ",\"artist\":\"" + Esc(props.Artist) + "\"";
                if (!string.IsNullOrEmpty(props.AlbumTitle)) json += ",\"album\":\"" + Esc(props.AlbumTitle) + "\"";
            }
            if (pos >= 0) json += ",\"position_sec\":" + pos.ToString("F1");
            if (dur > 0) json += ",\"duration_sec\":" + dur.ToString("F1");
            if (artFile != null) json += ",\"art_file\":\"" + Esc(artFile) + "\"";
            json += "}";
            Console.WriteLine(json);
        }
        catch (Exception ex)
        {
            Console.WriteLine("{\"status\":\"error\",\"msg\":\"" + Esc(ex.Message) + "\"}");
        }
    }

    static string Esc(string s) { return s.Replace("\\","\\\\").Replace("\"","\\\""); }
}
