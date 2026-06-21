# ⚡ SystemPulse

> A lightweight, cross-platform system information tool — collects system specs, generates a structured JSON report, and saves it right next to the executable. All with a single double-click.

**Author:** Kaustubh Bharti, VIT Chennai

---

## 🎯 What It Does

Download **one file** for your platform → run it → done:

1. **Opens** the HTML report in your default browser
2. **Gathers** system information using native OS commands
3. **Generates** a uniquely named JSON report (`{hostname}_{timestamp}.json`)
4. **Saves** the JSON in the same directory as the executable
5. **Logs** all CRUD operations with status

> No console window. No popups. No setup. No external files. Just download and run.

---

## 📦 What's Inside Each Executable

Every binary is **100% self-contained** — everything is embedded inside:

| Embedded Component | Windows `.exe` | Linux / macOS |
|--------------------|---------------|---------------|
| HTML report | ✅ C# resource | ✅ Embedded in script |
| `index.js` (Node.js logic) | ✅ C# resource | ✅ Embedded in script |
| `system-info.ps1` (PowerShell fallback) | ✅ C# resource | N/A |
| Bash fallback (no Node.js) | N/A | ✅ Built into script |

**Zero external files needed.** Download → Run → Done.

---

## 📂 Downloads

> **[⬇️ Download from GitHub Releases](https://github.com/Kaustubh-Bharti/Hackathon-3.0/releases)**

| Report | Windows | Linux | macOS |
|--------|---------|-------|-------|
| **Controversy Rankings** | `.exe` (68 KB) | `-linux` (51 KB) | `-macos` (51 KB) |
| **Country Impact Matrix** | `.exe` (82 KB) | `-linux` (66 KB) | `-macos` (66 KB) |
| **Full Action Report** | `.exe` (126 KB) | `-linux` (109 KB) | `-macos` (109 KB) |
| **Strategic Analysis** | `.exe` (79 KB) | `-linux` (63 KB) | `-macos` (63 KB) |

> Windows `.exe` files use the system's .NET Framework. Linux/macOS files are self-contained shell scripts with embedded HTML + JS.

---

## 🚀 Quick Start

### Windows — Just double-click

```
full-action-report.exe
```

A JSON file like `MSI_2026-06-21T19-13-00.json` will appear in the same folder.

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

That's it. The HTML report opens in your browser, and the system info JSON is saved in the same directory.

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
        │  [1/1] Generate system info JSON             │
        │        Saved next to the executable          │
        └──────────────────────────────────────────────┘
            │
            ▼
          Done (temp files cleaned up)
```

---

## 📊 Sample JSON Output

Each run produces a uniquely named file like `MSI_2026-06-21T19-13-00.json`:

```json
{
  "_meta": {
    "generated_at": "2026-06-21T19:13:01.209Z",
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
    "total_operations": 1,
    "history": [
      { "operation": "CREATE", "status": "success", "detail": "System info JSON generated" }
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
| `(default)` / `auto` | Generate system info JSON |
| `info` | Same as auto |
| `create <file> <content>` | Create a file in workspace |
| `read <file>` | Read a workspace file |
| `update <file> <content>` | Update a workspace file |
| `delete <file>` | Delete a workspace file |
| `list` | List workspace files |
| `help` | Show usage |

---

## 🔐 Running on Other Machines

Each binary is self-contained. Just download the one file for your platform and run.

> **Node.js is optional.** If installed, the binary uses it for richer output. If not, it falls back to native bash/PowerShell commands automatically.
>
> **No internet connection required.** Everything runs locally — the JSON report is saved in the same directory.

### Unique Filenames

Each machine produces a unique filename: `{hostname}_{timestamp}.json`

```
Downloads/
├── MSI_2026-06-21T19-13-00.json          ← from laptop "MSI"
├── DESKTOP-ABC_2026-06-22T09-15-00.json  ← from desktop "DESKTOP-ABC"
└── MacBook-Pro_2026-06-23T14-30-00.json  ← from MacBook
```

No clashes, no overwrites.

---

## 🏗️ Building the Executables

### Windows

All `.exe` files are compiled using the built-in Windows C# compiler — each with its HTML, `index.js`, and `system-info.ps1` embedded as resources:

```bash
csc /target:winexe /out:full-action-report.exe ^
    /resource:full-action-report.html,report.html ^
    /resource:index.js /resource:system-info.ps1 ^
    report-launcher.cs
```

### Linux / macOS

Shell scripts with all content appended after markers. No compilation needed:

```
[Shell script logic]
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
| `index.js` | Main Node.js logic (cross-platform system info collector) |
| `system-info.ps1` | PowerShell fallback for Windows (when no Node.js) |
| `*.html` | HTML report files (embedded into executables at build time) |

---

## ⚙️ Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Self-contained binaries** | Everything embedded — download one file and run, zero setup |
| **Local JSON output** | Report saved next to the executable — no cloud, no accounts |
| **Silent execution** | Windows: compiled as `winexe` — no console, no popups |
| **Name-based detection** | Each binary detects its own filename to open the correct HTML |
| **Native commands** | Uses `wmic`, `uname`, `sysctl` — not Node.js `os` module |
| **Unique filenames** | `{hostname}_{timestamp}.json` prevents cross-machine clashes |
| **CRUD audit trail** | Every pipeline action logged with status in the JSON |
| **Graceful fallback** | Node.js present → use it. Absent → bash/PowerShell fallback |
| **Temp directory isolation** | Files extracted to OS temp dir, cleaned up after execution |
| **GitHub Releases** | Binaries distributed via Releases for easy downloading |
