# =============================================================================
# Hyber Alias Installer
# Cross-platform shell alias manager
# https://github.com/thinhngotony/alias
# =============================================================================

$ErrorActionPreference = "Stop"

# Fetch latest version from GitHub releases
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/thinhngotony/alias/releases/latest" -TimeoutSec 5
    $Version = $release.tag_name -replace '^v', ''
    if ($Version -notmatch '^\d+\.\d+\.\d+$') {
        throw "Invalid release tag"
    }
} catch {
    throw "Failed to determine the latest release; existing aliases were not changed: $_"
}
$Repo = "https://raw.githubusercontent.com/thinhngotony/alias/v$Version"
$AliasHome = "$env:USERPROFILE\.alias"

# Check execution policy (skip in CI environments)
if (-not $env:SKIP_POLICY_CHECK) {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
        Write-Host ""
        Write-Host "Execution policy is restricted. Updating..." -ForegroundColor Yellow
        try {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "Policy updated" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Could not set execution policy." -ForegroundColor Red
            Write-Host "Run as Administrator: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Red
            exit 1
        }
    }
}

# Header
Write-Host ""
Write-Host "Hyber Alias" -ForegroundColor White -NoNewline
Write-Host " v$Version" -ForegroundColor DarkGray
Write-Host "Cross-platform shell alias manager" -ForegroundColor DarkGray
Write-Host ""

# System info
Write-Host "System" -ForegroundColor DarkGray
Write-Host "  OS         " -NoNewline; Write-Host "windows" -ForegroundColor White
Write-Host "  Shell      " -NoNewline; Write-Host "powershell" -ForegroundColor White
Write-Host "  Config     " -NoNewline; Write-Host "$PROFILE" -ForegroundColor DarkGray
Write-Host ""

# Install
Write-Host "Installing" -ForegroundColor DarkGray

# Create directories
New-Item -ItemType Directory -Force -Path $AliasHome | Out-Null
New-Item -ItemType Directory -Force -Path "$AliasHome\custom" | Out-Null
Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Created ~/.alias" -ForegroundColor DarkGray

# Download files using temp file for atomicity
try {
    $tmpFile = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -Uri "$Repo/load.ps1" -OutFile $tmpFile -UseBasicParsing -TimeoutSec 30
    if ((Get-Item $tmpFile).Length -gt 0) {
        Move-Item $tmpFile "$AliasHome\load.ps1" -Force
    } else {
        throw "Downloaded file is empty"
    }
    Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Downloaded aliases"
} catch {
    Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
    Write-Host "  " -NoNewline; Write-Host "✗" -ForegroundColor Red -NoNewline; Write-Host " Failed to download loader"
    exit 1
}

# Configure shell
$ProfileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
}
if (!(Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($null -eq $ProfileContent -or $ProfileContent -notmatch "\.alias\\load\.ps1") {
    Add-Content -Path $PROFILE -Value "`n# Hyber Alias - https://github.com/thinhngotony/alias"
    Add-Content -Path $PROFILE -Value "if (Test-Path `"$AliasHome\load.ps1`") { . `"$AliasHome\load.ps1`" }"
    Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Configured $PROFILE" -ForegroundColor DarkGray
} else {
    Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Already configured"
}

# Save the version only after the complete loader has been installed.
$envTmp = Join-Path $AliasHome ("env.ps1." + [guid]::NewGuid().ToString("N"))
@"
`$env:HYBER_SHELL = "powershell"
`$env:HYBER_OS = "windows"
`$env:HYBER_VERSION = "$Version"
"@ | Out-File -FilePath $envTmp -Encoding UTF8
Move-Item $envTmp "$AliasHome\env.ps1" -Force
Remove-Item "$AliasHome\.update-available" -Force -ErrorAction SilentlyContinue
[System.IO.File]::WriteAllText("$AliasHome\.update-check", "")
Write-Host "  " -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host " Saved environment"

Write-Host ""

# Success
Write-Host "Installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  → Run this command to activate aliases:" -ForegroundColor Cyan
Write-Host ""
Write-Host "      . $PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "  → Or open a new PowerShell window" -ForegroundColor Cyan
Write-Host ""
Write-Host "Quick start" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  alias-help     " -ForegroundColor Cyan -NoNewline; Write-Host "Show all available aliases"
Write-Host "  alias-git      " -ForegroundColor Cyan -NoNewline; Write-Host "Git shortcuts (ga, gcm, gs...)"
Write-Host "  alias-k8s      " -ForegroundColor Cyan -NoNewline; Write-Host "Kubernetes shortcuts (k, kgp...)"
Write-Host "  alias-add      " -ForegroundColor Cyan -NoNewline; Write-Host "Add custom aliases to categories"
Write-Host ""
Write-Host "Documentation  " -ForegroundColor DarkGray -NoNewline; Write-Host "https://github.com/thinhngotony/alias"
Write-Host ""
