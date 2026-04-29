# CMD Wallpaper

一个终端风格的 Wallpaper Engine 壁纸，配色参考 One Dark Pro，界面参考 neofetch / Windows Terminal。

订阅后直接应用即可，默认就能显示：

- 当前播放的音乐
- 歌手 / 专辑
- 专辑封面
- 播放进度
- 跟随音乐跳动的 EQ
- ```
  部分播放器可能不会向 Windows 暴露完整媒体信息。网易云音乐客户端通常可以触发 EQ，但可能无法提供专辑封面和播放进度。建议使用QQ音乐或网易云网页版。
  ```

  

---

## 显示电脑硬件信息

CPU、GPU、内存、磁盘、网络这些信息需要额外启用本地 helper。

原因很简单：Wallpaper Engine 的网页壁纸不能直接读取 Windows 系统信息，所以需要一个本地小程序把信息写到壁纸目录里的 `data` 文件夹。

---

## 安装 helper

1. 在 Wallpaper Engine 里右键这个壁纸。
2. 点“在资源管理器中打开”。
3. 先打开 Windows 的“文件扩展名”显示。

Windows 11：

查看 → 显示 → 文件扩展名

Windows 10：

查看 → 勾选“文件扩展名”

4. 把这些文件名改回来：

START_HERE.bat.txt → START_HERE.bat  
Install Helper.bat.txt → Install Helper.bat  
Uninstall Helper.bat.txt → Uninstall Helper.bat  

5. 进入 `publish` 文件夹，把：

cmdwallpaper_agent.exe.txt → cmdwallpaper_agent.exe

6. 回到壁纸根目录，双击：

START_HERE.bat

然后选择安装 helper。

也可以直接双击：

Install Helper.bat

装完后重新加载壁纸，就能看到 CPU / GPU / 内存 / 磁盘等信息。

---

## 重启后要重新安装吗？

一般不用。

安装成功后，helper 会自动加入开机启动。以后重启电脑，系统信息会自动更新。

只有这些情况需要重新安装：

- 重新订阅了壁纸
- Wallpaper Engine 的壁纸目录变了
- 运行过卸载
- 系统信息突然不显示了

---

## 卸载 helper

打开壁纸目录，双击：

Uninstall Helper.bat

卸载后音乐、封面、播放进度和 EQ 仍然能用，只是不再显示硬件信息。

---

## 常见问题

### 看不到 CPU / GPU / 内存？

说明 helper 没装，或者没有运行成功。按上面的步骤改名并运行 `START_HERE.bat`。

### 双击 bat 没反应？

大概率是文件名其实还是 `.bat.txt`。  
请先打开“文件扩展名”显示，再确认文件名。

### 提示找不到 agent？

检查：

publish\cmdwallpaper_agent.exe

如果它还是 `cmdwallpaper_agent.exe.txt`，把最后的 `.txt` 去掉。

### EQ 不动？

检查是否正在播放音乐。  
再确认 Wallpaper Engine 没被 Windows 音量混合器静音。  
正常情况下底部会显示 `EQ:WE-AUDIO`。

### 专辑封面不显示？

有些播放器或歌曲本身不提供封面。换一首歌或者重启 Wallpaper Engine 试试。

---

## 隐私

helper 只在本地工作，不会上传数据。

它可能会在壁纸目录下生成这些文件：

data/system_info.json  
data/smtc_data.json  
data/album_art.jpg  
data/cmdwallpaper_agent.log  

里面可能包含电脑名、用户名、局域网 IP、硬件信息和当前播放信息。

介意的话可以不装 helper。音乐、封面、播放进度和 EQ 仍然可用。

---

## 项目地址

https://github.com/NeoKe-42/cmdwallpaper
