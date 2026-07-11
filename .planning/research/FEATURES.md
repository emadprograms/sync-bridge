# Feature Research

**Domain:** Secure File Synchronization / Zero-Trust Bridge
**Researched:** 2026-07-11
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Bi-directional Synchronization | A "bridge" needs to pass data both ways (To_Uni and To_Local). | MEDIUM | Handled via drop-box folders on a local LAN. |
| Infinite Loop Prevention (Anti-Echo) | Prevents the system from ping-ponging the same file back and forth endlessly. | HIGH | Requires a memory cache or separate manifest to track what was synced. |
| Event-Driven Execution | Changes should sync quickly without needing manual triggers. | LOW | Easily achieved using `FileSystemWatcher` in PowerShell. |
| Robust Error Handling & Logging | Sync failures, network drops, or locked files shouldn't cause silent data loss. | MEDIUM | Needs file lock detection and retry logic. |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Strict Network Isolation | Achieves a pseudo-air-gap. Internet and university networks are never bridged simultaneously. | HIGH | Leverages a Two-PC architecture over an isolated local LAN. |
| 100% Native Implementation | Evades EDR/Windows Defender flags on locked-down campus endpoints. | MEDIUM | Pure PowerShell. No compiled C#/Python or external binaries. |
| Third-party Manifest Integration | Safely syncs files without breaking existing automations (WhatsApp bot). | HIGH | Cross-references `sync-manifest.json` using an independent `uni-sync-manifest.json`. |
| Zero-Trust Drop-Box Queuing | Uses intermediate folders (`\To_Uni`, `\To_Local`) instead of direct syncing. | LOW | Acts as a buffer/DMZ for file inspection or manual pausing. |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Compiled Executables (C#/Python) | Easier to develop, package, and deploy as background services. | High risk of triggering university endpoint protection/EDR. | 100% Native OS PowerShell scripts. |
| Single-PC Adapter Toggling | Cheaper, requires only one PC to toggle between Internet and University adapters. | Causes complex connection drops, OS routing confusion, and micro-bridges. | Two-PC Drop-Box Architecture via isolated LAN. |
| Cloud-based Sync (Dropbox, etc.) | Very easy to set up and highly reliable. | Explicitly violates university policy of bridging local networks to the public internet. | Local LAN P2P transfer only. |
| Block-level Differential Sync | Saves bandwidth for large files. | High complexity to implement in pure native PowerShell. | Simple whole-file copy for the drop-box model. |

## Feature Dependencies

```text
[Bi-directional Synchronization]
    └──requires──> [Infinite Loop Prevention]
                       └──requires──> [State Tracking / Manifest Memory Cache]

[Third-party Manifest Integration] ──enhances──> [State Tracking / Manifest Memory Cache]

[Two-PC Drop-Box Architecture]
    └──requires──> [Local LAN File Sharing]
    └──requires──> [Independent PC Watchers (PCA_Watcher, PCB_Watcher)]

[Single-PC Adapter Toggling] ──conflicts──> [Two-PC Drop-Box Architecture]
[Compiled Executables] ──conflicts──> [100% Native Implementation]
```

### Dependency Notes

- **[Bi-directional Synchronization] requires [Infinite Loop Prevention]:** Without anti-echo tracking, a file pushed to PC B will trigger PC B to push it back to PC A, creating an infinite loop.
- **[Third-party Manifest Integration] enhances [State Tracking / Manifest Memory Cache]:** By reading the WhatsApp bot's manifest, the bridge can smartly determine if a file is genuinely new or just part of the bot's own workflow.
- **[Single-PC Adapter Toggling] conflicts with [Two-PC Drop-Box Architecture]:** The project evolved explicitly away from single-PC toggling to avoid adapter state errors.

## MVP Definition

### Launch With (v1)

Minimum viable product — what's needed to validate the concept.

- [x] **Two-PC Drop-Box Architecture** — Foundation for strict network isolation without risky adapter toggling.
- [x] **100% Native Implementation (PowerShell)** — Essential to deploy on the university network without EDR flags.
- [x] **Bi-directional Synchronization** — Core capability (To_Uni / To_Local).
- [x] **Independent PC Watchers** — `PCA_Watcher.ps1` and `PCB_Watcher.ps1` for queue management.
- [x] **Infinite Loop Prevention** — Critical to prevent network flooding via ping-ponging files.

### Add After Validation (v1.x)

Features to add once core is working.

- [ ] **Third-party Manifest Integration** — To safely integrate with the WhatsApp bot without corrupting `sync-manifest.json`.
- [ ] **Enhanced Error Recovery** — Retry logic for files locked by other processes.

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] **File Filtering / Inspection** — Anti-virus scanning of the DMZ drop-box before bringing files fully into the university network.
- [ ] **Bandwidth Throttling** — To prevent saturating the local LAN during very large sync operations.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Two-PC Drop-Box Architecture | HIGH | MEDIUM | P1 |
| 100% Native Implementation | HIGH | LOW | P1 |
| Bi-directional Synchronization | HIGH | LOW | P1 |
| Infinite Loop Prevention | HIGH | HIGH | P1 |
| Independent PC Watchers | HIGH | MEDIUM | P1 |
| Third-party Manifest Integration | HIGH | HIGH | P2 |
| Enhanced Error Recovery | MEDIUM | LOW | P2 |
| File Filtering / Inspection | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Cloud Sync (OneDrive/Dropbox) | Syncthing | Our Approach (Sync Bridge) |
|---------|-------------------------------|-----------|----------------------------|
| **Network Isolation** | Fails (requires internet) | Configurable, but uses binaries | **Strict isolation via local LAN only, pure native** |
| **Deployment** | Installed Binary | Installed Binary | **Portable PowerShell scripts, invisible to EDR** |
| **Bot Integration** | Hard / API required | Ignored | **Directly parses & updates local JSON manifests** |
| **Anti-Echo** | Built-in | Built-in | **Custom memory cache to handle bi-directional push/pull safely** |

## Sources

- `.planning/PROJECT.md` (Project Context & Decisions)
- University Network Security Policies (Constraint References)

---
*Feature research for: Secure File Synchronization / Zero-Trust Bridge*
*Researched: 2026-07-11*
