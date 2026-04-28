# Wallpaper Engine - cmdwallpaper install
# Run once, then forget. Service auto-starts on every login.

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper v0.2.0-local" -ForegroundColor Cyan
Write-Host "  One-time install" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Create runtime directories
Write-Host "[1/3] Creating runtime directories..." -ForegroundColor Yellow
$dataDir = Join-Path $scriptDir "data"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    Write-Host "  OK - data/ created" -ForegroundColor Green
} else {
    Write-Host "  OK - data/ exists" -ForegroundColor Green
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
Write-Host "Runtime data written to data/" -ForegroundColor Gray
Write-Host "Service auto-starts when you log into Windows." -ForegroundColor Gray
