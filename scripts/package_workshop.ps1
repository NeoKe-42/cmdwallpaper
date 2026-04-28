# cmdwallpaper — Workshop package script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$ParentDir = Split-Path -Parent $ProjectRoot
$PackageDir = Join-Path $ParentDir "cmdwallpaper_workshop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper Workshop packager" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Project root : $ProjectRoot" -ForegroundColor Gray
Write-Host "Package dir  : $PackageDir" -ForegroundColor Gray
Write-Host ""

# ── Check agent exe exists ──────────────────────────────
$AgentSrc = Join-Path $ProjectRoot "publish\cmdwallpaper_agent.exe"
if (-not (Test-Path $AgentSrc)) {
    Write-Host "ERROR: publish\cmdwallpaper_agent.exe not found." -ForegroundColor Red
    Write-Host "Please build it first:" -ForegroundColor Yellow
    Write-Host "  dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 -o publish" -ForegroundColor White
    exit 1
}
Write-Host "[OK] Agent found" -ForegroundColor Green

# ── Git info ────────────────────────────────────────────
$gitBranch = "unknown"
$gitCommit = "unknown"
$gitMessage = "unknown"
try {
    $gitBranch = git -C $ProjectRoot branch --show-current 2>$null
    if (-not $gitBranch) { $gitBranch = "unknown" }
    $gitCommit = git -C $ProjectRoot rev-parse --short HEAD 2>$null
    if (-not $gitCommit) { $gitCommit = "unknown" }
    $gitMessage = git -C $ProjectRoot log -1 --pretty=%s 2>$null
    if (-not $gitMessage) { $gitMessage = "unknown" }
} catch { }
Write-Host "[OK] Branch: $gitBranch, Commit: $gitCommit" -ForegroundColor Green

# ── Clean old package dir ───────────────────────────────
if (Test-Path $PackageDir) {
    Remove-Item $PackageDir -Recurse -Force -ErrorAction Stop
    Write-Host "[OK] Removed old package dir" -ForegroundColor Green
}

New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null
Write-Host "[OK] Created $PackageDir" -ForegroundColor Green

# ── Helper: copy file (preserve relative path) ──────────
function Copy-PkgFile($src, $dst) {
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item $src $dst -Force
    Write-Host "  + $(Resolve-Path $src -Relative)" -ForegroundColor Gray
}

# ── Copy root files ─────────────────────────────────────
Write-Host ""
Write-Host "Copying root files..." -ForegroundColor Yellow
$rootFiles = @(
    "wallpaper.html", "project.json", "README.md",
    "install.ps1", "uninstall.ps1", "run_agent.ps1",
    "start_service.vbs", "cmdwallpaper_agent.cs", "cmdwallpaper_agent.csproj"
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

# ── Copy assets/ ────────────────────────────────────────
Write-Host "Copying assets/..." -ForegroundColor Yellow
$srcAssets = Join-Path $ProjectRoot "assets"
$dstAssets = Join-Path $PackageDir "assets"
if (Test-Path $srcAssets) {
    Copy-Item $srcAssets $dstAssets -Recurse -Force
    Get-ChildItem $dstAssets -Recurse -File | ForEach-Object {
        Write-Host "  + $(Resolve-Path $_.FullName -Relative)" -ForegroundColor Gray
    }
}

# ── Copy data/.gitkeep ──────────────────────────────────
Write-Host "Copying data/.gitkeep..." -ForegroundColor Yellow
$srcGitkeep = Join-Path $ProjectRoot "data\.gitkeep"
$dstDataDir = Join-Path $PackageDir "data"
if (Test-Path $srcGitkeep) {
    New-Item -ItemType Directory -Path $dstDataDir -Force | Out-Null
    Copy-PkgFile $srcGitkeep (Join-Path $dstDataDir ".gitkeep")
}

# ── Copy publish/cmdwallpaper_agent.exe ─────────────────
Write-Host "Copying publish/cmdwallpaper_agent.exe..." -ForegroundColor Yellow
$dstPublish = Join-Path $PackageDir "publish"
New-Item -ItemType Directory -Path $dstPublish -Force | Out-Null
Copy-PkgFile $AgentSrc (Join-Path $dstPublish "cmdwallpaper_agent.exe")

# ── Generate helper .bat files in package root ───────────
Write-Host "Generating helper .bat files..." -ForegroundColor Yellow

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
"@ | Out-File -FilePath (Join-Path $PackageDir "Install Helper.bat") -Encoding ASCII
Write-Host "  + Install Helper.bat" -ForegroundColor Gray

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
"@ | Out-File -FilePath (Join-Path $PackageDir "Uninstall Helper.bat") -Encoding ASCII
Write-Host "  + Uninstall Helper.bat" -ForegroundColor Gray

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
"@ | Out-File -FilePath (Join-Path $PackageDir "START_HERE.bat") -Encoding ASCII
Write-Host "  + START_HERE.bat" -ForegroundColor Gray

# ── Generate BUILD_INFO.txt ─────────────────────────────
Write-Host ""
Write-Host "Generating BUILD_INFO.txt..." -ForegroundColor Yellow
$buildTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$buildInfo = @"
CMD Wallpaper Workshop Package
==============================

Package path:
$PackageDir

Source repository:
$ProjectRoot

Git branch:
$gitBranch

Git commit:
$gitCommit

Git commit message:
$gitMessage

Build time:
$buildTime

Included:
- wallpaper.html
- project.json
- README.md
- install.ps1
- uninstall.ps1
- run_agent.ps1
- start_service.vbs
- Install Helper.bat (generated)
- Uninstall Helper.bat (generated)
- START_HERE.bat (generated)
- cmdwallpaper_agent.cs
- cmdwallpaper_agent.csproj
- assets/
- data/.gitkeep
- publish/cmdwallpaper_agent.exe

Excluded:
- data/*.json
- data/*.jpg
- data/*.png
- data/*.log
- data/*.tmp
- .git/
- bin/
- obj/
- audio_probe/
- scripts/
- *.log
- *.tmp
"@

$buildInfo | Out-File -FilePath (Join-Path $PackageDir "BUILD_INFO.txt") -Encoding UTF8
Write-Host "[OK] BUILD_INFO.txt created" -ForegroundColor Green

# ── Done ────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Workshop package created successfully." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package path : $PackageDir" -ForegroundColor Gray
Write-Host "Source path  : $ProjectRoot" -ForegroundColor Gray
Write-Host "Branch       : $gitBranch" -ForegroundColor Gray
Write-Host "Commit       : $gitCommit" -ForegroundColor Gray
Write-Host ""
Write-Host "Import project.json from the package folder into Wallpaper Engine." -ForegroundColor White
