# Wallpaper Engine 系统信息采集服务启动器
# 这个脚本在后台定期更新系统信息

param(
    [int]$UpdateInterval = 2  # 秒
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$getSystemInfoScript = Join-Path $scriptDir "get_system_info.ps1"
$outputFile = Join-Path $scriptDir "system_info.json"

Write-Host "System info updater started"
Write-Host "Update interval: $UpdateInterval sec"
Write-Host "Output: $outputFile"
Write-Host "Press Ctrl+C to stop"
Write-Host ""

$updateCount = 0
$stopRequested = $false

while (-not $stopRequested) {
    try {
        # 直接调用采集脚本（不额外启动 powershell.exe 进程）
        & $getSystemInfoScript -OutputFile $outputFile | Out-Null

        $updateCount++
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] Updated system info #$updateCount"

        Start-Sleep -Seconds $UpdateInterval
    }
    catch [System.Management.Automation.PipelineStoppedException] {
        # Ctrl+C 被按下
        $stopRequested = $true
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Start-Sleep -Seconds $UpdateInterval
    }
}

Write-Host "Service stopped"
