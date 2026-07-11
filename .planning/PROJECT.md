# Sync Bridge

## What This Is

An event-driven, bi-directional file synchronization bridge that securely links a local PC to a university network without ever bridging the two networks simultaneously. It leverages a dual-folder drop-box architecture on a local LAN to push and pull files safely, maintaining strict network isolation.

## Core Value

Zero-trust file synchronization that completely eliminates the risk of bridging the internet and the university network, while remaining entirely native (no third-party executables).

## Requirements

### Validated

- ✓ Native OS Implementation — Windows PowerShell scripts, no PyInstaller or external binaries.
- ✓ Strict Network Separation — No simultaneous connections bridging internet and university networks.
- ✓ Event-Driven Gatekeeping — Network toggling occurs only when explicitly necessary.
- ✓ Avoid Infinite Echo Loops — System must intelligently track files synced to prevent ping-ponging them back across the bridge.
- ✓ WhatsApp Manifest Integration — Sync tracking must cross-reference `sync-manifest.json` from the local WhatsApp downloader script to avoid disrupting existing local bot behaviors.

### Active

- [ ] **Phase 2:** Create `PCA_Watcher.ps1` for the local PC to watch `Documents\Sync` and handle the local-to-LAN queue. *(Depends on Phase 1)*
- [ ] **Phase 3:** Create `PCB_Watcher.ps1` for the bridge PC to handle LAN-to-University and University-to-LAN queue management. *(Depends on Phase 1)*
- [ ] **Phase 4:** Implement the `uni-sync-manifest.json` and `pcb-sync-manifest.json` state tracking logic to track pushed/pulled files and prevent echo loops. *(Depends on Phase 2 & 3 — requires real watchers to test against)*
- [ ] **Phase 5:** Upgrade watchers to event-driven (`FileSystemWatcher`) and harden via Windows Scheduled Tasks. *(Depends on Phase 2, 3 & 4)*

### Out of Scope

- Compiled C# / Python runtimes — Explicitly avoided to prevent EDR/Windows Defender flags.
- Single PC Adapter Toggling — The architecture evolved from a single PC toggling adapters to a two-PC drop-box setup over a local LAN for better reliability.

## Context

The user maintains a local folder (`Documents\Sync`) that receives files from a WhatsApp bot (tracked in `sync-manifest.json`). These files must securely sync to a University network share. The University network strictly forbids bridging with the public internet. 
A two-PC architecture is deployed:
- PC A: Internet + Local LAN (hosts the local folder).
- PC B: University Network + Local LAN (hosts the single `\BridgeSync` intermediate shared folder).
The challenge is keeping the folders perfectly synced while maintaining isolation and preventing the WhatsApp bot's JSON manifest from getting corrupted by the bridge's tracking state.

## Constraints

- **Tech stack**: Native PowerShell — To avoid triggering campus endpoint security tools.
- **Security**: Windows Firewall — Local LAN traffic between PC A and PC B must be locked down to file sharing only.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Two-PC Drop-Box Architecture | Eliminates complex adapter toggling and connection dropping errors on network shares. | — Pending |
| Separate Tracking Manifests | Using a separate `uni-sync-manifest.json` while reading `sync-manifest.json` prevents breaking the existing WhatsApp bot. | — Pending |
| In-Memory Cache for Echo Prevention | Both PC A and PC B require state tracking JSONs (`uni-sync-manifest.json` and `pcb-sync-manifest.json`) to realize when they just pushed a file, and to recover from network drops. | — Pending |
| Phase Reorder (State Mgmt → Phase 4) | State Management & Echo Prevention (originally Phase 2) moved to Phase 4. PC A and PC B watchers must exist to meaningfully test echo prevention end-to-end. | 2026-07-11 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-07-11 — phase order resequenced; State Management moved to Phase 4*
