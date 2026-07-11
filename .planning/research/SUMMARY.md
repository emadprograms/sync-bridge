# Project Research Summary

**Project:** Sync Bridge
**Domain:** Event-Driven Air-Gapped File Synchronization
**Researched:** 2026-07-11
**Confidence:** HIGH

## Executive Summary

The Sync Bridge is an event-driven, air-gapped file synchronization system designed to securely pass data between a local PC (connected to the internet) and a university network. To avoid the unreliability of single-PC adapter toggling and the strict security policies of the university, it leverages a Two-PC Drop-Box architecture operating over a strictly firewalled, isolated local LAN.

The recommended approach is a 100% native PowerShell implementation. By using built-in Windows capabilities like `System.IO.FileSystemWatcher` for event-driven queue management and SMB for the transport layer, the solution evades endpoint detection and response (EDR) systems or Windows Defender flags that typically block compiled executables or third-party sync tools on locked-down campus endpoints. 

Key risks include infinite echo loops (ping-ponging files back and forth), manifest corruption by concurrent reads/writes with an external WhatsApp bot, and silent network failures. These are mitigated by using an in-memory split-brain state tracking (`uni-sync-manifest.json`), maintaining strict read-only access to the bot's manifest, and explicitly checking network reachability before file operations.

## Key Findings

### Recommended Stack

The chosen stack avoids third-party executables and compiled runtimes to minimize the risk of triggering campus endpoint security. 

**Core technologies:**
- **PowerShell 5.1+**: Core scripting and execution engine — Native to all modern Windows environments, ensuring maximum compatibility without triggering EDR.
- **SMB (Windows File Sharing) v3.x**: Transport layer — Built-in Windows capability for local LAN file sharing, supporting strict firewall isolation.
- **Windows Task Scheduler**: Process daemon — Allows persistent background execution of the PowerShell watcher scripts without requiring third-party daemon services.

### Expected Features

The MVP definition focuses on core functionality to validate the concept, with advanced features deferred to later versions.

**Must have (table stakes):**
- **Bi-directional Synchronization** — Essential for passing data both ways (To_Uni and To_Local).
- **Infinite Loop Prevention (Anti-Echo)** — Prevents the system from infinitely ping-ponging the same file back and forth.
- **Event-Driven Execution** — Changes should sync quickly without needing manual triggers.
- **Independent PC Watchers** — `PCA_Watcher.ps1` and `PCB_Watcher.ps1` for queue management.

**Should have (competitive):**
- **Strict Network Isolation** — Achieves a pseudo-air-gap via the Two-PC architecture.
- **100% Native Implementation** — Pure PowerShell to evade EDR.
- **Third-party Manifest Integration** — Safely syncs files without breaking existing automations (WhatsApp bot).

**Defer (v2+):**
- **File Filtering / Inspection** — Anti-virus scanning of the DMZ drop-box before bringing files fully into the university network.
- **Bandwidth Throttling** — Preventing LAN saturation during large syncs.

### Architecture Approach

The architecture relies on an Event-Driven Gateway and a Bridge Manager communicating over shared intermediate drop folders.

**Major components:**
1. **`PCA_Watcher.ps1` (Local Gateway)** — Monitors local sync folder, pushes/pulls to/from LAN drop folders, tracks manifest.
2. **`PCB_Watcher.ps1` (Bridge Manager)** — Monitors LAN drop folders, moves files to/from the University Network.
3. **SMB Drop Folders (`\To_Uni`, `\To_Local`)** — Intermediate storage buffering files across the isolated LAN.
4. **`uni-sync-manifest.json`** — Distinct tracking state memory cache to prevent echo loops.

### Critical Pitfalls

There are several severe pitfalls in this domain that require specific architectural mitigations.

