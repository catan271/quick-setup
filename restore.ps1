#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataDir = Join-Path $ScriptDir ".data"

Write-Host "=== Restore Apollo + Tailscale data ===" -ForegroundColor Cyan

# ----- Apollo / Sunshine config -----
$src = Join-Path $DataDir "sunshine-config"
$dest = "$env:ProgramFiles\Sunshine\config"
if (Test-Path $src) {
    Write-Host "Restoring $src -> $dest"
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    robocopy $src $dest /MIR /NP /NDL /NFL /NJH /NJS
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed for sunshine-config" }
} else {
    Write-Host "No sunshine-config backup found at $src — skipping" -ForegroundColor DarkGray
}

# ----- Tailscale state -----
$src = Join-Path $DataDir "tailscale"
$dest = "$env:ProgramData\Tailscale"
if (Test-Path $src) {
    Write-Host "Restoring $src -> $dest"
    Write-Host "Stopping Tailscale service..."
    Stop-Service -Name "Tailscale" -Force -ErrorAction SilentlyContinue

    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    robocopy $src $dest /MIR /NP /NDL /NFL /NJH /NJS
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed for tailscale" }

    Write-Host "Starting Tailscale service..."
    Start-Service -Name "Tailscale" -ErrorAction SilentlyContinue
} else {
    Write-Host "No tailscale backup found at $src — skipping" -ForegroundColor DarkGray
}

Write-Host "`n=== Restore complete ===" -ForegroundColor Green
