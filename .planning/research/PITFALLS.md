# Pitfalls Research

**Domain:** Event-Driven File Synchronization Bridge
**Researched:** 2026-07-11
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Infinite Echo Loops (Ping-Ponging)

**What goes wrong:**
A file pulled from the University network to the Local PC is detected as a "new" file by the Local PC's watcher, and is subsequently pushed back to the University network, continuing endlessly.

**Why it happens:**
Lack of state awareness in the bi-directional file watchers. The watchers treat all file creations or modifications as user actions rather than the result of a recent synchronization event.

**How to avoid:**
Implement an in-memory cache and a distinct state-tracking file (`uni-sync-manifest.json`). When a file is synced by the script, its identifier (name, size, and modified timestamp) must be logged in the manifest *before* or *immediately as* it is dropped. The receiving watcher checks this manifest and ignores events for recently synced files.

**Warning signs:**
High CPU usage on both PC A and PC B, rapid updates to file timestamps, saturation of local LAN bandwidth, and identical files duplicating with `(1)`, `(2)` appended to their names.

**Phase to address:**
Core Sync Engine Implementation (MVP)

---

### Pitfall 2: Manifest Corruption / Bot Conflict

**What goes wrong:**
The WhatsApp downloader bot and the Sync Bridge script attempt to read and write the `sync-manifest.json` file simultaneously, leading to JSON corruption, truncated files, or access-denied locking errors.

**Why it happens:**
Windows enforces strict file locks during write operations. PowerShell's `ConvertFrom-Json` or `Out-File` operations lack built-in retry mechanisms for locked files.

**How to avoid:**
Treat the WhatsApp bot's `sync-manifest.json` as **strictly read-only** from the perspective of the Sync Bridge. Maintain a completely separate tracking manifest (`uni-sync-manifest.json`) for the bridge's internal state. When reading the bot's manifest, implement a retry loop catching `IOException` (File in use).

**Warning signs:**
WhatsApp bot crashing unexpectedly, zero-byte JSON files appearing in the directory, and `ConvertFrom-Json` exceptions in the PowerShell console.

**Phase to address:**
Manifest Integration & Local Queue Management

---

### Pitfall 3: Security Tooling (EDR) False Positives

**What goes wrong:**
The University's Endpoint Detection and Response (EDR) or Windows Defender flags the bridge scripts as malicious, killing the processes or quarantining the scripts.

**Why it happens:**
Heuristics detect unusual behavior: compiled wrappers (like PyInstaller/C#), obfuscated scripts, continuous aggressive network scanning, or unverified executables touching network shares.

**How to avoid:**
Stick strictly to native, clean, and unobfuscated PowerShell. Avoid packing or compiling scripts. Ensure that PowerShell watchers use standard OS event hooks (e.g., `System.IO.FileSystemWatcher`) rather than aggressive `while($true)` polling loops.

**Warning signs:**
Scripts terminating silently, files disappearing into quarantine, or the University IT department reaching out regarding suspicious network activity.

**Phase to address:**
Architecture & Deployment Hardening

---

### Pitfall 4: Network State Ambiguity / Silent Failures

**What goes wrong:**
PC B (the bridge) loses its connection to the University network but continues pulling files from the Local PC, queuing them endlessly without alerting the user, or failing to move them silently.

**Why it happens:**
Assuming the network share is always available and failing to perform pre-flight checks before attempting file operations.

**How to avoid:**
Implement explicit network reachability checks (`Test-Path` on the UNC path) before moving a file from a drop-box to its final destination. If unreachable, the script should safely queue the file and retry with an exponential backoff.

**Warning signs:**
Files piling up indefinitely in the `\To_Uni` intermediate drop-folder; users believing files are synced when they are isolated on the bridge PC.

**Phase to address:**
Bridge Queue Management (PCB_Watcher)

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Polling instead of Event-Driven | Easier to code in PowerShell | High CPU usage, latency, and increased likelihood of EDR flagging | Prototyping MVP only |
| Storing sync state in memory only | Avoids managing a JSON file | State is lost on script restart, leading to immediate echo loops of all files | Never |
| Hardcoding UNC paths | Faster initial setup | Breaks instantly when deploying to different user profiles or rebuilding PCs | Never |

## Integration Gotchas

Common mistakes when connecting to external services and network shares.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Windows SMB/File Share | Assuming the UNC share is always mounted and available | Perform a pre-check `Test-Path` on the UNC path with retries before operating |
| WhatsApp Bot Manifest | Overwriting the bot's JSON file to update sync status | Use read-only access to the bot's manifest; maintain a separate sync state |
| `FileSystemWatcher` | Relying purely on events without a fallback | Events can be dropped under high load; use a periodic fallback reconciliation sweep |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Unbounded in-memory history tracking | Memory usage grows linearly over time | Use a rolling window, size-capped queue, or prune logs older than 30 days | > 10,000 files synced |
| Hashing every file for deduplication | Extremely slow sync times for large files (e.g., videos) | Use File Size + LastWriteTime as a proxy for Hash | Files > 100MB |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Over-permissive Firewall Rules | PC B could accidentally route internet traffic directly to the University | Lock down Windows Firewall on PC B to specific IPs and SMB-only ports |
| Blindly executing synced scripts | Synced files could contain malware that runs automatically | The Bridge must only *move* files, absolutely never execute them |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No sync status indicator | User doesn't know if a file successfully reached the University | Write a simple local log or status toast notification on PC A |
| Silent collision resolution | User loses their local version of a file without knowing | Append `_conflict_[timestamp]` to colliding files instead of overwriting |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **File Movement:** Often missing atomic file moves — verify files aren't read by the receiver while still being written by the sender.
- [ ] **Error Handling:** Often missing retry logic for file locks — verify the script gracefully waits if a file is currently open in another app (like Word or Excel).
- [ ] **Path Lengths:** Often missing long-path support — verify deep directory structures don't break Windows MAX_PATH limits.
- [ ] **Event Dropping:** Often missing reconciliation — verify that if the script misses a `FileSystemWatcher` event, the file still syncs eventually.

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Infinite Echo Loop | HIGH | Kill watcher processes, clear intermediate drop-folders (`\To_Uni`, `\To_Local`), rebuild the tracking manifest, restart watchers. |
| Corrupted Manifest | MEDIUM | Restore manifest from backup, or regenerate it by forcefully re-scanning the synchronized directory. |
| False Positive EDR block | LOW | Submit script hash to IT as a false positive; refactor PowerShell to use more benign patterns (e.g., standard cmdlets over raw .NET reflection). |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Infinite Echo Loop | Core Sync Engine / State Tracking | Push a file manually and verify it does not bounce back after arriving. |
| Manifest Corruption | WhatsApp Bot Integration | Run the downloader bot and sync bridge simultaneously with high file volume. |
| Silent Network Failure | Error Handling & Resiliency | Unplug the network cable, attempt a sync, and verify files queue safely without data loss. |
| Atomic File Transfers | Core Sync Engine | Attempt to copy a massive file (e.g., 5GB video) and ensure the other side doesn't attempt to move it until the copy completes. |

## Sources

- Project requirements (`.planning/PROJECT.md`)
- Known behaviors of Windows `FileSystemWatcher`
- General network engineering and dual-homed isolation principles
- File locking and contention best practices in PowerShell

---
*Pitfalls research for: Sync Bridge*
*Researched: 2026-07-11*
