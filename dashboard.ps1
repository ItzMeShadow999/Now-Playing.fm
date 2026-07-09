Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$IconsDir   = Join-Path $PSScriptRoot "Icons"
$ScriptsDir = Join-Path $PSScriptRoot "Ps & Bat scripts"

$IconMain   = Join-Path $IconsDir "Config.ico"
$ImgEdit    = Join-Path $IconsDir "Config.ico"    
$ImgSync    = Join-Path $IconsDir "last.fm.ico" 

$ScriptEditor = Join-Path $ScriptsDir "editor.ps1"
$ScriptLaunch = Join-Path $ScriptsDir "Launcher.ps1"


$form = New-Object System.Windows.Forms.Form
$form.Text = "SYSTEM // Last.fm widget Setup"
$form.Size = New-Object System.Drawing.Size(560, 360)
$form.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 11)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.StartPosition = "CenterScreen"

if (Test-Path $IconMain) {
    try { $form.Icon = New-Object System.Drawing.Icon($IconMain) } catch {}
}

$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Size = New-Object System.Drawing.Size(560, 65)
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(26, 12, 36)
$form.Controls.Add($pnlHeader)

$pnlLine = New-Object System.Windows.Forms.Panel
$pnlLine.Size = New-Object System.Drawing.Size(560, 2)
$pnlLine.Location = New-Object System.Drawing.Point(0, 63)
$pnlLine.BackColor = [System.Drawing.Color]::FromArgb(163, 73, 164)
$pnlHeader.Controls.Add($pnlLine)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "WIDGET CONTROL CENTER // ROOT"
$lblTitle.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(230, 160, 240)
$lblTitle.Location = New-Object System.Drawing.Point(25, 20)
$lblTitle.AutoSize = $true
$pnlHeader.Controls.Add($lblTitle)


function Create-LauncherCard($title, $subtext, $iconPath, $posX, $posY, $onClickAction) {
    $pnlCard = New-Object System.Windows.Forms.Panel
    $pnlCard.Size = New-Object System.Drawing.Size(220, 180)
    $pnlCard.Location = New-Object System.Drawing.Point($posX, $posY)
    $pnlCard.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20)
    $pnlCard.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $pnlCard.add_Paint({
        param($sender, $e)
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(45, 45, 50), 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, $sender.Width - 1, $sender.Height - 1)
    })

    $pbIcon = New-Object System.Windows.Forms.PictureBox
    $pbIcon.Size = New-Object System.Drawing.Size(48, 48)
    $pbIcon.Location = New-Object System.Drawing.Point(86, 25)
    $pbIcon.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $pbIcon.BackColor = [System.Drawing.Color]::Transparent
    if (Test-Path $iconPath) {
        try {
            $ico = New-Object System.Drawing.Icon($iconPath, 48, 48)
            $pbIcon.Image = $ico.ToBitmap()
        } catch {
            try { $pbIcon.Image = [System.Drawing.Image]::FromFile($iconPath) } catch {}
        }
    }

    $lblHeader = New-Object System.Windows.Forms.Label
    $lblHeader.Text = $title.ToUpper()
    $lblHeader.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $lblHeader.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 130)
    $lblHeader.Location = New-Object System.Drawing.Point(10, 95)
    $lblHeader.Size = New-Object System.Drawing.Size(200, 20)
    $lblHeader.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

    $lblSub = New-Object System.Windows.Forms.Label
    $lblSub.Text = $subtext
    $lblSub.Font = New-Object System.Drawing.Font("Consolas", 8)
    $lblSub.ForeColor = [System.Drawing.Color]::FromArgb(130, 130, 140)
    $lblSub.Location = New-Object System.Drawing.Point(10, 120)
    $lblSub.Size = New-Object System.Drawing.Size(200, 45)
    $lblSub.TextAlign = [System.Drawing.ContentAlignment]::TopCenter

    $pnlCard.Add_Click($onClickAction)
    $pbIcon.Add_Click($onClickAction)
    $lblHeader.Add_Click($onClickAction)
    $lblSub.Add_Click($onClickAction)

    # Scoped tracking using parent tags to dynamically swap wrapper panels safely
    $pnlCard.Tag = $pnlCard
    $pbIcon.Tag = $pnlCard
    $lblHeader.Tag = $pnlCard
    $lblSub.Tag = $pnlCard

    $pnlCard.add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(28, 22, 36) })
    $pnlCard.add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20) })
    
    $pbIcon.add_MouseEnter({ $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(28, 22, 36) })
    $pbIcon.add_MouseLeave({ $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20) })
    
    $lblHeader.add_MouseEnter({ $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(28, 22, 36) })
    $lblHeader.add_MouseLeave({ $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20) })
    
    $lblSub.add_MouseEnter({ $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(28, 22, 36) })
    $lblSub.add_MouseLeave({ $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20) })

    $pnlCard.Controls.Add($pbIcon)
    $pnlCard.Controls.Add($lblHeader)
    $pnlCard.Controls.Add($lblSub)
    $form.Controls.Add($pnlCard)
}


$LaunchEditorAction = {
    if (Test-Path $ScriptEditor) {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptEditor`"" -WorkingDirectory $ScriptsDir
    } else {
        [System.Windows.Forms.MessageBox]::Show("Error: editor.ps1 framework target missing from scripts folder.", "Path Error")
    }
}

$LaunchDeployAction = {
    if (Test-Path $ScriptLaunch) {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptLaunch`"" -WorkingDirectory $ScriptsDir
    } else {
        [System.Windows.Forms.MessageBox]::Show("Error: Launcher.ps1 daemon config target missing from scripts folder.", "Path Error")
    }
}


Create-LauncherCard "Config Editor" "Modify system layouts, text mappings, and intervals inside sync.js." $ImgEdit 40 100 $LaunchEditorAction
Create-LauncherCard "Sync Last.fm" "Configure API tokens and launch the background loop tracking threads." $ImgSync 290 100 $LaunchDeployAction

$form.ShowDialog() | Out-Null