# CMD Wallpaper

A terminal-style Wallpaper Engine web wallpaper with system info, media display, album art, playback progress, and audio visualizer.

## Features

- Terminal / One Dark Pro style
- Native media title / artist / album
- Album art
- Playback progress
- Audio responsive EQ
- Optional system info helper
- CPU / GPU / RAM / Disk / Network / OS info

## For Users

Subscribe or import the wallpaper to get started. Basic media features work out of the box.

### System info helper (optional)

To see CPU, GPU, RAM, and other system info:

1. Right-click the wallpaper in Wallpaper Engine
2. Open in Explorer
3. Enable file name extensions in Windows Explorer
4. Rename the `.bat.txt` files to `.bat`:
   - `START_HERE.bat.txt` → `START_HERE.bat`
   - `Install Helper.bat.txt` → `Install Helper.bat`
   - `Uninstall Helper.bat.txt` → `Uninstall Helper.bat`
5. In the `publish` folder, rename:
   - `cmdwallpaper_agent.exe.txt` → `cmdwallpaper_agent.exe`
6. Double-click `START_HERE.bat`
7. Select Install helper
8. Reload the wallpaper

### Media support

Some players may not expose full media information to Windows:

- NetEase Cloud Music desktop client may only trigger EQ (no cover art or progress)
- NetEase Cloud Music web, Bilibili web, and Apple Music work well for media info

## For Developers

### Build the agent

```powershell
.\scripts\build_agent.ps1
```

This compiles a self-contained `publish/cmdwallpaper_agent.exe`.

### Package for Workshop

```powershell
.\scripts\package_workshop.ps1
```

This creates a clean `../cmdwallpaper_workshop` directory ready for Wallpaper Engine import.

Requires `publish/cmdwallpaper_agent.exe` to exist. Run `build_agent.ps1` first if needed.

## Project Structure

| File | Purpose |
|---|---|
| `wallpaper.html` | Wallpaper Engine web wallpaper (main UI) |
| `project.json` | Wallpaper Engine project config |
| `cmdwallpaper_agent.cs` | Native system info collector (C#) |
| `cmdwallpaper_agent.csproj` | .NET project file for the agent |
| `install.ps1` | Helper install script |
| `uninstall.ps1` | Helper uninstall script |
| `run_agent.ps1` | Run helper once in foreground |
| `start_service.vbs` | Silent background launcher |
| `assets/` | Static assets (album art placeholder, etc.) |
| `data/.gitkeep` | Runtime data directory placeholder |
| `scripts/build_agent.ps1` | Compile the helper agent |
| `scripts/package_workshop.ps1` | Generate Workshop-ready package |
| `tools/audio_probe/` | Audio probe wallpaper for diagnostics |

## Privacy

The helper works entirely offline. It writes to the local `data/` folder only and does not upload any data.

It may create these files in `data/`:

- `system_info.json` — CPU, GPU, RAM, disk, network, OS info
- `smtc_data.json` — current media playback info
- `album_art.jpg` — current album art
- `cmdwallpaper_agent.log` — agent log

These may contain computer name, username, LAN IP, hardware info, and currently playing media. Media, cover art, progress, and EQ remain available without the helper.

## Troubleshooting

### EQ not moving

Check that audio is playing and Wallpaper Engine is not muted in Windows Volume Mixer. The footer should show `EQ:WE-AUDIO` when working.

### Album art not showing

Some players or songs do not provide cover art. Try a different song or restart Wallpaper Engine.

### System info not showing

The helper is not installed or not running. Follow the install steps and make sure file extensions are renamed correctly.

### PowerShell not in PATH

If you see "powershell is not recognized", add `C:\Windows\System32\WindowsPowerShell\v1.0` to your system PATH, or run the scripts from an elevated PowerShell prompt directly.

### Windows SmartScreen warning

Windows may show a warning when running the helper for the first time. Click "More info" then "Run anyway".

### Do I need to reinstall after reboot?

No. Once installed, the helper starts automatically on boot. You only need to reinstall if you re-subscribe to the wallpaper, move the wallpaper directory, or run the uninstaller.

## License

MIT
