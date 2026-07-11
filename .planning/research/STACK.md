# Stack Research

**Domain:** File Synchronization Bridge (Air-gapped architecture via dual-PC LAN)
**Researched:** 2026-07-11
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| PowerShell | 5.1+ | Core scripting and execution engine | Native to all modern Windows environments. Completely avoids third-party executables and compiled runtimes, which minimizes the risk of triggering campus EDR (Endpoint Detection and Response) or Windows Defender. |
| SMB (Windows File Sharing) | v3.x | Transport layer between PC A and PC B | Built-in Windows capability for local LAN file sharing. Can be strictly firewalled to local IPs, satisfying the requirement for network isolation without bridging. |
| Windows Task Scheduler | Native | Process daemon / startup management | Allows persistent background execution of the PowerShell watcher scripts without requiring a logged-in user or installing third-party daemon services. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `System.IO.FileSystemWatcher` | .NET Core/Framework | Event-driven file monitoring | Use within PowerShell (`[System.IO.FileSystemWatcher]`) to monitor the drop-box directories (`Documents\Sync`, `\To_Uni`, `\To_Local`) for instant, event-driven queue management rather than polling. |
| `ConvertFrom-Json` / `ConvertTo-Json` | PS Native | State tracking and manifest management | Use for parsing and updating `sync-manifest.json` and the new `uni-sync-manifest.json` in-memory cache to track synced files and prevent infinite echo loops. |
| `Robocopy` | Native | Robust file transfer | Use as a fallback or primary copy mechanism if large files or network flakiness require built-in retries, as it is a trusted Windows native binary. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Windows Defender Firewall with Advanced Security | Strict LAN isolation | Must be configured to explicitly block internet/university outbound traffic on the local LAN interfaces, restricting them to SMB/file-sharing ports (445) only between PC A and PC B. |

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Two-PC Drop-Box | Single PC Adapter Toggling | ONLY if hardware is severely constrained (i.e., acquiring a second PC is impossible). Rejected here due to connection dropping errors on network shares and complexity. |
| `System.IO.FileSystemWatcher` | Polling via `Get-ChildItem` | Use if `FileSystemWatcher` drops events under extremely high file creation loads. Can be implemented as a fallback mechanism every X minutes to catch missed events. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Compiled Runtimes (C# / PyInstaller / Go) | High risk of being flagged by aggressive campus network endpoint security or Windows Defender. | Native PowerShell scripts (`.ps1`). |
| Third-party sync tools (Syncthing, Resilio) | Introduces external binaries that violate the "native OS implementation only" validated requirement. | Custom PowerShell logic using SMB. |
| Network Adapter Toggling (`Disable-NetAdapter`) | Prone to failure, breaks persistent connections, and requires elevated privileges that can complicate deployment. | Dual-PC architecture with physical network separation and firewalled LAN. |

## Stack Patterns by Variant

**If handling large queues of files:**
- Use a dedicated staging queue directory before moving to the final drop-box.
- Because `FileSystemWatcher` can sometimes fire multiple events for a single file or drop events if overwhelmed. A staging queue allows for atomic moves.

**If the WhatsApp bot updates `sync-manifest.json` rapidly:**
- Use file locking checks or read-only parsing in the bridge script.
- Because you must avoid write-collisions or corrupting the manifest that the bot relies on.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| PowerShell 5.1 | Windows 10/11 | Built-in by default. Ensures maximum compatibility without requiring PowerShell Core (7.x) installation. |
| System.IO.FileSystemWatcher | PowerShell 5.1+ | Instantiated natively via .NET reflection in PS. |

## Sources

- .planning/PROJECT.md - Project context, goals, and constraints.
- Official Microsoft Docs - Verified PowerShell 5.1 native JSON handling and FileSystemWatcher .NET classes.
- Security constraints based on standard campus EDR behavior (HIGH confidence).

---
*Stack research for: Sync Bridge*
*Researched: 2026-07-11*
