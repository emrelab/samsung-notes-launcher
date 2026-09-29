# Samsung Notes Launcher

[![License: MIT](https://img.shields.io/github/license/emrelab/samsung-notes-launcher?color=blue)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white)
![Language](https://img.shields.io/badge/language-Batch%20%2B%20PowerShell-4D4D4D)
![Install](https://img.shields.io/badge/install-none%20required-brightgreen)

A no-install Windows batch helper for the **Samsung Notes** app from the Microsoft
Store (UWP/AppX) on a **non-Samsung PC** — it locates the installed app package,
reports its identity, and refuses to continue with a readable message when the app
is missing.

> [!IMPORTANT]
> **Status — read this first.** The script currently implements the *detection* stage:
> administrator elevation, package lookup via PowerShell, and parsing of
> `PackageFullName` / `PackageFamilyName`. The **launch step** and the
> **device-identity workaround** (making Windows report itself as a Samsung device) are
> **not implemented in the committed script yet**. They are listed under
> [Roadmap](#-roadmap) — nothing on this page should be read as "it already runs
> Samsung Notes for you".

---

## 📌 Why this exists

The Microsoft Store build of Samsung Notes is distributed as a Samsung-only app: it
checks the device identity at startup and on a Dell/Lenovo/Asus/desktop build it either
refuses to run or greys out its sync functions. There is no official "install on any PC"
path.

This repository is the scaffolding half of a workaround: before touching any device
identity you must first reliably answer *"is Samsung Notes installed on this machine, and
what is its exact package identity?"*. That is what `samsung-launcher.bat` does today.

## 🔧 What the script actually does

| Step | Implementation | Where it lives in the script |
|---|---|---|
| Self-elevate | `net session` probe, then `Start-Process -Verb RunAs` | lines 12–20 |
| Look up the app | `Get-AppxPackage -Name *Samsung*Notes*`, dumped to `%temp%\samsung_details.txt` | line 24 |
| Guard against "not installed" | `find /i "PackageFullName"` → friendly message + `pause`, instead of a cryptic failure | lines 27–35 |
| Parse the identity | `for /f` over `findstr`, whitespace-stripped into `PACKAGE_FULL` / `PACKAGE_FAMILY` | lines 38–43 |

The script prints its messages in **Turkish** (the author's language) — they are
informational only, nothing depends on matching their text.

**No system files and no registry keys are read or written by the current script.** It
only queries the AppX package list for the current user. The BIOS/device-identity changes
described in older revisions of this README are not part of the code in this repository.

## 📋 Requirements

| | |
|---|---|
| OS | Windows 10 or Windows 11 |
| App | Samsung Notes installed from the Microsoft Store |
| Privileges | Administrator (the script self-elevates; accept the UAC prompt) |
| Dependencies | None — Batch and the PowerShell already present in Windows |

## 🚀 Usage

1. Download **[`samsung-launcher.bat`](samsung-launcher.bat)** (right-click → *Save link as…*).
2. Double-click it, or right-click → **Run as administrator**.
3. Accept the UAC prompt — the script re-launches itself elevated.
4. Read the report: the window prints `Paket Tam Adı` (package full name) and
   `Paket Aile Adı` (package family name).
5. Press any key to close.

Verified output shape on a machine with the app installed:

```
Paket Tam Adı: SamsungNotes_4.3.100.0_x64__<publisher-hash>
Paket Aile Adı: SamsungNotes_<publisher-hash>
```

On a machine without it:

```
Hata: Samsung Notes uygulaması bulunamadı.
Lütfen Microsoft Store'dan Samsung Notes uygulamasını yükleyin.
```

## 🧯 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Hata: Samsung Notes uygulaması bulunamadı.` | App not installed, or its package name no longer contains `Samsung` + `Notes` | Run `Get-AppxPackage *Samsung* \| Select Name` in PowerShell and update the pattern in line 24 |
| Window flashes and closes | Started without elevation and the UAC prompt was dismissed | Right-click the file → **Run as administrator** |
| `powershell` not recognized / blocked by policy | PowerShell removed or locked down by group policy on a managed machine | Use the package name from `Get-AppxPackage` manually; the script cannot run without PowerShell |
| The `%temp%` dump file is stale | The script overwrites it on every run | Delete `%temp%\samsung_details.txt` and re-run |

## 🧭 Roadmap

- [x] Self-elevation with a clear UAC flow
- [x] Locate the Samsung Notes package and expose its full / family name
- [x] Fail with a human-readable message when the app is absent
- [ ] **Launch the app** once found — `explorer.exe shell:appsFolder\<PackageFamilyName>!<AppId>`
- [ ] **Device-identity workaround**, with an automatic backup of the previous values and a guaranteed restore on exit
- [ ] Pre-flight check that refuses to run if a previous backup was left behind (interrupted run)
- [ ] Optional `-WhatIf`-style dry run that prints planned changes and touches nothing

Contributions towards the unchecked items are welcome — please open an issue first so the
approach to the device-identity step can be agreed before code lands.

## 🚨 Disclaimer

- **Unofficial.** Not affiliated with, endorsed by, or supported by Samsung or Microsoft.
- The current script makes no persistent change to your system. Any future release that
  modifies device identity will ship with backup/restore and will say so explicitly in
  this README and in the release notes.
- Running a Microsoft Store application outside its intended hardware may conflict with
  Microsoft's and/or Samsung's terms of service. Review them before use.
- Use at your own risk; the authors are not responsible for software or hardware issues.
- Samsung may change its verification mechanism at any time, which can break any
  workaround without notice.

## 🤝 Contributing

Bug reports, feature requests and pull requests are welcome via
[GitHub Issues](https://github.com/emrelab/samsung-notes-launcher/issues). Useful reports
include your Windows build (`winver`), the app's package name as printed by the script,
and the exact message you saw. Please never paste a publisher hash you consider private.

## 📄 License

[MIT](LICENSE) © emrelab

---

**Note:** this tool does not guarantee Samsung Notes will work on non-Samsung hardware.
The end-to-end flow is still under development — see [Roadmap](#-roadmap).
