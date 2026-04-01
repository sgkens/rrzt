#!/usr/bin/env pwsh
# /opt/mediastack/verify.ps1

$ErrorActionPreference = "Continue"

# ==========================================
# 1. TUI FOUNDATION
# ==========================================
$Palette = @{
    Primary   = "`e[38;5;153m"
    Secondary = "`e[38;5;150m"
    Accent    = "`e[38;5;183m"
    Warning   = "`e[38;5;222m"
    Error     = "`e[38;5;211m"
    Text      = "`e[38;5;253m"
    Reset     = "`e[0m"
}

$UI = @{
    TopLeft     = "┌"; TopRight    = "┐"
    BottomLeft  = "└"; BottomRight = "┘"
    Horizontal  = "─"; Vertical    = "│"
    DividerLeft = "├"; DividerRight= "┤"
    Width       = 80
}

function Get-PaddedString { param ([string]$RawText, [int]$TargetWidth); return $RawText.PadRight($TargetWidth) }

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

function Write-TuiCheck {
    param ([string]$Item, [bool]$Status, [string]$Detail = "")
    $AvailableWidth = $UI.Width - 4
    
    $StateObj = if ($Status) { @{ Text = "[ OK ]"; Color = $Palette.Secondary } } else { @{ Text = "[FAIL]"; Color = $Palette.Error } }
    $Constructed = "$($StateObj.Text) $Item $Detail"
    
    $PaddingLength = $AvailableWidth - $Constructed.Length
    if ($PaddingLength -lt 0) { $PaddingLength = 0 }
    $Padding = " " * $PaddingLength

    $FormattedLine = "$($StateObj.Color)$($StateObj.Text)$($Palette.Reset) $($Palette.Text)$Item$($Palette.Reset) $($Palette.Warning)$Detail$($Palette.Reset)$Padding"
    Write-Host "$($Palette.Primary)$($UI.Vertical) $FormattedLine $($Palette.Primary)$($UI.Vertical)$($Palette.Reset)"
}

# ==========================================
# 2. MANIFEST DEFINITIONS
# ==========================================
$BaseDir = "/opt/mediastack"
$RequiredFiles = @(
    ".env",
    "docker-compose.yml",
    "libraries.json",
    "init-stack.sh",
    "backup-stack.sh",
    "Set-MediaVolumes.ps1",
    "Test-ContainerPaths.ps1",
    "config/traefik/acme.json",
    "config/prometheus/prometheus.yml",
    "config/grafana/provisioning/datasources/prometheus.yaml",
    "config/grafana/provisioning/dashboards/dashboards.yaml",
    "config/recyclarr/recyclarr.yml",
    "config/homepage/services.yaml",
    "config/homepage/widgets.yaml"
)

# ==========================================
# 3. VERIFICATION EXECUTION
# ==========================================
Clear-Host
Write-TuiBorder -Type "Top"
Write-TuiLine -Text " MEDIASTACK INFRASTRUCTURE VALIDATION " -Color $Palette.Accent
Write-TuiBorder -Type "Divider"

$Errors = 0

foreach ($File in $RequiredFiles) {
    $FullPath = Join-Path $BaseDir $File
    $FileExists = Test-Path $FullPath
    
    if (-not $FileExists) {
        Write-TuiCheck -Item $File -Status $false -Detail "Missing"
        $Errors++
        continue
    }

    # Format specific validation
    if ($File.EndsWith(".json")) {
        try {
            Get-Content $FullPath -Raw | ConvertFrom-Json | Out-Null
            Write-TuiCheck -Item $File -Status $true -Detail "(Valid JSON)"
        } catch {
            Write-TuiCheck -Item $File -Status $false -Detail "(Invalid JSON Syntax)"
            $Errors++
        }
    } elseif ($File.EndsWith(".yml") -or $File.EndsWith(".yaml")) {
        # Basic emptiness/accessibility check for YAML (pure dependency-free validation)
        if ((Get-Item $FullPath).Length -gt 0) {
            Write-TuiCheck -Item $File -Status $true -Detail "(YAML Accessible)"
        } else {
            Write-TuiCheck -Item $File -Status $false -Detail "(YAML Empty)"
            $Errors++
        }
    } else {
        Write-TuiCheck -Item $File -Status $true
    }
}

Write-TuiBorder -Type "Divider"
if ($Errors -eq 0) {
    Write-TuiLine -Text "STATUS: PASSED - Infrastructure is ready for deployment." -Color $Palette.Secondary
} else {
    Write-TuiLine -Text "STATUS: FAILED - $Errors validation errors detected." -Color $Palette.Error
}
Write-TuiBorder -Type "Bottom"

if ($Errors -gt 0) { exit 1 }