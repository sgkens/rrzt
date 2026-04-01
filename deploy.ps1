#!/usr/bin/env pwsh
# /opt/mediastack/deploy.ps1

$ErrorActionPreference = "Stop"

# ==========================================
# 1. TUI FOUNDATION: PALETTE & UI OBJECTS
# ==========================================
$Palette = @{
    Primary   = "`e[38;5;153m" # Pastel Blue
    Secondary = "`e[38;5;150m" # Pastel Green
    Accent    = "`e[38;5;183m" # Pastel Purple
    Warning   = "`e[38;5;222m" # Pastel Yellow
    Error     = "`e[38;5;211m" # Pastel Pink
    Text      = "`e[38;5;253m" # Soft White
    Reset     = "`e[0m"
}

$UI = @{
    TopLeft      = "┌"
    TopRight     = "┐"
    BottomLeft   = "└"
    BottomRight  = "┘"
    Horizontal   = "─"
    Vertical     = "│"
    DividerLeft  = "├"
    DividerRight = "┤"
    Cross        = "┼"
    Width        = 80
}

# ==========================================
# 2. TUI RENDER FUNCTIONS
# ==========================================
function Get-PaddedString {
    param ([string]$RawText, [int]$TargetWidth)
    # Calculate padding before ASCII encoding to prevent terminal tearing
    return $RawText.PadRight($TargetWidth)
}

function Write-TuiBorder {
    param ([string]$Type)
    $Line = $UI.Horizontal * ($UI.Width - 2)
    if ($Type -eq "Top") { Write-Host "$($Palette.Primary)$($UI.TopLeft)$Line$($UI.TopRight)$($Palette.Reset)" }
    if ($Type -eq "Bottom") { Write-Host "$($Palette.Primary)$($UI.BottomLeft)$Line$($UI.BottomRight)$($Palette.Reset)" }
    if ($Type -eq "Divider") { Write-Host "$($Palette.Primary)$($UI.DividerLeft)$Line$($UI.DividerRight)$($Palette.Reset)" }
}

function Write-TuiLine {
    param ([string]$Text, [string]$Color = $Palette.Text)
    $AvailableWidth = $UI.Width - 4
    $Padded = Get-PaddedString -RawText $Text -TargetWidth $AvailableWidth
    Write-Host "$($Palette.Primary)$($UI.Vertical) $($Color)$Padded$($Palette.Reset) $($Palette.Primary)$($UI.Vertical)$($Palette.Reset)"
}

function Write-TuiKeyValue {
    param ([string]$Key, [string]$Value, [string]$ValueColor = $Palette.Secondary)
    $AvailableWidth = $UI.Width - 4
    $ConstructedString = "$Key: $Value"
    
    # Calculate padding on raw string
    $PaddingLength = $AvailableWidth - $ConstructedString.Length
    if ($PaddingLength -lt 0) { $PaddingLength = 0 }
    $Padding = " " * $PaddingLength

    # Apply ANSI encapsulation post-padding
    $FormattedLine = "$($Palette.Accent)$Key:$($Palette.Reset) $($ValueColor)$Value$($Palette.Reset)$Padding"
    Write-Host "$($Palette.Primary)$($UI.Vertical) $FormattedLine $($Palette.Primary)$($UI.Vertical)$($Palette.Reset)"
}

# ==========================================
# 3. HEADER ASCII ART
# ==========================================
Clear-Host
Write-TuiBorder -Type "Top"
Write-TuiLine -Text "  __  __          _ _        _____ _             _    " -Color $Palette.Accent
Write-TuiLine -Text " |  \/  |        | (_)      / ____| |           | |   " -Color $Palette.Accent
Write-TuiLine -Text " | \  / | ___  __| |_  __ _| (___ | |_ __ _  ___| | __" -Color $Palette.Accent
Write-TuiLine -Text " | |\/| |/ _ \/ _\` | |/ _\` |\___ \| __/ _\` |/ __| |/ /" -Color $Palette.Accent
Write-TuiLine -Text " | |  | |  __/ (_| | | (_| |____) | || (_| | (__|   < " -Color $Palette.Accent
Write-TuiLine -Text " |_|  |_|\___|\__,_|_|\__,_|_____/ \__\__,_|\___|_|\_\" -Color $Palette.Accent
Write-TuiLine -Text "                                                      "
Write-TuiLine -Text " MEDIASTACK v1.1.0 - ZERO-TOUCH DEPLOYMENT ENGINE     " -Color $Palette.Primary
Write-TuiBorder -Type "Divider"

