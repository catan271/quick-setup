@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run as Administrator.
    pause
    exit /b 1
)

set DATADIR=%~dp0.data

echo === Backup Apollo + Tailscale data ===

:: ----- Apollo / Sunshine config -----
if exist "%ProgramFiles%\Sunshine\config" (
    echo Backing up %ProgramFiles%\Sunshine\config -^> %DATADIR%\sunshine-config
    robocopy "%ProgramFiles%\Sunshine\config" "%DATADIR%\sunshine-config" /MIR /NP /NDL /NFL /NJH /NJS
    if !errorlevel! geq 8 (
        echo robocopy failed for sunshine-config
        pause
        exit /b 1
    )
) else (
    echo Sunshine config not found -- skipping
)

:: ----- Tailscale state -----
if exist "%ProgramData%\Tailscale" (
    echo Backing up %ProgramData%\Tailscale -^> %DATADIR%\tailscale
    robocopy "%ProgramData%\Tailscale" "%DATADIR%\tailscale" /MIR /NP /NDL /NFL /NJH /NJS
    if !errorlevel! geq 8 (
        echo robocopy failed for tailscale
        pause
        exit /b 1
    )
) else (
    echo Tailscale data not found -- skipping
)

echo.
echo === Backup complete -^> %DATADIR% ===
pause
