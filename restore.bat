@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run as Administrator.
    pause
    exit /b 1
)

set DATADIR=%~dp0.data

echo === Restore Apollo + Tailscale data ===

:: ----- Apollo / Sunshine config -----
if exist "%DATADIR%\sunshine-config" (
    echo Restoring %DATADIR%\sunshine-config -^> %ProgramFiles%\Sunshine\config
    if not exist "%ProgramFiles%\Sunshine\config" mkdir "%ProgramFiles%\Sunshine\config"
    robocopy "%DATADIR%\sunshine-config" "%ProgramFiles%\Sunshine\config" /MIR /NP /NDL /NFL /NJH /NJS
    if !errorlevel! geq 8 (
        echo robocopy failed for sunshine-config
        pause
        exit /b 1
    )
) else (
    echo No sunshine-config backup found -- skipping
)

:: ----- Tailscale state -----
if exist "%DATADIR%\tailscale" (
    echo Restoring %DATADIR%\tailscale -^> %ProgramData%\Tailscale
    echo Stopping Tailscale service...
    sc stop Tailscale >nul 2>&1
    net stop Tailscale >nul 2>&1

    if not exist "%ProgramData%\Tailscale" mkdir "%ProgramData%\Tailscale"
    robocopy "%DATADIR%\tailscale" "%ProgramData%\Tailscale" /MIR /NP /NDL /NFL /NJH /NJS
    if !errorlevel! geq 8 (
        echo robocopy failed for tailscale
        pause
        exit /b 1
    )

    echo Starting Tailscale service...
    sc start Tailscale >nul 2>&1
    net start Tailscale >nul 2>&1
) else (
    echo No tailscale backup found -- skipping
)

echo.
echo === Restore complete ===
pause
