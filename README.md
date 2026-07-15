# Now Playing.fm

---

A lightweight, background-sync engine that bridges your Last.fm music metadata directly to your Discord status. Designed for simplicity and performance, this tool runs headless, keeping your activity updated without needing to manually manage your status.

## Getting Started

### Prerequisites & Automated Setup

1. **Clone or Download** the repository to your local machine.
2. Get a Last.fm API key → https://www.last.fm/api/account/create
3. **Environment Setup**: You don't need to manually configure dependencies. Simply run the `Setup-Environment.bat` file included in the repository; it will verify your Node.js installation and automatically install PM2 globally if it's missing.
4. **Initialization**: Open the `Start Widget Config.bat` file, wait about 5 seconds, and click it again to initialize the folder structure. The system will automatically create your `.env` configuration file during the sync process.
5. **Configure & Deploy**: Use the generated PowerShell GUI to input your API credentials, then click the **Sync Last.fm** button to deploy the engine as a permanent background process via PM2.

> [!TIP]
> Run the `.bat` files from a normal (Administrator) terminal on first setup. if you install PM2 as a Windows Service see the Troubleshooting section below.

---

## Required Widget Data

To format your Discord profile widget, you will need the necessary JSON data structure. You can source your required layout schemas from either of these repositories:

* [Discord Widget Configurator](https://github.com/ItzMeShadow999/Discord_Widget_Configurator) ![Recommended](https://img.shields.io/badge/Recommended-%E2%9C%94-brightgreen)
* [Discord Widgets Extension](https://github.com/TheCreativeGod/Discord-Widgets-Extension)

Once you have your preferred configuration tool, you can access the reference blueprint here: [Widget Json Data.txt](https://github.com/ItzMeShadow999/Now-Playing.fm/blob/main/Widget%20Json%20Data.txt).

---

## Troubleshooting: PM2 `EPERM` / Registry Access Errors

<details>
<summary><strong>Click to expand fixes "EPERM" and "Requested registry access is not allowed" on Windows</strong></summary>

> WARNING
> These errors happen when PM2 is running as a **Windows Service** (under the `SYSTEM` account) at the same time you're running `pm2` commands from your own **user account**. The two contexts fight over `PM2_HOME`, causing `EPERM` on the process files and registry-access failures when Node tries to write environment keys.

### Step 1 — Identify what's actually running

Open PowerShell **as Administrator** and check the real service name first it isn't always literally `PM2`:

```powershell
Get-Service | Where-Object { $_.Name -like "*pm2*" }
```

### Step 2 — Stop everything cleanly

```powershell
# Stop the Windows service (use the name found above)
Stop-Service -Name "PM2" -ErrorAction SilentlyContinue

# Kill the PM2 daemon itself (not just the process list)
pm2 kill

# Only if node.exe processes remain, kill leftovers
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
```

> [!CAUTION]
> Avoid `taskkill /f /im node.exe /t` unless nothing else is currently using Node — it kills **every** Node process system-wide, including unrelated apps, dev servers, or editor extensions.

### Step 3 — Check for a conflicting user-level variable

Windows merges **User** and **System** environment variables, and the **user-level value wins** for anything you run interactively. If `PM2_HOME` is already set at the user level, setting a new one at the system level will silently be ignored in your own terminal.

```powershell
[System.Environment]::GetEnvironmentVariable("PM2_HOME", "User")
[System.Environment]::GetEnvironmentVariable("PM2_HOME", "Machine")
```

If a **User** value exists, remove it or point it at the same folder as the System value:

```powershell
[System.Environment]::SetEnvironmentVariable("PM2_HOME", $null, "User")
```

### Step 4 — Set `PM2_HOME` at the System level

Manual GUI method (most reliable if the CLI throws the registry error):

1. Press `Win + R`, type `sysdm.cpl`, press Enter.
2. **Advanced** tab → **Environment Variables**.
3. Under **System variables**, click **New**.
4. Variable name: `PM2_HOME`
5. Variable value: `C:\pm2`
6. **OK** on all windows, then close and reopen your terminal.

### Step 5 — Fix folder permissions

Even as Administrator, your account may not have ACL rights on a folder first created by the `SYSTEM`-context service:

```powershell
icacls "C:\pm2" /grant "$($env:USERNAME):(OI)(CI)F" /T
```

### Step 6 — Migrate & relaunch

```powershell
cd "C:\Users\user\OneDrive\Documents\Discord\discord Widgets\Last.fm-Live\Main config"

pm2 start sync.js --name "lastfm-sync" --cwd "C:\Users\user\OneDrive\Documents\Discord\discord Widgets\Last.fm-Live\Main config"

pm2 save
```

### Step 7 — Restart the service and verify

```powershell
Start-Service -Name "PM2"

# Verify PM2_HOME actually resolved before trusting the result
echo $env:PM2_HOME
pm2 ping
pm2 list
```

> ▷ [IMPORTANT]
> If `pm2 list` still throws `EPERM`, the daemon likely didn't pick up the new `PM2_HOME`. Run `pm2 kill` again and re-issue `pm2 list` this forces a fresh daemon spawn under the current environment.

### Longer-term fix

Always re-elevating PowerShell is a workaround, not a real fix. If this keeps recurring, reconfigure the PM2 Windows Service to run under **your own user account** instead of `SYSTEM` (via `pm2-installer`'s config or a scheduled-task-based service) so there's only ever one execution context.

### ⚠︎ OneDrive Warning

If you are running `sync.js` from a `OneDrive` folder. If the machine reboots and the PM2 service starts before OneDrive finishes syncing/downloading the file, the script will crash immediately on launch.

> ▷ [NOTE]
> For long-term stability, move the `Last.fm-Live` folder out of OneDrive to a local path such as `C:\Apps\Last.fm-Live` to guarantee it's available on boot.

</details>

---

## Need Help?

If you run into any setup failures or structural system issues, feel free to DM **[Shadow](https://discord.com/users/1065604516399026176)** directly on Discord.

---

## Project Architecture

| Component | Responsibility |
| --- | --- |
| **`sync.js`** | Core engine that fetches Last.fm data and patches your Discord identity. |
| **`Launcher.ps1`** | Orchestrates the PM2 background runtime and environment variable injection. |
| **`dashboard.ps1`** | User-friendly GUI for editing intervals, labels, and API keys without touching code. |
| **`.env`** | Local secure store for your Bot Token and API Keys. |

---

## 📄 License & Attribution

This project is open-source software licensed under the **MIT License**.

```text
MIT License

Copyright (c) 2026 Shadow (ItzMeShadow999)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```
