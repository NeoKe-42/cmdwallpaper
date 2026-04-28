# cmdwallpaper

A Wallpaper Engine web wallpaper with terminal aesthetic — system info, media display, album art, and EQ audio visualizer.

## Quick Start

### Mode 1: Basic (no install required)

1. Open Wallpaper Engine
2. Open Wallpaper → Open from File → select `project.json`
3. Play some music

**Works immediately:**
- Music title, artist, album
- Album art (via Wallpaper Engine Media Integration)
- Playback progress with local interpolation
- EQ audio visualizer (BASS / MID / TREBLE)

### Mode 2: Full system (run install.ps1 once)

```powershell
cd F:\1123\cmdwallpaper
.\install.ps1
```

**Adds:**
- CPU, GPU, RAM, Disk usage with color-coded progress bars
- OS version, hostname, username, motherboard
- Custom prompt (`C:\Users\<name>>`)
- System helper auto-starts on Windows login

## File Structure

| File | Purpose |
|------|---------|
| `project.json` | Wallpaper Engine project config (web type + audio) |
| `wallpaper.html` | Wallpaper UI, EQ, media integration |
| `cmdwallpaper_agent.cs` | C# system info + SMTC fallback collector |
| `publish/` | Compiled agent (build with `dotnet publish`) |
| `start_service.vbs` | Hidden launcher for the agent |
| `install.ps1` | One-time install + auto-start setup |
| `run_agent.ps1` | Debug launcher (runs agent in foreground) |
| `assets/` | Static assets (placeholder SVG) |
| `data/` | Runtime data (auto-generated, gitignored) |

## Building the Agent

```powershell
dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 -o publish
```

## Troubleshooting

**EQ bars not moving**: make sure `project.json` has `"supportsaudioprocessing": true` and audio is playing.

**System info shows "System helper not installed"**: run `install.ps1` to enable the C# system info agent.

**Service not starting on boot**: check `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WallpaperSystemInfo.bat` exists.

**Chinese text garbled**: save files as UTF-8 with BOM.

**Permission denied**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
