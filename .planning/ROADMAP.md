# Project Roadmap

## Phase 1: Shared Core Infrastructure
- **Requirements:** SEC-01, SEC-02
- **Description:** Build the native PowerShell foundation, logging utilities, and establish the SMB mapping.
*(Note: This phase is already completed. The `Sync-Utils.ps1` foundation serves as the base for PC B).*

## Phase 2: Node.js Orchestrator Foundation (PC A)
- **Requirements:** INT-01
- **Depends on:** Phase 1
- **Description:** Initialize the Node.js project on PC A. Implement `chokidar` to flawlessly watch the WhatsApp bot drop folder. Set up the basic `fs-extra` utilities to push files and JSON instructions to PC B's Local Folder.

## Phase 3: SQLite Database & State Management (PC A)
- **Requirements:** INT-02, SYNC-03
- **Depends on:** Phase 2
- **Description:** Implement `better-sqlite3`. Create the `Files` table (with `is_synced` flag) and the `SyncJobs` table. Build the background loop that polls for `is_synced = false` and spawns new SyncJobs.

## Phase 4: Command & Acknowledge State Machine (PC A & PC B)
- **Requirements:** SYNC-01
- **Depends on:** Phase 3
- **Description:** Build the granular JSON protocol. Implement the worker loop on PC B (PowerShell) to read JSON instructions from its Local Folder, and the corresponding state-machine logic on PC A to parse acknowledgments and advance the `SyncJobs`. **Crucially, implement a synchronous handshake: PC A commands a network disconnect, PC B executes and acknowledges, and only then does PC A transfer the payload.**

## Phase 5: Switched Network Diode (PC B)
- **Requirements:** SYNC-02
- **Depends on:** Phase 4
- **Description:** Harden PC B's worker script to execute `Disable-NetAdapter` and `Enable-NetAdapter` around transfers to the Uni Shared Folder. **This implements the "Diode" action commanded by the Phase 4 handshake, ensuring the University network is physically disconnected before any file arrives on PC B's Local Folder.** Add try/catch/finally blocks to prevent permanent network lock-outs.

## Phase 6: Web UI Visualization (PC A)
- **Requirements:** UI-01
- **Depends on:** Phase 5
- **Description:** Build a lightweight web UI on top of the SQLite database to visualize the synchronization pipeline, showing pending jobs, active transfers, and historical errors.
