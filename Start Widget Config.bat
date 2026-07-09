@echo off
if not "%1"=="min" start /min "" "%~f0" min & exit
title Widget Engine Bootloader
cd /d "%~dp0"

cd "Main config"
if not exist "node_modules\" (
    npm install
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "dashboard.ps1"