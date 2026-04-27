# Wallpaper Engine 动态系统信息集成完整指南

## 🎯 概述

本方案使用 PowerShell 后台服务采集系统信息，定期更新 JSON 文件，Wallpaper Engine 通过 Lua 脚本读取并显示动态信息。

**不需要 Python，无外部依赖！**

## 📁 项目文件说明

| 文件 | 作用 |
|-----|------|
| `get_system_info.ps1` | 系统信息采集脚本（一次性运行） |
| `system_info_updater.ps1` | 后台定时更新服务 |
| `system_info.json` | 输出文件（动态生成） |
| `system_info_loader.lua` | Lua 数据加载器 |

## 📊 采集的系统信息

```json
{
  "timestamp": "ISO 8601 时间",
  "system": {
    "hostname": "主机名",
    "username": "用户名"
  },
  "os": {
    "name": "系统名称",
    "version": "版本号",
    "build": "构建号",
    "architecture": "架构（x64/x86）"
  },
  "cpu": {
    "name": "处理器名称",
    "cores": 核心数,
    "threads": 线程数,
    "frequency_mhz": 最大频率
  },
  "gpu": ["GPU1", "GPU2"],
  "memory": {
    "total_gb": 总容量,
    "used_gb": 已用,
    "available_gb": 可用,
    "percent": 使用百分比
  },
  "disk": {
    "C:": {
      "mount": "C:\\",
      "total_gb": 总容量,
      "used_gb": 已用,
      "free_gb": 空闲,
      "percent": 使用百分比
    }
  },
  "motherboard": "主板型号"
}
```

## 🚀 快速启动（仅需 3 步）

### 第 1 步：生成初始数据
在项目目录打开 PowerShell 并运行：
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File get_system_info.ps1
```

验证：应该生成 `system_info.json` 文件

### 第 2 步：启动后台更新服务

#### 方式 A：临时运行（用于测试）
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File system_info_updater.ps1 -UpdateInterval 5
```
按 Ctrl+C 停止

#### 方式 B：永久后台运行（推荐）
保存下面的脚本为 `start_service.vbs`：
```vbscript
Set objShell = CreateObject("WScript.Shell")
strCommand = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File system_info_updater.ps1 -UpdateInterval 5"
objShell.Run strCommand, 0, False
```

### 第 3 步：在 Wallpaper Engine 中集成
1. 复制 `system_info_loader.lua` 到项目目录
2. 在 Wallpaper Engine 编辑器中引入 Lua 脚本
3. 关联文本元素到脚本输出变量

## 🔧 高级配置

修改更新频率：
```powershell
-UpdateInterval 10  # 每 10 秒更新
```

## 🐛 故障排除

### 问题：system_info.json 不更新
```powershell
# 手动测试脚本
powershell -NoProfile -ExecutionPolicy Bypass -File get_system_info.ps1

# 检查 JSON 有效性
Get-Content system_info.json | ConvertFrom-Json
```

### 问题：权限被拒绝
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📝 集成流程

```
get_system_info.ps1 → system_info.json → system_info_loader.lua → 壁纸显示
       (采集)              (存储)              (读取+格式化)         (实时更新)
```
