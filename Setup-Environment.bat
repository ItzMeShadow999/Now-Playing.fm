@echo off
title Environment Setup Engine
echo Checking for system dependencies...

:: Check for Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] Node.js not found. Please download and install it from https://nodejs.org/
    pause
    exit /b
) else (
    echo [+] Node.js detected.
)

:: Check for PM2
where pm2 >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] PM2 not found. Installing globally...
    call npm install -g pm2
    if %errorlevel% neq 0 (
        echo [X] Failed to install PM2. Please run CMD as Administrator.
        pause
        exit /b
    )
    echo [+] PM2 installed successfully.
) else (
    echo [+] PM2 detected.
)

echo.
echo All requirements satisfied. You are ready to run the widget.
pause
