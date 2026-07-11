# Project Roadmap

## Phase 1: Shared Core & Infrastructure Setup
- **Requirements:** SEC-01, SEC-02
- **Description:** Establish the native PowerShell foundation, logging utilities, and the basic Two-PC drop-box architecture using isolated SMB shares.

**Success Criteria:**
- [ ] `Test-NetworkIsolation.ps1` script successfully runs without triggering EDR.
- [ ] SMB shared folder (`\BridgeSync`) is successfully mapped and verified accessible via pure PowerShell.
- [ ] Core logging module writes a formatted entry to a local log file without errors.

## Phase 2: PC A Component (Local Gateway)
- **Requirements:** INT-01, INT-02
- **Depends on:** Phase 1
- **Description:** Develop the local PC watcher (`PCA_Watcher.ps1`) to parse the WhatsApp bot's manifest read-only, handle file lock collisions gracefully, and push files to the LAN drop-box.

**Success Criteria:**
- [ ] `PCA_Watcher.ps1` successfully reads `sync-manifest.json` without placing a read lock that disrupts simulated WhatsApp bot writes.
- [ ] When a simulated bot actively locks a file for writing, `PCA_Watcher.ps1` gracefully catches the `IOException` and retries without throwing a terminating error.
- [ ] Validated new files identified in the WhatsApp manifest are successfully copied to the `\BridgeSync` shared folder.

## Phase 3: PC B Component (Bridge Manager)
- **Requirements:** SYNC-01
- **Depends on:** Phase 1
- **Description:** Develop the bridge PC watcher (`PCB_Watcher.ps1`) to route files between the LAN drop-box and the University network securely.

**Success Criteria:**
- [ ] `PCB_Watcher.ps1` successfully synchronizes a test file from `\BridgeSync` into the designated University destination folder.
- [ ] `PCB_Watcher.ps1` successfully synchronizes a test file from the University source into the `\BridgeSync` shared folder.
- [ ] Files transferred maintain integrity and are correctly logged during transit.

## Phase 4: State Management & Echo Prevention Core
- **Requirements:** SYNC-02
- **Depends on:** Phase 2, Phase 3
- **Description:** Implement the JSON state tracking read/write logic (`uni-sync-manifest.json` and `pcb-sync-manifest.json`) to track the synchronization state, recover from network drops, and prevent the system from getting stuck in an infinite echo loop.

**Success Criteria:**
- [ ] `Get-SyncState` returns a parsed object from a given state tracking JSON.
- [ ] `Set-SyncState` successfully updates the tracking JSON with a new file identifier.
- [ ] `Test-IsEchoLoop` correctly returns `$true` for a recently synced file, preventing a re-sync.

## Phase 5: Event-Driven Queueing & Deployment
- **Requirements:** SYNC-03
- **Depends on:** Phase 2, Phase 3, Phase 4
- **Description:** Upgrade watchers to use `FileSystemWatcher` for immediate event-driven syncing, with fallback polling for robustness, and harden them into Windows Scheduled Tasks.

**Success Criteria:**
- [ ] File drops instantly trigger processing via `FileSystemWatcher` instead of waiting for a timer interval.
- [ ] Disconnecting the SMB network share forces watchers into a fallback polling/retry loop, and reconnecting resumes normal operation.
- [ ] Both watchers successfully run persistently in the background via Windows Task Scheduler.
