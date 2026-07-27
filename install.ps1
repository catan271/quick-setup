#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

Write-Host "=== Apollo + Tailscale Installer ===" -ForegroundColor Cyan

# ----- Apollo (Sunshine fork) -----
Write-Host "`n--- Installing Apollo ---" -ForegroundColor Yellow

Write-Host "Trying winget..."
$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    winget install ClassicOldSong.Apollo --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Apollo installed via winget"
    } else {
        Write-Host "winget failed, falling back to direct download..."
        & {
            $release = Invoke-RestMethod "https://api.github.com/repos/classicoldsong/apollo/releases/latest" -UseBasicParsing
            $asset = $release.assets | Where-Object { $_.name -match "\.exe$" } | Select-Object -First 1
            if (-not $asset) { throw "No Windows installer found" }
            $installer = "$env:TEMP\$($asset.name)"
            Write-Host "Downloading $($asset.name)..."
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer -UseBasicParsing
            Start-Process -FilePath $installer -ArgumentList "/S" -Wait -NoNewWindow
            Remove-Item $installer -Force
        }
    }
} else {
    Write-Error "winget not found. Install winget first."
}

# ----- Git -----
Write-Host "`n--- Installing Git ---" -ForegroundColor Yellow

if ($winget) {
    winget install Git.Git --accept-package-agreements --accept-source-agreements
} else {
    $git = "$env:TEMP\Git-Installer.exe"
    Invoke-WebRequest "https://github.com/git-for-windows/git/releases/download/v2.50.0.windows.1/Git-2.50.0-64-bit.exe" -OutFile $git -UseBasicParsing
    Start-Process -FilePath $git -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL" -Wait -NoNewWindow
    Remove-Item $git -Force
}

# ----- Tailscale -----
Write-Host "`n--- Installing Tailscale ---" -ForegroundColor Yellow

$ts = "$env:TEMP\tailscale-setup.exe"
Invoke-WebRequest "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" -OutFile $ts -UseBasicParsing
Start-Process -FilePath $ts -ArgumentList "/quiet" -Wait -NoNewWindow
Remove-Item $ts -Force

Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Run 'tailscale up' to connect."
Write-Host "Apollo config: $env:ProgramFiles\Sunshine\config"
Write-Host "Tailscale state: $env:ProgramData\Tailscale"
