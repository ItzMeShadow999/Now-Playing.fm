Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ParentDir  = Split-Path $PSScriptRoot -Parent
$ConfigDir  = Join-Path $ParentDir "Main config"
$IconsDir   = Join-Path $ParentDir "Icons"
$ScriptPath = Join-Path $ConfigDir "sync.js"
$IconPath   = Join-Path $IconsDir "Config.ico"

function Get-ScriptValue($regex, $fallback) {
    if (Test-Path $ScriptPath) {
        $content = Get-Content $ScriptPath -Raw
        if ($content -match $regex) { return $Matches[1].Trim() }
    }
    return $fallback
}

$CurrentInterval = if ((Get-ScriptValue "syncIntervalMs:\s*(\d+)\s*\*\s*1000" "30") -match "(\d+)") { $Matches[1] } else { "30" }
$LabelArtist = Get-ScriptValue "name:\s*'([^']+)',\s*value:\s*stats\.artist" "Artist"
$LabelAlbum = Get-ScriptValue "name:\s*'([^']+)',\s*value:\s*stats\.album" "Album"
$LabelScrobbles = Get-ScriptValue "name:\s*'([^']+)',\s*value:\s*stats\.scrobbles" "Scrobbles"
$LogFetchString = '[Status] Fetching live tracking & profile stats for: `${CONFIG.lastfmUsername}`...'

$form = New-Object System.Windows.Forms.Form
$form.Text = "SYSTEM // Config Panel"
$form.Size = New-Object System.Drawing.Size(820, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 11)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.StartPosition = "CenterScreen"

if (Test-Path $IconPath) {
    try { $form.Icon = New-Object System.Drawing.Icon($IconPath) } catch {}
}

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Size = New-Object System.Drawing.Size(820, 65)
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(26, 12, 36)
$form.Controls.Add($pnlHeader)

$pnlLine = New-Object System.Windows.Forms.Panel
$pnlLine.Size = New-Object System.Drawing.Size(820, 2)
$pnlLine.Location = New-Object System.Drawing.Point(0, 63)
$pnlLine.BackColor = [System.Drawing.Color]::FromArgb(163, 73, 164)
$pnlHeader.Controls.Add($pnlLine)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "APPLICATION CONFIGURATION MANAGER // GUI"
$lblTitle.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(230, 160, 240)
$lblTitle.Location = New-Object System.Drawing.Point(25, 20)
$lblTitle.AutoSize = $true
$pnlHeader.Controls.Add($lblTitle)

function Create-TerminalField($title, $currValue, $posX, $posY, $width=350) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $title.ToUpper()
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(140, 140, 150)
    $lbl.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point($posX, $posY)
    $lbl.AutoSize = $true
    $form.Controls.Add($lbl)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Text = $currValue
    $txt.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20)
    $txt.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 130)
    $txt.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $txt.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
    $txt.Location = New-Object System.Drawing.Point($posX, ($posY + 20))
    $txt.Size = New-Object System.Drawing.Size($width, 28)
    $form.Controls.Add($txt)
    return $txt
}

$txtInterval  = Create-TerminalField "Sync Interval (In Seconds)" $CurrentInterval 40 95
$txtLogString = Create-TerminalField "Console Output Format" $LogFetchString 40 175 350

$txtLabelArtist    = Create-TerminalField "Discord: Field 1 Label" $LabelArtist 420 95
$txtLabelAlbum     = Create-TerminalField "Discord: Field 2 Label" $LabelAlbum 420 175
$txtLabelScrobbles = Create-TerminalField "Discord: Field 3 Label" $LabelScrobbles 420 255

$lblSystemWarning = New-Object System.Windows.Forms.Label
$lblSystemWarning.Text = "WARNING: 30 seconds is the recommended minimum interval. Lower values significantly increase the risk of API rate limiting."
$lblSystemWarning.ForeColor = [System.Drawing.Color]::FromArgb(200, 80, 80)
$lblSystemWarning.Font = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Bold)
$lblSystemWarning.Location = New-Object System.Drawing.Point(40, 335)
$lblSystemWarning.Size = New-Object System.Drawing.Size(730, 25)
$form.Controls.Add($lblSystemWarning)

$btnCommit = New-Object System.Windows.Forms.Button
$btnCommit.Text = "COMMIT AND APPLY SETTINGS CHANGES"
$btnCommit.BackColor = [System.Drawing.Color]::FromArgb(163, 73, 164)
$btnCommit.ForeColor = [System.Drawing.Color]::White
$btnCommit.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnCommit.FlatAppearance.BorderSize = 0
$btnCommit.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$btnCommit.Location = New-Object System.Drawing.Point(40, 365)
$btnCommit.Size = New-Object System.Drawing.Size(730, 45)
$form.Controls.Add($btnCommit)

$btnCommit.Add_Click({
    if (-not (Test-Path $ScriptPath)) {
        [System.Windows.Forms.MessageBox]::Show("Error: sync.js file not found in Main config folder.", "System Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $cleanSec = $txtInterval.Text -replace '\D', ''
    if ([string]::IsNullOrEmpty($cleanSec) -or [int]$cleanSec -lt 1) { $cleanSec = "30" }

    $src = [System.IO.File]::ReadAllText($ScriptPath)

    $src = [Regex]::Replace($src, "syncIntervalMs:\s*[^,\n]+", "syncIntervalMs: $cleanSec * 1000")
    $src = [Regex]::Replace($src, "name:\s*'[^']+',\s*value:\s*stats\.artist", "name: '$($txtLabelArtist.Text)', value: stats.artist")
    $src = [Regex]::Replace($src, "name:\s*'[^']+',\s*value:\s*stats\.album", "name: '$($txtLabelAlbum.Text)', value: stats.album")
    $src = [Regex]::Replace($src, "name:\s*'[^']+',\s*value:\s*stats\.scrobbles", "name: '$($txtLabelScrobbles.Text)', value: stats.scrobbles")
    
    $escapedLog = $txtLogString.Text.Replace('$', '`$')
    $src = [Regex]::Replace($src, 'console\.log\(`(.+?)\.\.\.`\);', 'console.log(`' + $escapedLog + '`);')

    [System.IO.File]::WriteAllText($ScriptPath, $src, [System.Text.Encoding]::UTF8)

    [System.Windows.Forms.MessageBox]::Show("Configuration updated successfully.", "System Updated")
    $form.Close()
})

$form.ShowDialog() | Out-Null