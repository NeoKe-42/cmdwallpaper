# CMD Wallpaper

CMD Wallpaper 是一个基于 Wallpaper Engine 的终端风格动态壁纸，灵感来自 neofetch / Windows Terminal / One Dark Pro。

它可以显示当前播放的音乐、专辑封面、播放进度、音频响应 EQ，并且可以通过可选的本地 helper 显示 CPU、GPU、内存、磁盘、网络、系统版本等完整系统信息。

---

## 功能预览

订阅并应用壁纸后，基础功能会直接工作：

- 当前播放音乐标题
- 歌手 / 专辑名
- 专辑封面
- 播放进度
- 音频响应 EQ 动态条
- One Dark Pro 终端风格界面

如果你只想把它当作一个好看的音乐终端壁纸，订阅后直接应用即可，不需要额外安装任何东西。

如果你希望显示完整系统信息，例如：

- CPU
- GPU
- 内存
- 磁盘
- 网络 IP
- Windows 系统版本
- 主板信息

则需要手动启用本地 helper。

---

# 一、基础模式：订阅后直接可用

订阅并应用壁纸后，以下功能无需安装即可使用：

- 音乐标题
- 歌手
- 专辑名
- 专辑封面
- 播放进度
- EQ 音频响应条

这些功能由 Wallpaper Engine 原生媒体接口提供，不需要额外运行程序。

如果你只需要这些功能，到这里就可以了。

---

# 二、完整系统信息模式：需要启用 helper

Wallpaper Engine 的 Web 壁纸本身不能直接读取完整 Windows 系统信息。

因此，如果你想显示 CPU、GPU、内存、磁盘、网络等信息，需要启用本地 helper。

helper 的作用是：

1. 在本地读取系统信息；
2. 将信息写入壁纸文件夹中的 data/system_info.json；
3. 壁纸前端读取该文件并显示系统信息。

helper 只在本地运行，不会上传你的数据。

---

# 三、找到壁纸原始目录

订阅并应用壁纸后，先打开 Wallpaper Engine。

在 Wallpaper Engine 中找到本壁纸，然后：

1. 右键点击该壁纸；
2. 选择“在资源管理器中打开”或“Open in Explorer”。

这时会打开一个类似下面的目录：

Steam\steamapps\workshop\content\431960\xxxxxxxxxx

这个目录就是当前壁纸的实际运行目录。

后续所有操作都在这个目录里完成。

---

# 四、先打开 Windows 文件扩展名显示

由于 Steam Workshop 可能不会直接保留 .exe、.bat 等可执行文件后缀，本壁纸中的 helper 文件可能会以 .txt 后缀保存。

在改名之前，请先确认 Windows 已经显示文件扩展名。

## Windows 11

打开文件资源管理器后：

查看 → 显示 → 文件扩展名

确保“文件扩展名”已勾选。

## Windows 10

打开文件资源管理器后：

查看 → 勾选“文件扩展名”

这一步非常重要。

如果没有打开文件扩展名显示，你可能以为自己改好了文件名，但实际文件仍然是：

START_HERE.bat.txt
cmdwallpaper_agent.exe.txt

而不是正确的：

START_HERE.bat
cmdwallpaper_agent.exe

---

# 五、修改 helper 文件后缀

打开壁纸目录后，检查以下文件。

## 1. 修改 bat 文件后缀

如果你看到这些文件：

START_HERE.bat.txt
Install Helper.bat.txt
Uninstall Helper.bat.txt

请分别改名为：

START_HERE.bat
Install Helper.bat
Uninstall Helper.bat

也就是删除最后的 .txt。

最终文件名必须是：

START_HERE.bat
Install Helper.bat
Uninstall Helper.bat

不要保留 .txt。

## 2. 修改 helper 程序后缀

进入壁纸目录中的 publish 文件夹。

如果你看到：

cmdwallpaper_agent.exe.txt

请改名为：

cmdwallpaper_agent.exe

最终路径应该类似：

当前壁纸目录\publish\cmdwallpaper_agent.exe

如果 publish 文件夹里还有：

cmdwallpaper_agent.pdb

不用管它。这个是调试文件，不影响正常使用。

---

# 六、运行安装程序

完成上面的改名后，回到壁纸根目录。

