# Wallpaper Engine Dynamic System Info - Installation Verification
# Check if all components are in place

$projectPath = $PSScriptRoot
$passCount = 0
$totalCount = 0

Write-Host "Wallpaper Engine Dynamic System Info - Verification" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Check scripts
Write-Host "Checking script files..." -ForegroundColor Blue
$scripts = @(
    "get_system_info.ps1",
    "system_info_updater.ps1",
    "system_info_loader.lua",
    "start_service.vbs"
)

foreach ($script in $scripts) {
    $totalCount++
    $path = Join-Path $projectPath $script
    if (Test-Path $path) {
        Write-Host "[OK] $script" -ForegroundColor Green
        $passCount++
    } else {
        Write-Host "[MISSING] $script" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Checking data files..." -ForegroundColor Blue

# Check system_info.json
$totalCount++
$jsonPath = Join-Path $projectPath "system_info.json"
if (Test-Path $jsonPath) {
    Write-Host "[OK] system_info.json (data file)" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "[TODO] system_info.json (will be generated on first run)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Checking documentation..." -ForegroundColor Blue

$docs = @("README.md", "INTEGRATION_GUIDE.md")
foreach ($doc in $docs) {
    $totalCount++
    $path = Join-Path $projectPath $doc
    if (Test-Path $path) {
        Write-Host "[OK] $doc" -ForegroundColor Green
        $passCount++
    } else {
        Write-Host "[MISSING] $doc" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Results: $passCount/$totalCount components ready" -ForegroundColor Cyan
Write-Host ""

if ($passCount -ge 6) {
    Write-Host "SUCCESS! You are ready to start." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "1. Run: powershell -NoProfile -ExecutionPolicy Bypass -File get_system_info.ps1" -ForegroundColor Yellow
    Write-Host "2. Run: powershell -NoProfile -ExecutionPolicy Bypass -File system_info_updater.ps1" -ForegroundColor Yellow
    Write-Host "3. Follow INTEGRATION_GUIDE.md to set up in Wallpaper Engine" -ForegroundColor Yellow
}

Write-Host ""
