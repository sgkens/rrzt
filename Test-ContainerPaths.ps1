#!/usr/bin/env pwsh
# /opt/mediastack/Test-ContainerPaths.ps1
$ErrorActionPreference = "Stop"
$EnvFile = "/opt/mediastack/.env"
$LibrariesFile = "/opt/mediastack/libraries.json"

$EnvVars = @{}
Get-Content $EnvFile | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $Split = $_.Split('=', 2)
    $EnvVars[$Split[0]] = $Split[1].Trim()
}

$Libraries = Get-Content $LibrariesFile -Raw | ConvertFrom-Json

Write-Host "[INFO] Commencing container filesystem verification..."
foreach ($Lib in $Libraries) {
    if ("radarr" -in $Lib.Tags -and -not [string]::IsNullOrWhiteSpace($EnvVars["RADARR_API_KEY"])) {
        try { Invoke-RestMethod -Uri "http://localhost:7878/api/v3/filesystem?path=$($Lib.Target)" -Headers @{"X-Api-Key" = $EnvVars["RADARR_API_KEY"] } -ErrorAction Stop | Out-Null; Write-Host "[SUCCESS] Radarr verified $($Lib.Target)" } catch { Write-Host "[ERROR] Radarr access failed for $($Lib.Target)" }
    }
    if ("sonarr" -in $Lib.Tags -and -not [string]::IsNullOrWhiteSpace($EnvVars["SONARR_API_KEY"])) {
        try { Invoke-RestMethod -Uri "http://localhost:8989/api/v3/filesystem?path=$($Lib.Target)" -Headers @{"X-Api-Key" = $EnvVars["SONARR_API_KEY"] } -ErrorAction Stop | Out-Null; Write-Host "[SUCCESS] Sonarr verified $($Lib.Target)" } catch { Write-Host "[ERROR] Sonarr access failed for $($Lib.Target)" }
    }
}