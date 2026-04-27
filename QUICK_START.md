# 🚀 cmdwallpaper 使用指南

## 📁 文件夹结构

```
F:\3634342477\
├── 📄 原始壁纸文件
│   ├── project.json              (壁纸配置)
│   ├── scene.pkg                 (场景数据)
│   ├── preview.gif               (预览图)
│   └── ...其他原始文件
│
└── 📂 cmdwallpaper/              (✨ 动态系统信息组件)
    ├── get_system_info.ps1       (采集脚本)
    ├── system_info_updater.ps1   (更新服务)
    ├── system_info_loader.lua    (Lua 加载器)
    ├── system_info.json          (动态数据)
    ├── start_service.vbs         (启动工具)
    ├── verify_installation.ps1   (验证脚本)
    ├── README.md                 (快速开始)
    ├── INTEGRATION_GUIDE.md      (集成指南)
    ├── PROJECT_SUMMARY.md        (完成总结)
    └── CHECKLIST.md              (完成清单)
```

## ⚡ 快速启动

### 方法 1: 在 cmdwallpaper 文件夹中运行（推荐）

在 `F:\3634342477\cmdwallpaper\` 中打开 PowerShell：

```powershell
# 1. 生成系统信息
powershell -NoProfile -ExecutionPolicy Bypass -File get_system_info.ps1

# 2. 启动后台服务
cscript start_service.vbs

# 3. 验证安装
powershell -NoProfile -ExecutionPolicy Bypass -File verify_installation.ps1
```

### 方法 2: 从任何位置运行

```powershell
cd F:\3634342477\cmdwallpaper

# 运行任何脚本
powershell -NoProfile -ExecutionPolicy Bypass -File get_system_info.ps1
```

## 📊 输出数据

脚本会在 `F:\3634342477\cmdwallpaper\` 中生成 `system_info.json`：

```json
{
  "timestamp": "2026-04-27T14:31:03.866Z",
  "cpu": {
    "name": "AMD Ryzen 7 6800H",
    "cores": 8,
    "threads": 16
  },
  "gpu": ["NVIDIA RTX 3060", "AMD Radeon"],
  "memory": {
    "total_gb": 31.19,
    "used_gb": 24.16,
    "percent": 77.5
  },
  "disk": {...},
  "os": {...}
}
```

## 🎯 集成到 Wallpaper Engine

详见 `cmdwallpaper/INTEGRATION_GUIDE.md` 的详细步骤

## 🔍 文件说明

| 文件 | 大小 | 说明 |
|------|------|------|
| `get_system_info.ps1` | 3.0 KB | 一次性采集脚本 |
| `system_info_updater.ps1` | 1.2 KB | 后台定时更新 |
| `system_info_loader.lua` | 3.5 KB | Lua 接口 |
| `system_info.json` | 1.9 KB | 动态数据（自动生成） |
| `start_service.vbs` | 970 B | VBS 启动器 |
| `verify_installation.ps1` | 2.4 KB | 验证脚本 |
| `README.md` | 5.3 KB | 快速开始指南 |
| `INTEGRATION_GUIDE.md` | 3.1 KB | 集成详细步骤 |
| `PROJECT_SUMMARY.md` | 5.2 KB | 技术方案 |
| `CHECKLIST.md` | 5.5 KB | 完成清单 |

## ✅ 一键启动

双击 `start_service.vbs` 即可启动后台系统信息采集服务：

```
cmdwallpaper/
└── start_service.vbs  (双击运行)
```

## 🐛 故障排除

运行验证脚本检查所有组件：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File verify_installation.ps1
```

详见 `README.md` 的故障排除部分。

## 💡 更新频率配置

编辑 `system_info_updater.ps1` 中的参数：

```powershell
# 默认 5 秒更新一次
powershell -NoProfile -ExecutionPolicy Bypass -File system_info_updater.ps1 -UpdateInterval 5

# 10 秒更新一次
powershell -NoProfile -ExecutionPolicy Bypass -File system_info_updater.ps1 -UpdateInterval 10
```

---

**现在开始使用吧！** 🎉
