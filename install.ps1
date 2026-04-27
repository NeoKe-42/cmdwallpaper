# Wallpaper Engine - System Info Terminal Wallpaper install
# Run once, then forget. Service auto-starts on every login.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  System Info Terminal Wallpaper" -ForegroundColor Cyan
Write-Host "  One-time install" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Generate initial system info
Write-Host "[1/3] Generating system info..." -ForegroundColor Yellow
try {
    & (Join-Path $scriptDir "get_system_info.ps1") -OutputFile (Join-Path $scriptDir "system_info.json")
    Write-Host "  OK - system_info.json created" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: $_" -ForegroundColor Red
    exit 1
}

# 2. Add to Windows Startup folder
Write-Host "[2/3] Registering auto-start..." -ForegroundColor Yellow
$startupDir = [Environment]::GetFolderPath("Startup")
$batPath = Join-Path $startupDir "WallpaperSystemInfo.bat"
$vbsPath = Join-Path $scriptDir "start_service.vbs"

"@echo off`r`nwscript.exe `"$vbsPath`"" | Out-File -FilePath $batPath -Encoding ASCII

if (Test-Path $batPath) {
    Write-Host "  OK - Added to Startup folder" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Could not write to Startup folder" -ForegroundColor Yellow
}

# 3. Start the background service now
Write-Host "[3/3] Starting background service..." -ForegroundColor Yellow
try {
    Start-Process wscript.exe -ArgumentList "`"$vbsPath`"" -WindowStyle Hidden
    Start-Sleep -Seconds 2
    Write-Host "  OK - Background service started" -ForegroundColor Green
} catch {
    Write-Host "  WARNING: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Install complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step:" -ForegroundColor White
Write-Host "  Wallpaper Engine -> Open from File ->" -ForegroundColor White
Write-Host "  $scriptDir\project.json" -ForegroundColor Yellow
Write-Host ""
Write-Host "System info updates every 5 seconds." -ForegroundColor Gray
Write-Host "Service auto-starts when you log into Windows." -ForegroundColor Gray
