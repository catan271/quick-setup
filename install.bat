@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run as Administrator.
    pause
    exit /b 1
)

echo === Apollo + Tailscale + Git Installer ===

:: ----- Apollo (Sunshine fork) -----
echo.
echo --- Installing Apollo ---

where winget >nul 2>&1
if %errorlevel% equ 0 (
    echo Trying winget...
    winget install ClassicOldSong.Apollo --accept-package-agreements --accept-source-agreements
    if !errorlevel! equ 0 (
        echo Apollo installed via winget
        goto :install_git
    )
    echo winget failed, falling back to direct download...
)

echo Downloading latest Apollo...
powershell -Command ^
    "$r = Invoke-RestMethod 'https://api.github.com/repos/classicoldsong/apollo/releases/latest' -UseBasicParsing;" ^
    "$a = $r.assets | ? { $_.name -match '\.exe$' } | Select -First 1;" ^
    "if (-not $a) { exit 1 };" ^
    "Invoke-WebRequest $a.browser_download_url -OutFile '%TEMP%\%a.name%' -UseBasicParsing;" ^
    "Write-Output $a.name"
if %errorlevel% neq 0 (
    echo Failed to download Apollo.
    pause
    exit /b 1
)

for /f "delims=" %%f in ('powershell -Command ^
    "$r = Invoke-RestMethod 'https://api.github.com/repos/classicoldsong/apollo/releases/latest' -UseBasicParsing;" ^
    "$a = $r.assets | ? { $_.name -match '\.exe$' } | Select -First 1;" ^
    "Write-Output $a.name"') do set APOLLO_FILE=%%f

"%TEMP%\%APOLLO_FILE%" /S
del /f "%TEMP%\%APOLLO_FILE%" >nul 2>&1

:install_git
:: ----- Git -----
echo.
echo --- Installing Git ---

where winget >nul 2>&1
if %errorlevel% equ 0 (
    winget install Git.Git --accept-package-agreements --accept-source-agreements
) else (
    curl -L -o "%TEMP%\Git-Installer.exe" "https://github.com/git-for-windows/git/releases/download/v2.50.0.windows.1/Git-2.50.0-64-bit.exe"
    if exist "%TEMP%\Git-Installer.exe" (
        "%TEMP%\Git-Installer.exe" /VERYSILENT /NORESTART /NOCANCEL
        del /f "%TEMP%\Git-Installer.exe" >nul 2>&1
    )
)

:: ----- Tailscale -----
echo.
echo --- Installing Tailscale ---

curl -L -o "%TEMP%\tailscale-setup.exe" "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe"
if exist "%TEMP%\tailscale-setup.exe" (
    "%TEMP%\tailscale-setup.exe" /quiet
    del /f "%TEMP%\tailscale-setup.exe" >nul 2>&1
)

echo.
echo === Done ===
echo Run 'tailscale up' to connect.
echo Apollo config: %ProgramFiles%\Sunshine\config
echo Tailscale state: %ProgramData%\Tailscale
pause
