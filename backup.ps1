#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataDir = Join-Path $ScriptDir ".data"

Write-Host "=== Backup Apollo + Tailscale data ===" -ForegroundColor Cyan

$backupJobs = @()

# ----- Apollo / Sunshine config -----
$sunshineConfig = "$env:ProgramFiles\Sunshine\config"
if (Test-Path $sunshineConfig) {
    $dest = Join-Path $DataDir "sunshine-config"
    Write-Host "Backing up $sunshineConfig -> $dest"
    # ponytail: robocopy mirrors dirs, skip timestamp comparison since we want fresh backup each time
    robocopy $sunshineConfig $dest /MIR /NP /NDL /NFL /NJH /NJS
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed for sunshine-config" }
} else {
    Write-Host "Sunshine config not found at $sunshineConfig — skipping" -ForegroundColor DarkGray
}

# ----- Tailscale state -----
$tailscaleData = "$env:ProgramData\Tailscale"
if (Test-Path $tailscaleData) {
    $dest = Join-Path $DataDir "tailscale"
    Write-Host "Backing up $tailscaleData -> $dest"
    robocopy $tailscaleData $dest /MIR /NP /NDL /NFL /NJH /NJS
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed for tailscale" }
} else {
    Write-Host "Tailscale data not found at $tailscaleData — skipping" -ForegroundColor DarkGray
}

Write-Host "`n=== Backup complete -> $DataDir ===" -ForegroundColor Green
