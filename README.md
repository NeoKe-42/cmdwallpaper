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
cd <ProjectRoot>
.\install.ps1
```

`install.ps1` is **only** for system info. Music, album art, and EQ do not depend on it.

**Adds:**
- CPU, GPU, RAM, Disk usage with color-coded progress bars
- OS version, hostname, username, motherboard
- Custom prompt (`C:\Users\<name>>`)
- System helper auto-starts on Windows login

## File Structure

| File | Purpose |
|------|---------|
| `project.json` | Wallpaper Engine project config (Web type + audio) |
| `wallpaper.html` | Wallpaper UI, EQ, media integration |
| `cmdwallpaper_agent.cs` | C# system info + SMTC fallback collector |
| `publish/` | Compiled agent (build with `dotnet publish`) |
| `start_service.vbs` | Hidden launcher for the agent |
| `install.ps1` | One-time install + auto-start setup |
| `run_agent.ps1` | Debug launcher (runs agent in foreground) |
| `tools/audio_probe/` | Minimal audio listener probe (debug tool) |
| `assets/` | Static assets |
| `data/` | Runtime data (auto-generated, **gitignored**) |

`data/` contains runtime files (`*.json`, `*.jpg`, `*.log`) and should not be committed to the repository.

## Building the Agent

```powershell
dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 -o publish
```

## Troubleshooting

**EQ shows REGISTERED-NO-FRAMES**:

Make sure `project.json` uses the tested Web audio structure:

```json
{
  "type": "Web",
  "supportsAudio": true,
  "general": {
    "properties": {},
    "supportsaudioprocessing": true
  }
}
```

- Do NOT use bare `general.supportsaudioprocessing` without `properties` — this can crash Wallpaper Engine.
- Do NOT rely on root-level `supportsaudioprocessing` alone.
- In Wallpaper Engine settings, check General → Media → Audio recording device.
- Make sure Wallpaper Engine is not muted in Windows Volume Mixer.
- If using a USB/Bluetooth headset, try 44100 Hz sample rate.
- Use `tools/audio_probe/` to isolate whether the issue is WE audio capture or the main wallpaper.

**Album art not showing**:

- Basic mode uses Wallpaper Engine native Media Integration — make sure your music app exposes Windows media session metadata (Spotify, Edge, Groove Music all support this).
- Full system mode adds `data/album_art.jpg` fallback — requires `install.ps1` and a running agent.
- If using fallback, switch songs to trigger art extraction.

**System info shows "System helper not installed"**:

- Run `install.ps1` once to enable the C# system info agent.
- The agent writes to `data/system_info.json` every 10 seconds.

**Changes not taking effect**:

- Wallpaper Engine works from its own `myprojects` folder, not the source directory.
- Open the wallpaper in WE Editor → click Edit → Open in Explorer to find where WE copied it.
- Re-import `project.json` from the source directory after making changes.
- Or: open WE Editor → Save after applying changes.

**Service not starting on boot**: check `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WallpaperSystemInfo.bat` exists.

**Chinese text garbled**: save files as UTF-8 with BOM.

**Permission denied**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
