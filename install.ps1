# cmdwallpaper v0.3.0 install
$ProjectRoot = $PSScriptRoot
$AgentExe = Join-Path $ProjectRoot "publish\cmdwallpaper_agent.exe"
$DataDir = Join-Path $ProjectRoot "data"
$PidFile = Join-Path $ProjectRoot "cmdwallpaper.pid"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper v0.3.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ProjectRoot: $ProjectRoot" -ForegroundColor Gray
Write-Host ""

# ── 1. Check agent exe ──────────────────────────────────
if (-not (Test-Path $AgentExe)) {
    Write-Host "ERROR: Agent not found:" -ForegroundColor Red
    Write-Host "  $AgentExe" -ForegroundColor Red
    Write-Host ""
    Write-Host "For development, run:" -ForegroundColor Yellow
    Write-Host "  dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 -o publish" -ForegroundColor White
    exit 1
}
Write-Host "[1/5] Agent: $AgentExe" -ForegroundColor Green

# ── 2. Create data/ ─────────────────────────────────────
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
    Write-Host "[2/5] data/ created" -ForegroundColor Green
} else {
    Write-Host "[2/5] data/ exists" -ForegroundColor Green
}

# ── 3. Check if already running (same project root) ─────
Write-Host "[3/5] Checking agent status..." -ForegroundColor Yellow
$alreadyRunning = $false
$existingPid = $null

# Check by PID file
if (Test-Path $PidFile) {
    try {
        $existingPid = [int](Get-Content $PidFile -Raw).Trim()
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$existingPid" -ErrorAction SilentlyContinue
        if ($proc) {
            $exePath = $proc.ExecutablePath
            if ($exePath -and ($exePath -eq $AgentExe -or $exePath -like "*$ProjectRoot*")) {
                $alreadyRunning = $true
            }
        }
    } catch { }
}

# Also check by process name as fallback
if (-not $alreadyRunning) {
    $procs = Get-CimInstance Win32_Process -Filter "Name='cmdwallpaper_agent.exe'" -ErrorAction SilentlyContinue
    foreach ($p in $procs) {
        $exePath = $p.ExecutablePath
        if ($exePath -and ($exePath -eq $AgentExe -or $exePath -like "*$ProjectRoot*")) {
            $alreadyRunning = $true
            $existingPid = $p.ProcessId
            break
        }
    }
}

if ($alreadyRunning) {
    Write-Host "  Agent is already running (PID $existingPid)" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Already installed." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Project root : $ProjectRoot" -ForegroundColor Gray
    Write-Host "Agent        : $AgentExe" -ForegroundColor Gray
    Write-Host "Data folder  : $DataDir" -ForegroundColor Gray
    exit 0
}

# ── 4. Start agent ──────────────────────────────────────
Write-Host "[4/5] Starting agent..." -ForegroundColor Yellow
$proc = Start-Process -FilePath $AgentExe `
    -ArgumentList "." `
    -WorkingDirectory $ProjectRoot `
    -WindowStyle Hidden `
    -PassThru

Start-Sleep -Seconds 3

# ── 5. Verify ───────────────────────────────────────────
$agentRunning = (-not $proc.HasExited)
$sysInfoFile = Join-Path $DataDir "system_info.json"
$logFile = Join-Path $DataDir "cmdwallpaper_agent.log"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($agentRunning) {
    Write-Host "  Agent: RUNNING (PID $($proc.Id))" -ForegroundColor Green
} else {
    Write-Host "  Agent: EXITED (code $($proc.ExitCode))" -ForegroundColor Red
}

if (Test-Path $sysInfoFile) {
    Write-Host "  data/system_info.json: OK" -ForegroundColor Green
} else {
    Write-Host "  data/system_info.json: not found (may need a few seconds)" -ForegroundColor Yellow
}

if (Test-Path $logFile) {
    Write-Host "  data/cmdwallpaper_agent.log: OK" -ForegroundColor Green
    if ($agentRunning) {
        Write-Host "  --- last 3 log lines ---" -ForegroundColor Gray
        Get-Content $logFile -Tail 3 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    }
}

# ── 6. Register auto-start ──────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Auto-start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$startupDir = [Environment]::GetFolderPath("Startup")
$batPath = Join-Path $startupDir "WallpaperSystemInfo.bat"
$vbsPath = Join-Path $ProjectRoot "start_service.vbs"

$batContent = "@echo off`r`ncd /d `"$ProjectRoot`"`r`nwscript.exe `"$vbsPath`""

try {
    # Remove old entry if it exists (to avoid duplicates)
    if (Test-Path $batPath) { Remove-Item $batPath -Force -ErrorAction SilentlyContinue }
    $batContent | Out-File -FilePath $batPath -Encoding ASCII -Force
    if (Test-Path $batPath) {
        Write-Host "  Startup entry: OK" -ForegroundColor Green
    } else {
        Write-Host "  Startup entry: FAILED to write" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARNING: Could not write startup entry" -ForegroundColor Yellow
    Write-Host "  $_" -ForegroundColor Gray
}

# ── Done ────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($agentRunning) {
    Write-Host "  CMD Wallpaper helper installed." -ForegroundColor Green
} else {
    Write-Host "  Install done (agent may need manual start)." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project root : $ProjectRoot" -ForegroundColor Gray
Write-Host "Agent        : $AgentExe" -ForegroundColor Gray
Write-Host "Data folder  : $DataDir" -ForegroundColor Gray
Write-Host "Startup entry: $batPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Restart Wallpaper Engine or reload the wallpaper." -ForegroundColor White
