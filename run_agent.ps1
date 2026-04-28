# cmdwallpaper — quick agent launcher (debug convenience)
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentExe = Join-Path $ProjectRoot "publish\cmdwallpaper_agent.exe"

if (-not (Test-Path $AgentExe)) {
    Write-Error "Agent not found: $AgentExe"
    Write-Host "Build: dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 -o publish" -ForegroundColor Yellow
    exit 1
}

# Kill existing agents
Get-Process -Name "cmdwallpaper_agent" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Remove stale PID
$pidFile = Join-Path $ProjectRoot "cmdwallpaper.pid"
if (Test-Path $pidFile) { Remove-Item $pidFile -Force -ErrorAction SilentlyContinue }

Write-Host "Starting agent..." -ForegroundColor Yellow
Write-Host "  Exe: $AgentExe" -ForegroundColor Gray
Write-Host "  Cwd: $ProjectRoot" -ForegroundColor Gray

# Run in foreground (visible terminal) for debugging
& $AgentExe "."
