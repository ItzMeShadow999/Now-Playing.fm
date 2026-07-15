# Force console environment compatibility 
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$host.ui.RawUI.WindowTitle = "Last-Resort PM2 Repair [ADMIN]"
Clear-Host

$asciiArt = @"
██╗      █████╗ ███████╗████████╗███████╗███╗   ███╗              
██║     ██╔══██╗██╔════╝╚══██╔══╝██╔════╝████╗ ████║              
██║     ███████║███████╗   ██║   █████╗  ██╔████╔██║              
██║     ██╔══██║╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║              
███████╗██║  ██║███████║   ██║██╗██║     ██║ ╚═╝ ██║              
╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝╚═╝╚═╝     ╚═╝     ╚═╝              
                                                                  
██████╗ ███╗   ███╗██████╗     ███████╗██╗██╗  ██╗███████╗██████╗ 
██╔══██╗████╗ ████║╚════██╗    ██╔════╝██║╚██╗██╔╝██╔════╝██╔══██╗
██████╔╝██╔████╔██║ █████╔╝    █████╗  ██║ ╚███╔╝ █████╗  ██████╔╝
██╔═══╝ ██║╚██╔╝██║██╔═══╝     ██╔══╝  ██║ ██╔██╗ ██╔══╝  ██╔══██╗
██║     ██║ ╚═╝ ██║███████╗    ██║     ██║██╔╝ ██╗███████╗██║  ██║
╚═╝     ╚═╝     ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
"@

# Display ANSI UI
Write-Host $asciiArt -ForegroundColor Cyan
Write-Host "`n============================================================" -ForegroundColor DarkGray
Write-Host " STATUS: System detected. Ready to repair PM2 environment." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host "`n[!] ATTENTION: This script will reset PM2 to a global machine-wide state."
Write-Host "[!] This will stop all node processes and reset your PM2 home directory."
Write-Host "`nPress ANY KEY to read the safety warning, or CTRL+C to abort..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Clear-Host
Write-Host $asciiArt -ForegroundColor Cyan
Write-Host "`n[!] DANGER ZONE" -ForegroundColor Red
Write-Host "------------------------------------------------------------"
Write-Host "This is a last-resort tool. It will:"
Write-Host " 1. Stop the Windows PM2 Service."
Write-Host " 2. Force-kill ALL active node.exe instances."
Write-Host " 3. Reset the PM2_HOME variable to C:\pm2."
Write-Host " 4. Re-register your Last.fm-Live sync engine."
Write-Host "------------------------------------------------------------"
$confirm = Read-Host "`nAre you ABSOLUTELY sure you want to proceed? (type 'YES' to continue)"
if ($confirm -ne 'YES') { 
    Write-Host "`nOperation aborted by user." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Exit 
}

# Execution Phase
Write-Host "`n[*] Initiating Repair Protocol..." -ForegroundColor Yellow
Stop-Service -Name "PM2" -ErrorAction SilentlyContinue
taskkill /f /im node.exe /t | Out-Null

Write-Host "[*] Configuring Environment..." -ForegroundColor Yellow
[System.Environment]::SetEnvironmentVariable('PM2_HOME', 'C:\pm2', 'Machine')
if (!(Test-Path "C:\pm2")) { New-Item -Path "C:\pm2" -ItemType Directory | Out-Null }

Write-Host "[*] Registering Process..." -ForegroundColor Yellow
Start-Service -Name "PM2"
cd "C:\Users\user\OneDrive\Documents\Discord\discord Widgets\Last.fm-Live\Main config"
pm2 start sync.js --name "lastfm-sync" --cwd "C:\Users\user\OneDrive\Documents\Discord\discord Widgets\Last.fm-Live\Main config" --force | Out-Null
pm2 save | Out-Null

Write-Host "`n[+] SUCCESS: PM2 has been stabilized." -ForegroundColor Green
Write-Host "[+] All processes should now be online." -ForegroundColor Green