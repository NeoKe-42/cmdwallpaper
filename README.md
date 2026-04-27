# Terminal System Info Wallpaper

A Wallpaper Engine web wallpaper that displays real-time system information in a terminal/neofetch style.

![](preview.gif)

## Features

- Terminal aesthetic — dark background, monospace font, ASCII art logo
- Real-time CPU, GPU, memory, and disk usage with color-coded progress bars
- OS version, hostname, username, motherboard
- Auto-refreshes every 5 seconds
- Auto-starts on Windows login — install once, works forever
- Zero dependencies — pure PowerShell, runs on Windows 7+

## Quick Start

### 1. Install

Open PowerShell in this folder and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1
```

This generates initial system data, registers the background updater to auto-start on login, and launches it immediately.

### 2. Import into Wallpaper Engine

Wallpaper Engine → Open Wallpaper → Open from File → select `project.json`.

Done. The wallpaper updates every 5 seconds, and the background service starts automatically every time you log into Windows.

## File Structure

| File | Purpose |
|------|---------|
| `project.json` | Wallpaper Engine project config |
| `wallpaper.html` | Terminal-style wallpaper UI |
| `get_system_info.ps1` | System info collector (one-shot) |
| `system_info_updater.ps1` | Background update daemon |
| `start_service.vbs` | Hidden launcher for the daemon |
| `install.ps1` | One-time install + auto-start setup |
| `system_info.json` | Live data file (auto-generated) |
| `system_info_loader.lua` | Lua loader (legacy, for scene wallpapers) |

## Configuration

Change the update interval:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File system_info_updater.ps1 -UpdateInterval 10
```

## Troubleshooting

**Wallpaper shows no data**: run `powershell -NoProfile -ExecutionPolicy Bypass -File get_system_info.ps1` to make sure `system_info.json` is generated.

**Chinese text garbled**: make sure `get_system_info.ps1` is saved as UTF-8 with BOM. Re-run `install.ps1`.

**Service not starting on boot**: check `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\WallpaperSystemInfo.bat` exists.

**Permission denied**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
