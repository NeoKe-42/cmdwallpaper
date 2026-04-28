# CMD Wallpaper

一个基于 Wallpaper Engine 的终端风格动态壁纸，灵感来自 neofetch / Windows Terminal / One Dark Pro。

可以显示：
- 当前播放的音乐标题、歌手、专辑
- 专辑封面
- 播放进度
- 随音乐响应的 EQ 动态条
- 可选的系统信息：CPU、GPU、内存、磁盘、网络、系统版本等

---

## 功能模式

### 1. 基础模式：无需安装

订阅或导入壁纸后，基础功能直接工作：

- 音乐标题
- 歌手
- 专辑名
- 专辑封面
- 播放进度
- 音频响应 EQ

这些功能由 Wallpaper Engine 原生媒体接口提供，不需要额外安装任何程序。

### 2. 完整模式：显示系统信息

如果你想显示 CPU、GPU、内存、磁盘、IP、主板、系统版本等信息，需要启用本地 helper。

原因是 Wallpaper Engine 的 Web 壁纸不能直接读取完整 Windows 系统信息，所以需要一个本地 helper 将系统信息写入 data 文件夹。

---

## 如何使用

### 第一步：应用壁纸

在 Wallpaper Engine 中订阅或导入本壁纸后，直接应用即可。

此时你应该能看到：
- 当前播放的音乐信息
- 专辑封面
- 播放进度
- EQ 动态条

如果只需要这些功能，不需要做其他操作。

### 第二步（可选）：开启系统信息

1. 在 Wallpaper Engine 中右键该壁纸
2. 选择「在资源管理器中打开」
3. 双击 `START_HERE.bat`
4. 选择 [1] Install helper
5. 重新加载壁纸或重启 Wallpaper Engine

也可以直接双击 `Install Helper.bat`。

成功后，壁纸会显示完整系统信息。

---

## 卸载 helper

1. 打开壁纸所在文件夹
2. 双击 `Uninstall Helper.bat`

如果想同时清理本地运行时数据（JSON、封面图等），可以打开 `START_HERE.bat` 选择 [3] Clean runtime data。

卸载后音乐信息、封面、EQ 不受影响。

---

## 常见问题

### 为什么只能看到音乐信息，看不到 CPU / GPU / 内存？

正常。音乐信息和 EQ 属于基础模式，不需要安装。CPU / GPU / 内存需要运行 `Install Helper.bat`。

### 为什么 EQ 不动？

1. 检查当前是否正在播放音乐
2. 检查 Wallpaper Engine 是否被 Windows 音量混音器静音
3. 检查 Wallpaper Engine 设置中的音频录制设备
4. 重新加载壁纸或重启 Wallpaper Engine

正常情况下，壁纸底部状态会显示 `EQ:WE-AUDIO`。

### 为什么专辑封面不显示？

可能原因：
- 当前播放器没有提供封面
- 刚切歌需要等待 1-2 秒
- 播放器不支持系统媒体信息

可以尝试换一首歌，或使用 Spotify / 网易云 / QQ 音乐 / Edge 网页播放器等支持系统媒体信息的播放器。

### 为什么系统信息没有刷新？

1. 确认运行过 `Install Helper.bat`
2. 右键壁纸 → 在资源管理器中打开 → 确认是从正确文件夹运行的安装程序
3. 检查 helper 是否被杀毒软件拦截

---

## 隐私说明

本壁纸不会上传你的数据。

系统信息 helper 只会在本地生成运行时文件：

- `data/system_info.json`（系统信息）
- `data/smtc_data.json`（音乐信息）
- `data/album_art.jpg`（专辑封面）
- `data/cmdwallpaper_agent.log`（运行日志）

这些文件只保存在你的电脑本地。

其中可能包含：用户名、电脑名、局域网 IP、CPU / GPU / 内存 / 磁盘信息、当前播放音乐信息、当前专辑封面。

如果你介意，可以不安装 helper。基础音乐显示和 EQ 功能仍然可用。

---

## 给朋友的最简说明

1. 订阅壁纸，应用即可
2. 音乐和 EQ 自动工作
3. 如果还想显示硬件信息：右键壁纸 → 打开文件夹 → 双击 `START_HERE.bat` → 选安装

---

## 已知限制

- Web 壁纸本身不能直接读取完整 Windows 系统信息，系统信息需要 helper
- 部分播放器可能不提供专辑封面
- 部分音频设备可能需要在 Wallpaper Engine 设置中切换录制设备
- 仅支持 Windows + Wallpaper Engine

---

## 推荐环境

- Windows 10 / Windows 11
- Wallpaper Engine
- 支持系统媒体信息的播放器（Spotify、网易云、QQ 音乐、Edge/Chrome 网页播放器等）

---

如果你只想要好看的音乐终端壁纸，直接应用即可。  
如果你想让它像 neofetch 一样显示电脑硬件信息，再安装 helper。
