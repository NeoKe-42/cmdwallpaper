-- Wallpaper Engine Lua 脚本
-- 读取系统信息 JSON 并更新壁纸显示

local json = require("rapidjson")

-- 配置
local SYSTEM_INFO_FILE = "system_info.json"
local UPDATE_INTERVAL = 5  -- 秒

-- 缓存
local lastUpdateTime = 0
local cachedDisplayData = {}

--- 读取系统信息 JSON 文件（带错误保护）
local function readSystemInfo()
    local file, err = io.open(SYSTEM_INFO_FILE, "r")
    if not file then
        return nil
    end

    local content, readErr = file:read("*all")
    file:close()

    if not content then
        return nil
    end

    local ok, data = pcall(function()
        return json.decode(content)
    end)

    if ok then
        return data
    else
        return nil
    end
end

--- 格式化内存显示
local function formatMemory(gb)
    return string.format("%.2f GiB", gb)
end

--- 格式化磁盘显示
local function formatDisk(gb)
    return string.format("%.2f GiB", gb)
end

--- 获取主要 GPU 名称
local function getPrimaryGPU(gpuList)
    if gpuList and #gpuList > 0 then
        return gpuList[1]
    end
    return "Unknown"
end

--- 更新系统信息到全局变量供 scene.json 使用
local function updateSystemDisplay()
    local currentTime = os.time()

    -- 检查更新间隔（真正使用缓存，避免频繁磁盘读取）
    if currentTime - lastUpdateTime < UPDATE_INTERVAL then
        return cachedDisplayData
    end

    lastUpdateTime = currentTime

    local info = readSystemInfo()
    if not info then
        return cachedDisplayData
    end

    -- 构造显示文本
    local displayData = {}

    -- CPU 信息
    if info.cpu then
        displayData.cpu_name = info.cpu.name or "Unknown"
        displayData.cpu_cores = string.format("%d Cores / %d Threads",
                                             info.cpu.cores or 0,
                                             info.cpu.threads or 0)
    end

    -- GPU 信息
    if info.gpu then
        displayData.gpu_name = getPrimaryGPU(info.gpu)
    end

    -- 内存信息
    if info.memory then
        displayData.memory = string.format("%s / %s (%.0f%%)",
                                          formatMemory(info.memory.used_gb or 0),
                                          formatMemory(info.memory.total_gb or 0),
                                          info.memory.percent or 0)
    end

    -- 磁盘信息（C: 盘）
    if info.disk and info.disk["C:"] then
        local disk = info.disk["C:"]
        displayData.disk = string.format("%s / %s (%.0f%%)",
                                        formatDisk(disk.used_gb or 0),
                                        formatDisk(disk.total_gb or 0),
                                        disk.percent or 0)
    end

    -- 系统信息
    if info.system then
        displayData.host = info.system.hostname or "Unknown"
        displayData.user = info.system.username or "Unknown"
    end

    -- OS 信息
    if info.os then
        displayData.os_name = info.os.name or "Unknown"
        displayData.os_version = info.os.version or ""
    end

    -- 主板信息
    if info.motherboard then
        displayData.motherboard = info.motherboard
    end

    -- 更新缓存
    cachedDisplayData = displayData

    return displayData
end

--- 获取缓存的显示数据
local function getDisplayData()
    return updateSystemDisplay()
end

-- 导出函数供外部调用
return {
    getDisplayData = getDisplayData,
    readSystemInfo = readSystemInfo
}
