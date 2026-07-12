# Sync Bridge

## What This Is

Sync Bridge is a highly secure, uni-directional file synchronization system that moves files from an internet-facing WhatsApp bot drop folder (PC A) to a locked-down, air-gapped University network (PC B). It uses a granular Command & Acknowledge state machine protocol over a dedicated bridging LAN to ensure absolute security and reliability.

## Core Value

Securely transfer files across an air-gapped boundary using a Switched Network Diode mechanism, ensuring that the University network is physically disconnected from the transfer bridge during payload movement.

## Requirements

### Validated

- ✓ [SEC-01] PC B runs native PowerShell only to avoid triggering University EDR. — existing
- ✓ [SEC-02] Shared bridging connection established over SMB without installing third-party tools on PC B. — existing

### Active

- [ ] [INT-01] PC A runs a Node.js orchestrator that flawlessly watches the WhatsApp bot folder using `chokidar`.
- [ ] [INT-02] PC A maintains a SQLite database (`Files` and `SyncJobs` tables) tracking file hashes, sync states, and orchestration steps.
- [ ] [SYNC-01] File synchronization is managed through atomic JSON instructions dropped into PC B's Local Folder.
- [ ] [SYNC-02] PC B implements a Switched Network Diode (disables University network adapter, transfers file, re-enables adapter).
- [ ] [SYNC-03] The database directly tracks `is_synced` on the `Files` table to enable instant recovery on restart.
- [ ] [UI-01] Build a web UI on PC A to visualize the database state, sync jobs, and errors once the core pipeline is stable.

### Out of Scope

- [Pure P2P Sync Tools] — Tools like Syncthing or Resilio Sync are excluded because they don't support granular State Machine command architectures or Switched Network Diodes.
- [Node.js on PC B] — Installing runtimes on PC B is explicitly excluded to prevent EDR alerts on the University network.

## Context

The project is re-architecting from a pure-PowerShell peer-to-peer polling design into a "Node.js Master / PowerShell Worker" command-and-control design. The initial Phase 1 foundation (native PowerShell logging, environment handling, Pester testing) has already been built and is preserved to power the PC B worker.

## Constraints

- **Security**: Switched Network Diode — PC B must physically disconnect its University network adapter before processing files from the bridging LAN.
- **Environment**: Zero-Installation on PC B — The worker must be pure PowerShell 5.1+ to comply with strict University IT monitoring.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Node.js for Orchestration | `chokidar` provides superior event handling over Windows `FileSystemWatcher`, and `better-sqlite3` provides robust state tracking. | — Pending |
| Local Folder Command Queue | Placing the drop zone on PC B's Local Folder ensures PC A can orchestrate without relying on University server uptime. | — Pending |
| Two-Table DB Schema | Separating `Files` (truth) and `SyncJobs` (state machine) makes tracking, retries, and the future Web UI significantly easier. | — Pending |

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
*Last updated: 2026-07-12 after architecture pivot to Node.js Master-Worker*
