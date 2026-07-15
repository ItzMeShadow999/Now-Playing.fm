@echo off
:: Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: If not admin, elevate
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /b

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    
    :: FORCE the working directory directly to the folder containing this script
    cd /d "%~dp0"
    
    :: Force cmd window into UTF-8 mode for the ANSI text
    chcp 65001 >nul
    
    :: Detect PowerShell 7 (pwsh.exe) and target the relative file directly
    where pwsh >nul 2>nul
    if %errorlevel% equ 0 (
        pwsh.exe -NoProfile -NoExit -ExecutionPolicy Bypass -File ".\Fix-PM2.ps1"
    ) else (
        powershell.exe -NoProfile -NoExit -ExecutionPolicy Bypass -File ".\Fix-PM2.ps1"
    )

    echo.
    echo [!] Script execution finished or interrupted.
    pause