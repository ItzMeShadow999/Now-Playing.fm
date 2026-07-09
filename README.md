
# Now Playing.fm
---

A lightweight, background-sync engine that bridges your Last.fm music metadata directly to your Discord status. Designed for simplicity and performance, this tool runs headless, keeping your activity updated without needing to manually manage your status.

## Getting Started

### Prerequisites & Automated Setup

1. **Clone or Download** the repository to your local machine.
2. **Environment Setup**: You don't need to manually configure dependencies. Simply run the `Setup-Environment.bat` file included in the repository; it will verify your Node.js installation and automatically install PM2 globally if it's missing.
3. **Initialization**: Open the `Start Widget Config.bat` file, wait about 5 seconds, and click it again to initialize the folder structure. The system will automatically create your `.env` configuration file during the sync process.
4. **Configure & Deploy**: Use the generated PowerShell GUI to input your API credentials, then click the **Sync Last.fm** button to deploy the engine as a permanent background process via PM2.



---

## Required Widget Data

To format your Discord profile widget, you will need the necessary JSON data structure. You can source your required layout schemas from either of these repositories:

* [Discord Widget Configurator](https://github.com/ItzMeShadow999/Discord_Widget_Configurator)
* [Discord Widgets Extension](https://github.com/TheCreativeGod/Discord-Widgets-Extension)

Once you have your preferred configuration tool, you can access the reference blueprint here: [Widget Json Data.txt](https://github.com/ItzMeShadow999/Now-Playing.fm/blob/main/Widget%20Json%20Data.txt).

---

## Need Help?

If you run into any setup failures or structural system issues, feel free to DM **[Shadow](https://discord.com/users/1065604516399026176)** directly on Discord.

---

## Project Architecture

| Component | Responsibility |
| --- | --- |
| **`sync.js`** | Core engine that fetches Last.fm data and patches your Discord identity.

 |
| **`Launcher.ps1`** | Orchestrates the PM2 background runtime and environment variable injection.

 |
| **`dashboard.ps1`** | User-friendly GUI for editing intervals, labels, and API keys without touching code.

 |
| **`.env`** | Local secure store for your Bot Token and API Keys.

 |

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