双击运行：

START_HERE.bat

然后根据菜单选择安装 helper。

如果你不想进入菜单，也可以直接双击：

Install Helper.bat

安装程序会自动完成以下操作：

- 检查 publish\cmdwallpaper_agent.exe
- 创建 data 文件夹
- 启动系统信息 helper
- 创建开机启动项
- 生成系统信息文件

安装完成后，重新加载壁纸或重启 Wallpaper Engine。

成功后，壁纸会显示完整系统信息，例如：

- CPU
- GPU
- 内存
- 磁盘
- 网络 IP
- Windows 系统版本
- 主板信息

---

# 七、重启电脑后还需要重新运行 bat 吗？

正常情况下，不需要。

只要你成功运行过一次：

Install Helper.bat

它会创建开机启动项。

之后每次重启 Windows 时，helper 会自动启动。

你只需要打开 Wallpaper Engine 或重新应用壁纸即可。

只有以下情况才需要重新运行安装：

- 你重新订阅或重新下载了壁纸；
- Wallpaper Engine 的 Workshop 文件夹路径发生变化；
- 你运行过 Uninstall Helper.bat；
- 系统信息不再显示；
- data/system_info.json 不再更新；
- 你手动删除过 publish 或 data 文件夹。

---

# 八、卸载 helper

如果你不想继续显示系统信息，或者想移除后台 helper，请打开壁纸目录，双击运行：

Uninstall Helper.bat

卸载后：

- 音乐标题仍然可用；
- 歌手 / 专辑仍然可用；
- 专辑封面仍然可用；
- 播放进度仍然可用；
- EQ 动态条仍然可用；
- 只是 CPU / GPU / 内存 / 磁盘等系统信息不再显示。

如果你想清理本地运行时数据，可以打开：

START_HERE.bat

然后选择清理数据选项。

---

# 九、最简单使用流程

如果你只是想快速使用：

1. 订阅壁纸
2. 应用壁纸
3. 音乐信息、封面、播放进度、EQ 自动工作

如果你想显示完整系统信息：

1. 在 Wallpaper Engine 中右键该壁纸
2. 选择“在资源管理器中打开”
3. 打开 Windows 文件扩展名显示
4. 将 START_HERE.bat.txt 改成 START_HERE.bat
5. 将 Install Helper.bat.txt 改成 Install Helper.bat
6. 将 Uninstall Helper.bat.txt 改成 Uninstall Helper.bat
7. 进入 publish 文件夹
8. 将 cmdwallpaper_agent.exe.txt 改成 cmdwallpaper_agent.exe
9. 回到壁纸根目录
10. 双击 START_HERE.bat
11. 选择安装 helper
12. 重新加载壁纸或重启 Wallpaper Engine

---

# 十、文件说明

壁纸目录中主要文件说明如下：

wallpaper.html  
壁纸主界面文件。

project.json  
Wallpaper Engine 项目配置文件。

START_HERE.bat  
安装 / 卸载 / 清理 helper 的菜单入口。

Install Helper.bat  
一键安装系统信息 helper。

Uninstall Helper.bat  
一键卸载系统信息 helper。

publish\cmdwallpaper_agent.exe  
系统信息 helper 程序。

data\  
本地运行时数据目录。

helper 生成的系统信息、日志、封面缓存等会写入这个文件夹。

---

# 十一、常见问题

## Q1：为什么我订阅后只能看到音乐信息，看不到 CPU / GPU / 内存？

这是正常的。

订阅后默认是基础模式。

基础模式包括：

- 音乐标题
- 歌手
- 专辑封面
- 播放进度
- EQ 动态条

这些功能不需要安装 helper。

如果你想显示 CPU、GPU、内存、磁盘等完整系统信息，需要按照上面的步骤启用 helper。

## Q2：为什么双击 START_HERE.bat 没反应？

请检查文件名是否真的改对了。

正确文件名：

START_HERE.bat

错误文件名：

START_HERE.bat.txt

请先打开 Windows 的“文件扩展名”显示，再重新检查文件名。

## Q3：为什么安装时提示找不到 agent？

请检查这个文件是否存在：

publish\cmdwallpaper_agent.exe

如果它仍然是：

cmdwallpaper_agent.exe.txt

请改成：

