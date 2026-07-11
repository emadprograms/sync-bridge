# Architecture Research

**Domain:** Event-Driven Air-Gapped File Synchronization
**Researched:** 2026-07-11
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                          PC A (Local)                       │
│  [Internet connection]                    [LAN connection]  │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────┐         ┌────────────────────────┐      │
│  │ Documents\Sync │  <--->  │ PCA_Watcher.ps1        │      │
│  │ (WhatsApp bot) │         │ (Event-Driven Gateway) │      │
│  └────────────────┘         └──────────┬─────────────┘      │
├────────────────────────────────────────┼────────────────────┤
│                                   SMB Share                 │
├────────────────────────────────────────┼────────────────────┤
│  ┌────────────────────────┐         ┌──┴─────────────────┐  │
│  │ University Network     │  <--->  │ PCB_Watcher.ps1    │  │
│  │ (Target Destination)   │         │ (Bridge Manager)   │  │
│  └────────────────────────┘         └──────────┬─────────┘  │
│                                                │            │
│  ┌────────────────┐         ┌──────────────────┴─────┐      │
│  │ \To_Uni        │         │ \To_Local              │      │
│  │ (Drop Folder)  │         │ (Drop Folder)          │      │
│  └────────────────┘         └────────────────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                          PC B (Bridge)                      │
│  [University network]                     [LAN connection]  │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `PCA_Watcher.ps1` | Monitors local sync folder, pushes/pulls to/from LAN drop folders, tracks manifest. | PowerShell FileSystemWatcher / Polling |
| `PCB_Watcher.ps1` | Monitors LAN drop folders, moves files to/from University Network. | PowerShell FileSystemWatcher / Polling |
| `\To_Uni` | Intermediate storage for files going from PC A to University. | Windows SMB Shared Folder |
| `\To_Local` | Intermediate storage for files going from University to PC A. | Windows SMB Shared Folder |
| `sync-manifest.json` | Tracking files downloaded by WhatsApp bot. | JSON file read by PCA_Watcher |
| `uni-sync-manifest.json` | Tracking state of synced files to prevent echo loops (ping-ponging). | JSON memory cache / local file |

## Recommended Project Structure

```
sync-bridge/
├── src/                    # Core PowerShell scripts
│   ├── pc-a/               # Scripts running on Local PC
│   │   ├── PCA_Watcher.ps1 # Local queue manager
│   │   └── state/          # State tracking (uni-sync-manifest)
│   ├── pc-b/               # Scripts running on Bridge PC
│   │   └── PCB_Watcher.ps1 # Bridge queue manager
│   └── shared/             # Shared utilities
│       ├── Logger.ps1      # Logging functions
│       └── Config.ps1      # Configuration loading
├── tests/                  # Mock testing utilities
└── deploy/                 # Deployment scripts or scheduled task XMLs
```

### Structure Rationale

- **`src/pc-a/` and `src/pc-b/`:** Clearly separates the scripts that run on the internet-connected machine vs. the university-connected machine, maintaining mental boundaries of the air-gap.
- **`src/shared/`:** Centralizes cross-cutting concerns like logging and common folder path configurations to prevent duplication across PC scripts.
- **`deploy/`:** Keeps infrastructure-related setup files (like Windows Scheduled Task exports) separate from the application logic.

## Architectural Patterns

### Pattern 1: Event-Driven File Watching

**What:** Using `System.IO.FileSystemWatcher` combined with an event queue to detect file changes and trigger sync events.
**When to use:** To react quickly to WhatsApp bot downloads or incoming bridge files without constant CPU-heavy polling.
**Trade-offs:** FileSystemWatcher can miss events under heavy load or rapid file generation. It needs a robust debounce mechanism and a periodic reconciliation polling fallback.

**Example:**
```powershell
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "C:\Users\Emad\Documents\Sync"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher "Created" -Action {
    # Add file to sync queue
}
```

### Pattern 2: Split-Brain State Tracking (Echo Prevention)

**What:** Maintaining a separate `uni-sync-manifest.json` distinct from `sync-manifest.json` to track files we have already synced.
**When to use:** In bi-directional sync setups where a file pushed from A to B shouldn't be pulled back from B to A (infinite loop).
**Trade-offs:** Adds state management complexity and disk I/O; requires robust error handling to ensure atomic updates if state gets out of sync with actual file system.

