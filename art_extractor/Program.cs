using System;
using System.IO;
using System.Threading;
using Windows.Media.Control;

class Program
{
    static string _lastTitle = "";

    static void Main(string[] args)
    {
        string dir = args.Length > 0 ? args[0] : ".";

        while (true)
        {
            try
            {
                var op = GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
                while (op.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(50);
                if (op.Status != Windows.Foundation.AsyncStatus.Completed) { Thread.Sleep(3000); continue; }
                var mgr = op.GetResults();
                var session = mgr.GetCurrentSession();
                if (session == null) { Thread.Sleep(3000); continue; }

                var mpOp = session.TryGetMediaPropertiesAsync();
                while (mpOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(50);
                var props = mpOp.Status == Windows.Foundation.AsyncStatus.Completed ? mpOp.GetResults() : null;

                if (props?.Thumbnail != null && !string.IsNullOrEmpty(props.Title))
                {
                    if (props.Title == _lastTitle) { Thread.Sleep(3000); continue; }
                    _lastTitle = props.Title;

                    var artOp = props.Thumbnail.OpenReadAsync();
                    while (artOp.Status == Windows.Foundation.AsyncStatus.Started) Thread.Sleep(30);
                    if (artOp.Status != Windows.Foundation.AsyncStatus.Completed) { Thread.Sleep(3000); continue; }

                    var stream = artOp.GetResults();
                    using (var ms = new MemoryStream())
                    {
                        stream.AsStreamForRead().CopyTo(ms);
                        var bytes = ms.ToArray();
                        if (bytes.Length > 128)
                        {
                            string ext = "png";
                            if (bytes.Length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) ext = "jpg";
                            string artFile = Path.Combine(dir, "album_art." + ext);
                            string tmp = artFile + ".tmp";
                            File.WriteAllBytes(tmp, bytes);
                            if (File.Exists(artFile)) File.Delete(artFile);
                            File.Move(tmp, artFile);
                        }
                    }
                }
            }
            catch { _lastTitle = ""; }
            Thread.Sleep(3000);
        }
    }
}
