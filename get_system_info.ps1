# System info collector for Wallpaper Engine terminal wallpaper
param([string]$OutputFile = "system_info.json")

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load helper DLL (WASAPI EQ + now-playing)
$dll = Join-Path $scriptDir "media_helper.dll"
if (Test-Path $dll) { try { Add-Type -Path $dll -ErrorAction Stop | Out-Null; [MediaHelper]::StartMeter($scriptDir) } catch {} }

try {
    $info = @{}
    $info["timestamp"] = (Get-Date).ToUniversalTime().ToString("o")
    $info["system"] = @{ "hostname" = [System.Environment]::MachineName; "username" = [System.Environment]::UserName }

    $os = Get-CimInstance Win32_OperatingSystem
    $info["os"] = @{ "name" = $os.Caption; "version" = $os.Version; "build" = $os.BuildNumber; "architecture" = $os.OSArchitecture }
    $t = [math]::Round($os.TotalVisibleMemorySize/1048576, 2); $f = [math]::Round($os.FreePhysicalMemory/1048576, 2); $u = $t-$f
    $info["memory"] = @{ "total_gb"=$t; "used_gb"=$u; "available_gb"=$f; "percent"=[math]::Round($u/$t*100,1) }

    $c = Get-CimInstance Win32_Processor
    $info["cpu"] = @{ "name"=$c.Name.Trim(); "cores"=$c.NumberOfCores; "threads"=$c.NumberOfLogicalProcessors; "frequency_mhz"=$c.MaxClockSpeed }

    $info["gpu"] = @(); foreach ($g in (Get-CimInstance Win32_VideoController)) { $info["gpu"] += $g.Name }

    $info["disk"] = @{}
    Get-Volume | Where-Object { $_.DriveLetter -and $_.SizeRemaining -gt 0 } | ForEach-Object {
        $l=$_.DriveLetter; $ts=[math]::Round($_.Size/1GB,2); $fs=[math]::Round($_.SizeRemaining/1GB,2); $us=$ts-$fs
        $pct=if($ts-gt0){[math]::Round($us/$ts*100,1)}else{0}
        $info["disk"]["${l}:"] = @{ "mount"="${l}:\"; "total_gb"=$ts; "used_gb"=$us; "free_gb"=$fs; "percent"=$pct }
    }

    $mb = Get-CimInstance Win32_BaseBoard; $info["motherboard"] = "$($mb.Manufacturer) $($mb.Product)"

    try {
        $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.AddressState -eq 'Preferred' } |
            Sort-Object -Property { $_.InterfaceMetric -as [int] } | Select-Object -First 1
        if ($ip) { $info["network"] = @{ "ipv4"=$ip.IPAddress; "interface"=$ip.InterfaceAlias } }
    } catch {}

    # Audio EQ from WASAPI loopback
    try {
        $muted=$false; $vol=[MediaHelper]::GetMasterVolume([ref]$muted)
        $info["audio"]=@{ "volume"=$vol; "muted"=$muted; "eq_bass"=[math]::Round([MediaHelper]::GetEQBass(),1); "eq_mid"=[math]::Round([MediaHelper]::GetEQMid(),1); "eq_treble"=[math]::Round([MediaHelper]::GetEQTreble(),1) }
    } catch {}

    # Now playing - read from SMTC background EXE (always fresh, no cold start)
    $np = @{ "status"="no_media" }
    $smtcFile = Join-Path $scriptDir "smtc_data.json"
    try {
        if (Test-Path $smtcFile) {
            $smtc = Get-Content $smtcFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($smtc.status -eq "playing" -and $smtc.title) {
                $np["status"] = "playing"
                $np["title"] = $smtc.title
                if ($smtc.artist) { $np["artist"] = $smtc.artist }
                if ($smtc.album)  { $np["album_title"] = $smtc.album }
                if ($smtc.pos -gt 0) { $np["position_seconds"] = [double]$smtc.pos }
                if ($smtc.dur -gt 0)  { $np["duration_seconds"] = [double]$smtc.dur }
            }
        }
    } catch {}
    # Fallback to window titles
    if ($np["status"] -ne "playing") {
        $title=$null; $artist=$null; $album=$null
        $src = [MediaHelper]::GetNowPlaying([ref]$title, [ref]$artist, [ref]$album)
        if ($src) { $np = @{ "status"="playing"; "title"=$title; "artist"=$artist; "album_title"=$album; "source"=$src } }
    }
    $info["now_playing"] = $np

    $json = $info | ConvertTo-Json -Depth 10
    $tmp = $OutputFile + ".tmp"
    $utf8 = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($tmp, $json, $utf8)
    Move-Item -Path $tmp -Destination $OutputFile -Force
    Write-Host "OK - $OutputFile"
} catch { Write-Host "Error: $_"; exit 1 }
