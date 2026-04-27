# System info collector for terminal-style Wallpaper Engine wallpaper
# Collects: CPU, GPU, RAM, disk, OS, network, audio volume, now playing

param(
    [string]$OutputFile = "system_info.json"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load compiled C# helper (CoreAudio + now-playing)
$dllPath = Join-Path $scriptDir "media_helper.dll"
if (Test-Path $dllPath) {
    try { Add-Type -Path $dllPath -ErrorAction Stop | Out-Null } catch { }
}

# ============================================================
# Core system info (CPU, GPU, RAM, disk, OS, motherboard)
# ============================================================

function Get-SystemInfo {
    $info = @{}

    $info["timestamp"] = (Get-Date).ToUniversalTime().ToString("o")

    $info["system"] = @{
        "hostname" = [System.Environment]::MachineName
        "username" = [System.Environment]::UserName
    }

    $osInfo = Get-CimInstance Win32_OperatingSystem
    $info["os"] = @{
        "name" = $osInfo.Caption
        "version" = $osInfo.Version
        "build" = $osInfo.BuildNumber
        "architecture" = $osInfo.OSArchitecture
    }

    $totalMem = [math]::Round($osInfo.TotalVisibleMemorySize / 1024 / 1024, 2)
    $freeMem = [math]::Round($osInfo.FreePhysicalMemory / 1024 / 1024, 2)
    $usedMem = $totalMem - $freeMem
    $memPercent = [math]::Round(($usedMem / $totalMem) * 100, 1)

    $info["memory"] = @{
        "total_gb" = $totalMem
        "used_gb" = $usedMem
        "available_gb" = $freeMem
        "percent" = $memPercent
    }

    $cpuInfo = Get-CimInstance Win32_Processor
    $info["cpu"] = @{
        "name" = $cpuInfo.Name.Trim()
        "cores" = $cpuInfo.NumberOfCores
        "threads" = $cpuInfo.NumberOfLogicalProcessors
        "frequency_mhz" = $cpuInfo.MaxClockSpeed
    }

    $gpuInfo = Get-CimInstance Win32_VideoController
    $info["gpu"] = @()
    foreach ($gpu in $gpuInfo) { $info["gpu"] += $gpu.Name }

    $info["disk"] = @{}
    $disks = Get-Volume | Where-Object { $_.DriveLetter -and $_.SizeRemaining -gt 0 }
    foreach ($disk in $disks) {
        $letter = $disk.DriveLetter
        $totalSize = [math]::Round($disk.Size / 1GB, 2)
        $freeSize = [math]::Round($disk.SizeRemaining / 1GB, 2)
        $usedSize = $totalSize - $freeSize
        $percent = if ($totalSize -gt 0) { [math]::Round(($usedSize / $totalSize) * 100, 1) } else { 0 }
        $info["disk"]["${letter}:"] = @{
            "mount" = "${letter}:\"
            "total_gb" = $totalSize
            "used_gb" = $usedSize
            "free_gb" = $freeSize
            "percent" = $percent
        }
    }

    $mbInfo = Get-CimInstance Win32_BaseBoard
    $info["motherboard"] = "$($mbInfo.Manufacturer) $($mbInfo.Product)"

    return $info
}

# ============================================================
# Network: active IPv4 address
# ============================================================

function Get-NetworkInfo {
    try {
        $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.AddressState -eq 'Preferred' } |
            Sort-Object -Property { $_.InterfaceMetric -as [int] } |
            Select-Object -First 1
        if ($ip) { return @{ "ipv4" = $ip.IPAddress; "interface" = $ip.InterfaceAlias } }
    } catch { }
    return @{ "ipv4" = $null; "interface" = $null }
}

# ============================================================
# Audio volume via compiled DLL (CoreAudio COM)
# ============================================================

function Get-AudioVolume {
    try {
        $muted = $false
        $vol = [MediaHelper]::GetMasterVolume([ref] $muted)
        $peak = [MediaHelper]::GetAudioPeakLevel()
        if ($vol -ge 0) {
            return @{ "volume_percent" = $vol; "muted" = $muted; "peak" = $peak }
        }
    } catch { }
    return @{ "volume_percent" = $null; "muted" = $null; "peak" = $null }
}

# ============================================================
# Now playing via window title parsing (compiled DLL)
# ============================================================

function Get-NowPlaying {
    $result = @{ "status" = "no_media" }
    try {
        $title = $null; $artist = $null; $album = $null; $pos = -1.0; $dur = -1.0
        $source = [MediaHelper]::GetNowPlayingInfo([ref] $title, [ref] $artist, [ref] $album, [ref] $pos, [ref] $dur)
        if ($source) {
            $result["status"] = "playing"
            if ($title) { $result["title"] = $title }
            if ($artist) { $result["artist"] = $artist }
            if ($album) { $result["album_title"] = $album }
            $result["source"] = $source
        }
    } catch { }
    return $result
}

# ============================================================
# Main: collect all info and write JSON
# ============================================================

try {
    $sysInfo = Get-SystemInfo
    $sysInfo["network"] = Get-NetworkInfo
    $sysInfo["audio"] = Get-AudioVolume
    $sysInfo["now_playing"] = Get-NowPlaying

    $json = $sysInfo | ConvertTo-Json -Depth 10

    $tmpFile = $OutputFile + ".tmp"
    $utf8BOM = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($tmpFile, $json, $utf8BOM)
    Move-Item -Path $tmpFile -Destination $OutputFile -Force

    Write-Host "OK - System info saved to $OutputFile"
}
catch {
    Write-Host "Error: $_"
    exit 1
}