### Pattern 3: Two-PC Air-Gap Bridge (Drop-Box)

**What:** Using intermediate SMB shared folders (`\To_Uni`, `\To_Local`) on an isolated LAN to pass files between two networks that cannot be bridged.
**When to use:** When strict network separation is required but automated data transfer is necessary, overcoming the reliability issues of toggling network adapters.
**Trade-offs:** Requires maintaining two physical/virtual machines and securing the local LAN (e.g., via Windows Firewall) to restrict traffic exclusively to file sharing.

## Data Flow

### Request Flow (A to Uni)

```
[WhatsApp Bot]
    ↓ (creates file)
[Documents\Sync] → [PCA_Watcher] → [SMB: \To_Uni]
                                        ↓
[University Network] ← [PCB_Watcher] ← [SMB: \To_Uni]
```

### Request Flow (Uni to A)

```
[University Network]
    ↓ (creates file)
[PCB_Watcher] → [SMB: \To_Local]
                    ↓
[Documents\Sync] ← [PCA_Watcher] ← [SMB: \To_Local]
    ↓ (updates)
[uni-sync-manifest.json]
```

### State Management & Echo Prevention

```
[Incoming File Event]
    ↓
[Check uni-sync-manifest.json]
    ├─ If tracked: Skip (Prevent Echo)
    └─ If untracked: Process & Add to Manifest
```

### Suggested Build Order

1. **Shared Core:** Logging and Config utilities to establish the foundation.
2. **State Management:** `uni-sync-manifest.json` read/write caching logic and echo prevention functions.
3. **PC A Component:** `PCA_Watcher.ps1` with `FileSystemWatcher` integration, including reading the WhatsApp manifest.
4. **PC B Component:** `PCB_Watcher.ps1` to handle the routing between the LAN drop folders and the University network.
5. **Deployment & CI:** Scheduled tasks and Windows Firewall lockdown scripts.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| < 100 files/day | Pure event-driven watcher is sufficient. |
| 1k+ files/day | Add bulk batching and debounce timers before moving files across the SMB share. |
| Large Files (GBs) | Implement temporary `.part` file extensions during transfer so watchers ignore incomplete writes. |

### Scaling Priorities

1. **First bottleneck:** Incomplete file reads. If PC B tries to read a file while PC A is still copying it over SMB, it will throw lock errors. Need to implement file-lock checking before copying.
2. **Second bottleneck:** Manifest JSON bloat. The `uni-sync-manifest.json` might grow indefinitely. Need a cleanup routine for files older than X days.

## Anti-Patterns

### Anti-Pattern 1: Adapater Toggling

**What people do:** Write scripts that disable the Wi-Fi adapter, enable the LAN adapter, copy files, and toggle back.
**Why it's wrong:** It is extremely unreliable, drops active downloads, triggers network timeout errors, and can accidentally bridge connections if scripts crash midway.
**Do this instead:** Use the Two-PC Drop-Box Architecture with static routing and isolated LANs.

### Anti-Pattern 2: Relying Solely on FileSystemWatcher

**What people do:** Assume `FileSystemWatcher` will catch 100% of file events.
**Why it's wrong:** The internal buffer can overflow during bulk operations, silently dropping events.
**Do this instead:** Combine `FileSystemWatcher` for real-time responsiveness with a periodic (e.g., every 5 minutes) full directory poll to catch missed files.

## Integration Points

### External Boundaries

| Boundary | Integration Pattern | Notes |
|----------|---------------------|-------|
| WhatsApp Bot | Reads `sync-manifest.json` | Read-only access to prevent corrupting the bot's state. |
| University Network | Standard OS File Copy | Requires appropriate permissions and mapped network drives on PC B. |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| PCA ↔ PCB | SMB File Sharing (`\To_Uni`, `\To_Local`) | Must be strictly firewall-isolated. Use explicit IP addresses rather than hostname resolution to avoid DNS leaks. |

## Sources

- [PROJECT.md Context]
- [PowerShell FileSystemWatcher Documentation]
- [Air-Gapped Network Design Principles]

---
*Architecture research for: Sync Bridge*
*Researched: 2026-07-11*
