Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ParentDir = Split-Path $PSScriptRoot -Parent
$ConfigDir = Join-Path $ParentDir "Main config"
$IconsDir = Join-Path $ParentDir "Icons"
$EnvFilePath = Join-Path $ConfigDir ".env"
$ScriptPath = Join-Path $ConfigDir "sync.js"
$IconPath = Join-Path $IconsDir "last.fm.ico"

if (-not (Test-Path $EnvFilePath)) {
    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }
    $TemplateContent = @(
        "LASTFM_USERNAME=`"`"",
        "LASTFM_API_KEY=`"`"",
        "DISCORD_BOT_TOKEN=`"`"",
        "APPLICATION_ID=`"`"",
        "DISCORD_USER_ID=`"`""
    )
    $TemplateContent | Out-File $EnvFilePath -Encoding utf8
}

function Get-EnvValue($key) {
    if (Test-Path $EnvFilePath) {
        $line = Get-Content $EnvFilePath | Where-Object { $_ -match "^$key=" }
        if ($line) { return ($line -split '=', 2)[1].Trim('"').Trim("'") }
    }
    return ""
}

function Save-EnvFile {
    $content = @(
        "LASTFM_USERNAME=`"$($txtUser.Text)`"",
        "LASTFM_API_KEY=`"$($txtApiKey.Text)`"",
        "DISCORD_BOT_TOKEN=`"$($txtBotToken.Text)`"",
        "APPLICATION_ID=`"$($txtAppId.Text)`"",
        "DISCORD_USER_ID=`"$($txtUserId.Text)`""
    )
    $content | Out-File $EnvFilePath -Encoding utf8
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Last.fm x Discord Sync Manager"
$form.Size = New-Object System.Drawing.Size(500, 590)
$form.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.StartPosition = "CenterScreen"

if (Test-Path $IconPath) {
    try { $form.Icon = New-Object System.Drawing.Icon($IconPath) } catch {}
}

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Size = New-Object System.Drawing.Size(500, 70)
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(213, 16, 7)
$form.Controls.Add($pnlHeader)

if (Test-Path $IconPath) {
    try {
        $pbLogo = New-Object System.Windows.Forms.PictureBox
        $pbLogo.Size = New-Object System.Drawing.Size(32, 32)
        $pbLogo.Location = New-Object System.Drawing.Point(20, 19)
        $pbLogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
        $pbLogo.Image = (New-Object System.Drawing.Icon($IconPath)).ToBitmap()
        $pnlHeader.Controls.Add($pbLogo)
    } catch {}
}

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "last.fm sync"
$lblTitle.Font = New-Object System.Drawing.Font("Arial Black", 20, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::White
$lblTitle.Location = New-Object System.Drawing.Point(62, 14)
$lblTitle.AutoSize = $true
$pnlHeader.Controls.Add($lblTitle)

$global:currentY = 90

function Add-InputField($labelText, $defaultValue) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $labelText.ToUpper()
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(185, 185, 185)
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(25, $global:currentY)
    $lbl.AutoSize = $true
    $form.Controls.Add($lbl)
    
    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Text = $defaultValue
    $txt.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $txt.ForeColor = [System.Drawing.Color]::White
    $txt.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $txt.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $txt.Location = New-Object System.Drawing.Point(25, ($global:currentY + 22))
    $txt.Size = New-Object System.Drawing.Size(430, 25)
    $form.Controls.Add($txt)
    
    $global:currentY += 65
    return $txt
}

$txtUser     = Add-InputField "LAST.FM USERNAME" (Get-EnvValue "LASTFM_USERNAME")
$txtApiKey   = Add-InputField "LAST.FM API KEY" (Get-EnvValue "LASTFM_API_KEY")
$txtBotToken = Add-InputField "DISCORD BOT TOKEN" (Get-EnvValue "DISCORD_BOT_TOKEN")
$txtAppId    = Add-InputField "APPLICATION ID" (Get-EnvValue "APPLICATION_ID")
$txtUserId   = Add-InputField "DISCORD USER ID" (Get-EnvValue "DISCORD_USER_ID")

$lblStatusInfo = New-Object System.Windows.Forms.Label
$lblStatusInfo.Text = "Note: This widget utilizes PM2 to manage continuous background execution and live auto-updates for your profile status."
$lblStatusInfo.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 140)
$lblStatusInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$lblStatusInfo.Location = New-Object System.Drawing.Point(25, $global:currentY)
$lblStatusInfo.Size = New-Object System.Drawing.Size(430, 35)
$form.Controls.Add($lblStatusInfo)

$global:currentY += 40

$btnSync = New-Object System.Windows.Forms.Button
$btnSync.Text = "DEPLOY TO PM2 BACKGROUND PROCESS"
$btnSync.BackColor = [System.Drawing.Color]::FromArgb(213, 16, 7)
$btnSync.ForeColor = [System.Drawing.Color]::White
$btnSync.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnSync.FlatAppearance.BorderSize = 0
$btnSync.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnSync.Location = New-Object System.Drawing.Point(25, $global:currentY)
$btnSync.Size = New-Object System.Drawing.Size(430, 45)
$form.Controls.Add($btnSync)

$btnSync.Add_Click({
    Save-EnvFile
    
    if (-not (Test-Path $ScriptPath)) {
        [System.Windows.Forms.MessageBox]::Show("Could not find your Node script ($ScriptPath) in this directory!", "Execution Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    if (Get-Command pm2 -ErrorAction SilentlyContinue) {
        # Updated line with --cwd flag to point PM2 to the config folder
        Start-Process cmd -ArgumentList "/c pm2 start `"$ScriptPath`" --name `"lastfm-discord-sync`" --cwd `"$ConfigDir`"" -NoNewWindow
        Start-Process cmd -ArgumentList "/c pm2 logs `"lastfm-discord-sync`""
        [System.Windows.Forms.MessageBox]::Show("Pipeline successfully deployed under permanent PM2 process runtime!", "PM2 Process Initiated")
    } else {
        [System.Windows.Forms.MessageBox]::Show("PM2 runtime not found globally! Please execute 'npm install pm2 -g' inside your terminal before running this utility.", "Missing Runtime Dependency", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
    
    $form.Close()
})

$form.ShowDialog() | Out-Null