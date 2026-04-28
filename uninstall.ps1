# cmdwallpaper uninstall
param([switch]$CleanData)

$ProjectRoot = $PSScriptRoot
$AgentExe = Join-Path $ProjectRoot "publish\cmdwallpaper_agent.exe"
$DataDir = Join-Path $ProjectRoot "data"
$PidFile = Join-Path $ProjectRoot "cmdwallpaper.pid"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper uninstall" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ProjectRoot: $ProjectRoot" -ForegroundColor Gray
Write-Host ""

# ── 1. Stop agent ──────────────────────────────────────
Write-Host "[1/2] Stopping agent..." -ForegroundColor Yellow

# Stop by PID file
if (Test-Path $PidFile) {
    try {
        $pid = [int](Get-Content $PidFile -Raw).Trim()
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$pid" -ErrorAction SilentlyContinue
        if ($proc) {
            $exePath = $proc.ExecutablePath
            if ($exePath -and ($exePath -eq $AgentExe -or $exePath -like "*$ProjectRoot*")) {
                Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
                Write-Host "  Stopped PID $pid" -ForegroundColor Green
            }
        }
    } catch { }
}

# Stop all agents in this project root
$procs = Get-CimInstance Win32_Process -Filter "Name='cmdwallpaper_agent.exe'" -ErrorAction SilentlyContinue
foreach ($p in $procs) {
    $exePath = $p.ExecutablePath
    if ($exePath -and ($exePath -eq $AgentExe -or $exePath -like "*$ProjectRoot*")) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped PID $($p.ProcessId)" -ForegroundColor Green
    }
}

# Remove PID file
if (Test-Path $PidFile) {
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 1
Write-Host "  Done" -ForegroundColor Green

# ── 2. Remove startup entry ────────────────────────────
Write-Host "[2/2] Removing startup entry..." -ForegroundColor Yellow
$startupDir = [Environment]::GetFolderPath("Startup")
$batPath = Join-Path $startupDir "WallpaperSystemInfo.bat"

if (Test-Path $batPath) {
    Remove-Item $batPath -Force -ErrorAction SilentlyContinue
    Write-Host "  Removed: $batPath" -ForegroundColor Green
} else {
    Write-Host "  No startup entry found" -ForegroundColor Gray
}

# ── 3. Optional: clean runtime data ────────────────────
if ($CleanData) {
    Write-Host ""
    Write-Host "Cleaning runtime data..." -ForegroundColor Yellow

    $patterns = @(
        "system_info.json", "system_info.json.tmp",
        "smtc_data.json", "smtc_data.json.tmp",
        "eq_data.json",
        "album_art.jpg", "album_art.png", "album_art.tmp",
        "cmdwallpaper_agent.log"
    )

    foreach ($p in $patterns) {
        $path = Join-Path $DataDir $p
        if (Test-Path $path) {
            Remove-Item $path -Force -ErrorAction SilentlyContinue
            Write-Host "  Removed: data/$p" -ForegroundColor Gray
        }
    }

    Write-Host "  .gitkeep preserved" -ForegroundColor Green
    Write-Host ""
    Write-Host "Source files and publish/ are unchanged." -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Uninstall complete." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