1. **Infinite Echo Loops (Ping-Ponging)** — Avoid by implementing a distinct state-tracking file (`uni-sync-manifest.json`) and checking it before syncing files.
2. **Manifest Corruption / Bot Conflict** — Avoid by treating the WhatsApp bot's `sync-manifest.json` as strictly read-only and using a retry loop for `IOException` access-denied locking errors.
3. **Security Tooling (EDR) False Positives** — Avoid by strictly using native, unobfuscated PowerShell and avoiding aggressive polling loops.
4. **Network State Ambiguity / Silent Failures** — Avoid by explicitly verifying network reachability (`Test-Path`) with exponential backoff before file operations.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Shared Core & Infrastructure Setup
**Rationale:** Establishes foundation for logging, configuration, and secure network transport before implementing complex logic.
**Delivers:** Configuration loading, logging utilities, mapped SMB drop folders (`\To_Uni`, `\To_Local`), firewall restrictions.
**Addresses:** Strict Network Isolation.
**Avoids:** Over-permissive Firewall Rules, Hardcoding UNC paths.

### Phase 2: State Management & Echo Prevention Core
**Rationale:** Must be built before bi-directional syncing to prevent immediate infinite loops.
**Delivers:** `uni-sync-manifest.json` read/write caching logic and echo prevention functions.
**Uses:** PowerShell `ConvertFrom-Json` / `ConvertTo-Json`.
**Implements:** `uni-sync-manifest.json` state tracking.

### Phase 3: PC A Component (Local Gateway)
**Rationale:** Implements the internet-facing side of the bridge and handles WhatsApp bot integration.
**Delivers:** `PCA_Watcher.ps1` with `FileSystemWatcher` integration and read-only manifest parsing.
**Addresses:** Bi-directional Synchronization, Third-party Manifest Integration.
**Avoids:** Manifest Corruption / Bot Conflict.

### Phase 4: PC B Component (Bridge Manager)
**Rationale:** Connects the LAN drop folders to the final University Network destination.
**Delivers:** `PCB_Watcher.ps1` to route files securely.
**Addresses:** Event-Driven Execution, Robust Error Handling.
**Avoids:** Network State Ambiguity / Silent Failures.

### Phase 5: Deployment, Testing & Hardening
**Rationale:** Finalizes the system for persistent, reliable execution without user intervention.
**Delivers:** Scheduled tasks XMLs, test scripts, complete error handling.
**Addresses:** 100% Native Implementation.
**Avoids:** Security Tooling (EDR) False Positives.

### Phase Ordering Rationale

- Core infrastructure and state management must precede watcher implementation to avoid catastrophic echo loops immediately upon launch.
- PC A is built before PC B as it deals with the more complex third-party integration (WhatsApp manifest).
- Deployment is separated to ensure all components can run natively without EDR interference before backgrounding them.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3:** Complex integration. Requires handling file locks when reading the third-party WhatsApp manifest while it's actively downloading files. Needs careful implementation of robust error recovery.
- **Phase 4:** Requires robust handling of UNC paths and pre-flight connectivity checks in PowerShell.

Phases with standard patterns (skip research-phase):
- **Phase 1 & 2:** Well-documented, standard PowerShell patterns for configuration, file handling, and JSON manipulation.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Relies on well-known, established built-in Windows components. |
| Features | HIGH | Clearly prioritized based on known constraints and MVP goals. |
| Architecture | HIGH | Addresses air-gap needs cleanly via decoupled watchers. |
| Pitfalls | HIGH | Highly specific operational risks mapped to structural solutions. |

**Overall confidence:** HIGH

### Gaps to Address

- **FileSystemWatcher Drop Rates**: The frequency at which `FileSystemWatcher` might drop events under the WhatsApp bot's specific download load is unknown. This may necessitate fallback polling mechanisms (e.g. `Get-ChildItem`) during execution. Needs validation during implementation.

## Sources

### Primary (HIGH confidence)
- `.planning/research/STACK.md` — Technology choices and constraints.
- `.planning/research/FEATURES.md` — Product requirements and MVP definition.
- `.planning/research/ARCHITECTURE.md` — System design and data flow.
- `.planning/research/PITFALLS.md` — Operational risks and mitigations.

---
*Research completed: 2026-07-11*
*Ready for roadmap: yes*
