# cmdwallpaper — Build agent helper
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$PublishDir = Join-Path $ProjectRoot "publish"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  cmdwallpaper Agent Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Project root : $ProjectRoot" -ForegroundColor Gray
Write-Host "Publish dir  : $PublishDir" -ForegroundColor Gray
Write-Host ""

# ── Clean old publish dir ─────────────────────────────────
if (Test-Path $PublishDir) {
    Remove-Item $PublishDir -Recurse -Force -ErrorAction Stop
    Write-Host "[OK] Removed old publish/" -ForegroundColor Green
}

# ── Build ─────────────────────────────────────────────────
Write-Host "Building self-contained agent..." -ForegroundColor Yellow
Write-Host ""

Push-Location $ProjectRoot
try {
    dotnet publish cmdwallpaper_agent.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o publish
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: dotnet publish failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host ""

# ── Verify output ─────────────────────────────────────────
$AgentExe = Join-Path $PublishDir "cmdwallpaper_agent.exe"
if (Test-Path $AgentExe) {
    $size = (Get-Item $AgentExe).Length
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "[OK] Build succeeded" -ForegroundColor Green
    Write-Host "  Path : $AgentExe" -ForegroundColor Gray
    Write-Host "  Size : $size bytes ($sizeMB MB)" -ForegroundColor Gray
} else {
    Write-Host "ERROR: $AgentExe not found after build" -ForegroundColor Red
    exit 1
}