# ==========================================
# 4. DEPLOYMENT EXECUTION PIPELINE
# ==========================================
Write-TuiLine -Text "[1/4] Compiling Storage Volumes..." -Color $Palette.Text
try {
    pwsh /opt/mediastack/Set-MediaVolumes.ps1 | Out-Null
    Write-TuiLine -Text "      Target: docker-compose.override.yml generated." -Color $Palette.Secondary
}
catch {
    Write-TuiLine -Text "      Failed compiling media volumes." -Color $Palette.Error
    Write-TuiBorder -Type "Bottom"
    exit 1
}

Write-TuiBorder -Type "Divider"
Write-TuiLine -Text "[2/4] Initializing Docker Engine State..." -Color $Palette.Text
try {
    # Request profile plex as baseline, scale dependents to 0
    docker compose --profile plex up -d --scale recyclarr=0 --scale homepage=0 --scale unpackerr=0 2>&1 | Out-Null
    Write-TuiLine -Text "      Target: Base infrastructure active." -Color $Palette.Secondary
}
catch {
    Write-TuiLine -Text "      Docker daemon rejected compose payload." -Color $Palette.Error
    Write-TuiBorder -Type "Bottom"
    exit 1
}

Write-TuiBorder -Type "Divider"
Write-TuiLine -Text "[3/4] Executing API Orchestrator..." -Color $Palette.Text
try {
    bash /opt/mediastack/init-stack.sh > /dev/null 2>&1
    Write-TuiLine -Text "      Target: All internal APIs linked." -Color $Palette.Secondary
}
catch {
    Write-TuiLine -Text "      API Orchestration encountered an error." -Color $Palette.Error
    Write-TuiBorder -Type "Bottom"
    exit 1
}

Write-TuiBorder -Type "Divider"
Write-TuiLine -Text "[4/4] Validating Storage Mounts..." -Color $Palette.Text
try {
    pwsh /opt/mediastack/Test-ContainerPaths.ps1 | Out-Null
    Write-TuiLine -Text "      Target: *Arr filesystem access verified." -Color $Palette.Secondary
}
catch {
    Write-TuiLine -Text "      Storage validation failed." -Color $Palette.Error
    Write-TuiBorder -Type "Bottom"
    exit 1
}

# ==========================================
# 5. CONFIGURATION SUMMARY
# ==========================================
Write-TuiBorder -Type "Divider"
Write-TuiLine -Text "DEPLOYMENT SUMMARY" -Color $Palette.Accent

$EnvMap = @{}
Get-Content /opt/mediastack/.env | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $Split = $_.Split('=', 2)
    $EnvMap[$Split[0]] = $Split[1].Trim()
}

Write-TuiKeyValue -Key "Domain Name" -Value $EnvMap["DOMAIN_NAME"]
Write-TuiKeyValue -Key "Host IP" -Value $EnvMap["HOST_IP"]
Write-TuiKeyValue -Key "VPN Provider" -Value $EnvMap["VPN_PROVIDER"]
Write-TuiKeyValue -Key "Dashboard" -Value "https://home.$($EnvMap["DOMAIN_NAME"])"

$ApiCount = ($EnvMap.Keys | Where-Object { $_ -match "_API_KEY" -and -not [string]::IsNullOrWhiteSpace($EnvMap[$_]) }).Count
Write-TuiKeyValue -Key "Generated API Keys" -Value "$ApiCount / 7 extracted successfully"

Write-TuiBorder -Type "Bottom"