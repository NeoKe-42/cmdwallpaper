# CMD Wallpaper

终端风格的 Wallpaper Engine 网页壁纸，支持系统信息、媒体显示、专辑封面、播放进度和音频可视化。

A terminal-style Wallpaper Engine web wallpaper with system info, media display, album art, playback progress, and audio visualizer.

---

## 功能 / Features

- 终端风格 UI / Terminal-style UI
- One Dark Pro 配色 / One Dark Pro color scheme
- 音乐标题 / 歌手 / 专辑 / Media title, artist, album
- 专辑封面 / Album art
- 播放进度 / Playback progress
- 音频响应 EQ / Audio-responsive EQ
- 可选系统信息 helper / Optional system info helper
- CPU / GPU / RAM / 磁盘 / 网络 / 操作系统 / CPU, GPU, RAM, disk, network, OS

---

## 使用方法 / Usage

订阅或导入壁纸后，基础媒体功能可直接使用。
如果只需要音乐信息、封面、进度和 EQ，不需要安装 helper。

After subscribing or importing the wallpaper, basic media features work out of the box.
If you only need music info, album art, playback progress and EQ, no helper is required.

---

## 启用完整系统信息 / Enable Full System Stats

Steam Workshop 可能会把 `.exe` 和 `.bat` 文件改成 `.txt` 后缀，需要手动改回来。

Steam Workshop may rename `.exe` and `.bat` files with a `.txt` suffix. You'll need to rename them back.

1. 在 Wallpaper Engine 中右键壁纸 / Right-click the wallpaper in Wallpaper Engine
2. 选择"在资源管理器中打开" / Select "Open in Explorer"
3. 打开 Windows 文件扩展名显示 / Enable file name extensions in Windows Explorer
4. 将 `START_HERE.bat.txt` 改为 `START_HERE.bat` / Rename `START_HERE.bat.txt` → `START_HERE.bat`
5. 将 `Install Helper.bat.txt` 改为 `Install Helper.bat` / Rename `Install Helper.bat.txt` → `Install Helper.bat`
6. 将 `Uninstall Helper.bat.txt` 改为 `Uninstall Helper.bat` / Rename `Uninstall Helper.bat.txt` → `Uninstall Helper.bat`
7. 进入 `publish` 文件夹 / Go into the `publish` folder
8. 将 `cmdwallpaper_agent.exe.txt` 改为 `cmdwallpaper_agent.exe` / Rename `cmdwallpaper_agent.exe.txt` → `cmdwallpaper_agent.exe`
9. 回到壁纸根目录，双击 `START_HERE.bat` / Go back to the wallpaper root, double-click `START_HERE.bat`
10. 选择 Install helper / Select Install helper
11. 重新加载壁纸 / Reload the wallpaper

---

## 卸载 helper / Uninstall Helper

双击 `Uninstall Helper.bat`。
卸载后基础媒体功能仍然可用，只是不再显示系统信息。

Double-click `Uninstall Helper.bat`.
After uninstalling, media features still work, but system stats will no longer be shown.

---

## 播放器兼容性 / Player Compatibility

支持大多数会向 Windows 暴露媒体信息的播放器。
Apple Music、B站网页、网易云网页版通常可以显示封面和进度。
网易云客户端可能只能触发 EQ，无法提供封面和进度。

Works best with players that expose media information to Windows.
Apple Music, Bilibili web player, and NetEase Cloud Music web player usually provide album art and playback progress.
The NetEase desktop client may only trigger EQ without album art or timeline.

---

## 隐私 / Privacy

helper 只在本地读取系统信息和媒体信息，数据写入壁纸目录下的 `data` 文件夹，不会上传任何数据。

The helper only reads system and media info locally. Data is written to the `data` folder inside the wallpaper directory. Nothing is uploaded.

可能生成的文件 / Files that may be created:

- `data/system_info.json` — 系统硬件信息 / system hardware info
- `data/smtc_data.json` — 当前媒体播放信息 / current media playback info
- `data/eq_data.json` — 音频频谱数据 / audio spectrum data
- `data/album_art.jpg` — 当前专辑封面 / current album art
- `data/cmdwallpaper_agent.log` — helper 日志 / helper log

---

## 开发者构建 / Build for Developers

构建 helper / Build the helper:

```powershell
.\scripts\build_agent.ps1
```

生成 Workshop 发布目录 / Generate Workshop package:

```powershell
.\scripts\package_workshop.ps1
```

---

## 项目结构 / Project Structure

| 文件 | 说明 |
|---|---|
| `wallpaper.html` | 壁纸主界面 / Main wallpaper UI |
| `project.json` | Wallpaper Engine 项目配置 / Wallpaper Engine project config |
| `cmdwallpaper_agent.cs` | 系统信息采集 (C#) / System info collector (C#) |
| `install.ps1` | 安装脚本 / Install script |
| `uninstall.ps1` | 卸载脚本 / Uninstall script |
| `run_agent.ps1` | 前台运行 helper / Run helper in foreground |
| `start_service.vbs` | 后台静默启动 / Silent background launcher |
| `scripts/build_agent.ps1` | 编译 helper / Build helper |
| `scripts/package_workshop.ps1` | 生成 Workshop 发布包 / Generate Workshop package |
| `assets/` | 静态资源 (默认封面等) / Static assets (default cover, etc.) |
| `data/.gitkeep` | 运行时数据目录占位 / Runtime data directory placeholder |

---

## 常见问题 / FAQ

**Q: 为什么看不到系统信息？ / Why can't I see system info?**

A: helper 没有启用。请按上面说明运行 `START_HERE.bat` 安装。 / The helper is not enabled. Run `START_HERE.bat` and install it.

**Q: 为什么 EQ 不动？ / Why is the EQ not moving?**

A: 检查 Wallpaper Engine 是否被系统静音了、播放器是否正在输出音频。 / Check if Wallpaper Engine is muted in Windows Volume Mixer and make sure audio is playing.

**Q: 为什么封面或进度不显示？ / Why don't I see album art or progress?**

A: 播放器可能没有向 Windows 暴露完整媒体信息。可以尝试用网页播放器（如网易云网页版、B站、Apple Music）。 / Your player may not expose full media info to Windows. Try a web player instead.

**Q: 重启后需要重新安装 helper 吗？ / Do I need to reinstall after reboot?**

A: 正常不需要，安装后会创建启动项。重新订阅壁纸、路径变化、或运行过卸载后需要重新安装。 / No. The helper auto-starts after install. Reinstall only if you re-subscribe to the wallpaper, the path changes, or you ran the uninstaller.

**Q: Windows 提示风险怎么办？ / Windows shows a security warning?**

A: helper 是本地程序，未签名时会触发 Windows 提示。信任项目的话点"更多信息"→"仍要运行"即可。 / The helper is an unsigned local program. Click "More info" → "Run anyway" if you trust the project.

---

## License

MIT

---

https://github.com/NeoKe-42/cmdwallpaper
