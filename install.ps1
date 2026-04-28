# cmdwallpaper v0.2.1-agent-hotfix install
$ProjectRoot = $PSScriptRoot
$AgentExe = Join-Path $ProjectRoot "publish\cmdwallpaper_agent.exe"
$DataDir = Join-Path $ProjectRoot "data"
$SmtcFile = Join-Path $DataDir "smtc_data.json"
$LogFile = Join-Path $DataDir "cmdwallpaper_agent.log"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper v0.2.1-agent-hotfix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ProjectRoot: $ProjectRoot" -ForegroundColor Gray
Write-Host ""

# 1. Check agent exe exists
if (-not (Test-Path $AgentExe)) {
    Write-Host "ERROR: Agent not found: $AgentExe" -ForegroundColor Red
    Write-Host "Build it first: dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 -o publish" -ForegroundColor Yellow
    exit 1
}
Write-Host "[1/4] Agent found: $AgentExe" -ForegroundColor Green

# 2. Create data directory
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
    Write-Host "[2/4] data/ created" -ForegroundColor Green
} else {
    Write-Host "[2/4] data/ exists" -ForegroundColor Green
}

# 3. Kill any existing agent process (to avoid stale pid lock)
Write-Host "[3/4] Stopping existing agents..." -ForegroundColor Yellow
Get-Process -Name "cmdwallpaper_agent" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Remove stale PID file
$pidFile = Join-Path $ProjectRoot "cmdwallpaper.pid"
if (Test-Path $pidFile) {
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

# 4. Start agent
Write-Host "[4/4] Starting agent..." -ForegroundColor Yellow
$proc = Start-Process -FilePath $AgentExe `
    -ArgumentList "." `
    -WorkingDirectory $ProjectRoot `
    -WindowStyle Hidden `
    -PassThru

Start-Sleep -Seconds 3

# 5. Verify
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$agentRunning = $false
if (-not $proc.HasExited) {
    $agentRunning = $true
    Write-Host "  Agent process: RUNNING (PID $($proc.Id))" -ForegroundColor Green
} else {
    Write-Host "  Agent process: EXITED (exit code: $($proc.ExitCode))" -ForegroundColor Red
}

if (Test-Path $SmtcFile) {
    $smtcAge = [int]((Get-Date) - (Get-Item $SmtcFile).LastWriteTime).TotalSeconds
    Write-Host "  data/smtc_data.json: OK (updated ${smtcAge}s ago)" -ForegroundColor Green
} else {
    Write-Host "  data/smtc_data.json: NOT FOUND" -ForegroundColor Yellow
    Write-Host "  If this persists, manually run:" -ForegroundColor Yellow
    Write-Host "    cd `"$ProjectRoot`"; .\publish\cmdwallpaper_agent.exe ." -ForegroundColor White
}

if (Test-Path $LogFile) {
    Write-Host "  data/cmdwallpaper_agent.log: OK" -ForegroundColor Green
    Write-Host "  --- last 5 log lines ---" -ForegroundColor Gray
    Get-Content $LogFile -Tail 5 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
} else {
    Write-Host "  data/cmdwallpaper_agent.log: NOT FOUND" -ForegroundColor Yellow
}

# 6. Register auto-start
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Auto-start registration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$startupDir = [Environment]::GetFolderPath("Startup")
$batPath = Join-Path $startupDir "WallpaperSystemInfo.bat"

$batContent = @"
@echo off
cd /d "$ProjectRoot"
wscript.exe "$ProjectRoot\start_service.vbs"
"@

try {
    $batContent | Out-File -FilePath $batPath -Encoding ASCII
    if (Test-Path $batPath) {
        Write-Host "  Startup entry: OK" -ForegroundColor Green
        Write-Host "  $batPath" -ForegroundColor Gray
    }
} catch {
    Write-Host "  WARNING: Could not write startup entry" -ForegroundColor Yellow
    Write-Host "  $_" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($agentRunning) {
    Write-Host "  Install complete!" -ForegroundColor Green
} else {
    Write-Host "  Install complete (agent may need manual start)" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: Wallpaper Engine -> Open from File ->"
Write-Host "  $ProjectRoot\project.json" -ForegroundColor White