cmdwallpaper_agent.exe

注意：最终文件名不能带 .txt。

## Q4：为什么改名后仍然无法运行？

请检查这几点：

1. 是否已经打开“文件扩展名”显示；
2. 文件名是否真的变成了 .exe 和 .bat；
3. publish\cmdwallpaper_agent.exe 是否存在；
4. 是否被 Windows 安全中心或杀毒软件拦截；
5. 是否从正确的壁纸目录运行安装程序。

建议操作：

右键壁纸 → 在资源管理器中打开 → 在该目录中操作

不要把文件复制到其他目录后再运行。

## Q5：Windows 提示该文件可能不安全怎么办？

这是因为 helper 是本地程序，会读取你的系统信息并写入本地 data 文件夹。

如果你信任本项目，可以选择继续运行。

helper 只在本地工作，不会上传数据。

如果你不想运行本地程序，可以不安装 helper。基础音乐信息和 EQ 仍然可以正常使用。

## Q6：EQ 不动怎么办？

请检查：

1. 当前是否正在播放音乐；
2. Wallpaper Engine 是否启用了音频响应；
3. Windows 音量混合器中 Wallpaper Engine 是否被静音；
4. 播放器是否有系统音频输出；
5. 尝试重新加载壁纸或重启 Wallpaper Engine；
6. 尝试切换 Wallpaper Engine 的音频录制设备。

正常情况下，底部状态栏会显示：

EQ:WE-AUDIO

## Q7：专辑封面不显示怎么办？

可能原因：

- 当前播放器没有提供封面；
- 当前音乐没有专辑封面；
- 刚切歌时需要等待 1-2 秒；
- Wallpaper Engine 媒体集成暂时没有刷新；
- 某些播放器不支持系统媒体信息。

可以尝试：

- 换一首歌；
- 重启 Wallpaper Engine；
- 使用支持系统媒体信息的播放器；
- 等待几秒后刷新壁纸。

## Q8：系统信息没有刷新怎么办？

请检查：

1. 是否运行过 Install Helper.bat；
2. data/system_info.json 是否存在；
3. helper 是否被安全软件拦截；
4. 是否从正确的壁纸目录运行安装程序；
5. 是否移动过壁纸文件夹；
6. 是否重新订阅后路径发生变化。

如果重新订阅或路径变化，请重新运行：

Install Helper.bat

## Q9：卸载 helper 后会影响壁纸吗？

不会。

卸载 helper 后：

- 音乐信息仍然可用；
- 专辑封面仍然可用；
- 播放进度仍然可用；
- EQ 仍然可用；
- 只是完整系统信息不再显示。

---

# 十二、隐私说明

helper 只会在本地读取系统信息，并写入当前壁纸文件夹中的 data 目录。

可能生成的本地文件包括：

data/system_info.json
data/smtc_data.json
data/album_art.jpg
data/cmdwallpaper_agent.log

这些文件只保存在你的电脑本地，不会上传到网络。

其中可能包含：

- 用户名
- 电脑名
- 局域网 IP
- CPU / GPU / 内存 / 磁盘信息
- 当前播放音乐信息
- 当前专辑封面

如果你介意这些信息，可以不安装 helper。

不安装 helper 时，基础音乐显示和 EQ 功能仍然可以正常使用。

---

# 十三、推荐环境

建议使用：

- Windows 10 / Windows 11
- Wallpaper Engine
- 支持系统媒体信息的音乐播放器
- 支持音频输出的播放环境

推荐播放器包括：

- Spotify
- 网易云音乐
- QQ 音乐
- Apple Music
- Edge / Chrome 网页播放器
- 其他支持系统媒体信息的播放器

---

# 十四、开发者说明

如果你是开发者，并且想自己编译 helper，可以使用：

dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o publish

这会生成自带 .NET Runtime 的单文件 helper。

生成后的文件位于：

publish\cmdwallpaper_agent.exe

普通用户不需要执行这一步。

---

# 十五、项目地址

源代码和更新说明：

https://github.com/NeoKe-42/cmdwallpaper

如果你只想要一个好看的音乐终端壁纸，直接订阅并应用即可。

如果你想让它像 neofetch 一样显示完整硬件信息，请按照上面的步骤启用 helper。
