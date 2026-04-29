# cmdwallpaper — Workshop package script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$ParentDir = Split-Path -Parent $ProjectRoot
$PackageDir = Join-Path $ParentDir "cmdwallpaper_workshop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper Workshop Packager" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Project root : $ProjectRoot" -ForegroundColor Gray
Write-Host "Package dir  : $PackageDir" -ForegroundColor Gray
Write-Host ""

# ── Check agent exe exists ────────────────────────────────
$AgentSrc = Join-Path $ProjectRoot "publish\cmdwallpaper_agent.exe"
if (-not (Test-Path $AgentSrc)) {
    Write-Host "ERROR: publish\cmdwallpaper_agent.exe not found." -ForegroundColor Red
    Write-Host "Please build it first:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build_agent.ps1" -ForegroundColor White
    exit 1
}
Write-Host "[OK] Agent found" -ForegroundColor Green

# ── Clean old package dir ─────────────────────────────────
if (Test-Path $PackageDir) {
    Remove-Item $PackageDir -Recurse -Force -ErrorAction Stop
    Write-Host "[OK] Removed old package dir" -ForegroundColor Green
}

New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null
Write-Host "[OK] Created $PackageDir" -ForegroundColor Green

# ── Helper: copy file (preserve relative path) ────────────
function Copy-PkgFile($src, $dst) {
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item $src $dst -Force
    Write-Host "  + $(Resolve-Path $src -Relative)" -ForegroundColor Gray
}

# ── Copy root files ───────────────────────────────────────
Write-Host ""
Write-Host "Copying root files..." -ForegroundColor Yellow
$rootFiles = @(
    "wallpaper.html", "project.json", "README.md",
    "install.ps1", "uninstall.ps1", "run_agent.ps1",
    "start_service.vbs"
)
foreach ($f in $rootFiles) {
    $src = Join-Path $ProjectRoot $f
    $dst = Join-Path $PackageDir $f
    if (Test-Path $src) {
        Copy-PkgFile $src $dst
    } else {
        Write-Host "  WARN: $f not found" -ForegroundColor Yellow
    }
}

# ── Copy assets/ ──────────────────────────────────────────
Write-Host "Copying assets/..." -ForegroundColor Yellow
$srcAssets = Join-Path $ProjectRoot "assets"
$dstAssets = Join-Path $PackageDir "assets"
if (Test-Path $srcAssets) {
    Copy-Item $srcAssets $dstAssets -Recurse -Force
    Get-ChildItem $dstAssets -Recurse -File | ForEach-Object {
        Write-Host "  + $(Resolve-Path $_.FullName -Relative)" -ForegroundColor Gray
    }
}

# ── Copy data/.gitkeep ────────────────────────────────────
Write-Host "Copying data/.gitkeep..." -ForegroundColor Yellow
$srcGitkeep = Join-Path $ProjectRoot "data\.gitkeep"
$dstDataDir = Join-Path $PackageDir "data"
if (Test-Path $srcGitkeep) {
    New-Item -ItemType Directory -Path $dstDataDir -Force | Out-Null
    Copy-PkgFile $srcGitkeep (Join-Path $dstDataDir ".gitkeep")
}

# ── Copy agent exe ────────────────────────────────────────
Write-Host "Copying agent exe..." -ForegroundColor Yellow
$dstPublish = Join-Path $PackageDir "publish"
New-Item -ItemType Directory -Path $dstPublish -Force | Out-Null
Copy-PkgFile $AgentSrc (Join-Path $dstPublish "cmdwallpaper_agent.exe")

# ── Generate .txt wrappers for Workshop filter bypass ─────
Write-Host "Generating .txt wrappers..." -ForegroundColor Yellow
Copy-Item (Join-Path $dstPublish "cmdwallpaper_agent.exe") (Join-Path $dstPublish "cmdwallpaper_agent.exe.txt") -Force
Write-Host "  + publish/cmdwallpaper_agent.exe.txt" -ForegroundColor Gray

# START_HERE.bat.txt
@"
@echo off
cd /d "%~dp0"
title CMD Wallpaper Helper
:menu
cls
echo ================================
echo   CMD Wallpaper Helper
echo ================================
echo.
echo [1] Install helper
echo [2] Uninstall helper
echo [3] Clean runtime data
echo [4] Run helper once (foreground)
echo [0] Exit
echo.
set /p choice="Select: "

if "%choice%"=="1" (
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
    echo.
    pause
    goto menu
)
if "%choice%"=="2" (
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
    echo.
    pause
    goto menu
)
if "%choice%"=="3" (
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1" -CleanData
    echo.
    pause
    goto menu
)
if "%choice%"=="4" (
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_agent.ps1"
    echo.
    pause
    goto menu
)
if "%choice%"=="0" exit /b
goto menu
"@ | Out-File -FilePath (Join-Path $PackageDir "START_HERE.bat.txt") -Encoding ASCII
Write-Host "  + START_HERE.bat.txt" -ForegroundColor Gray

# Install Helper.bat.txt
@"
@echo off
cd /d "%~dp0"
title CMD Wallpaper Helper Installer
echo ================================
echo CMD Wallpaper Helper Installer
echo ================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
"@ | Out-File -FilePath (Join-Path $PackageDir "Install Helper.bat.txt") -Encoding ASCII
Write-Host "  + Install Helper.bat.txt" -ForegroundColor Gray

# Uninstall Helper.bat.txt
@"
@echo off
cd /d "%~dp0"
title CMD Wallpaper Helper Uninstaller
echo ================================
echo CMD Wallpaper Helper Uninstaller
echo ================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
echo.
pause
"@ | Out-File -FilePath (Join-Path $PackageDir "Uninstall Helper.bat.txt") -Encoding ASCII
Write-Host "  + Uninstall Helper.bat.txt" -ForegroundColor Gray

# ── Verify agent exe in package ───────────────────────────
$pkgAgent = Join-Path $dstPublish "cmdwallpaper_agent.exe"
if (-not (Test-Path $pkgAgent)) {
    Write-Host ""
    Write-Host "ERROR: Agent exe missing from package!" -ForegroundColor Red
    Write-Host "  $pkgAgent" -ForegroundColor Red
    exit 1
}

# ── Done ──────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Workshop package created successfully." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package path : $PackageDir" -ForegroundColor Gray
Write-Host "Source path  : $ProjectRoot" -ForegroundColor Gray
Write-Host ""
Write-Host "Import project.json from the package folder into Wallpaper Engine." -ForegroundColor White
Write-Host ""
Write-Host "Workshop note:" -ForegroundColor Yellow
Write-Host "  .bat and .exe files have .txt suffix for Workshop filter bypass." -ForegroundColor Gray
Write-Host "  Users must rename them back after downloading." -ForegroundColor Gray
