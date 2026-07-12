# Requirements

## Validated
- [SEC-01] PC B runs native PowerShell only to avoid triggering University EDR.
- [SEC-02] Shared bridging connection established over SMB without installing third-party tools on PC B.

## Active
- [INT-01] PC A runs a Node.js orchestrator that flawlessly watches the WhatsApp bot folder using `chokidar`.
- [INT-02] PC A maintains a SQLite database (`Files` and `SyncJobs` tables) tracking file hashes, sync states, and orchestration steps.
- [SYNC-01] File synchronization is managed through atomic JSON instructions dropped into PC B's Local Folder.
- [SYNC-02] PC B implements a Switched Network Diode (disables University network adapter, transfers file, re-enables adapter).
- [SYNC-03] The database directly tracks `is_synced` on the `Files` table to enable instant recovery on restart.
- [UI-01] Build a web UI on PC A to visualize the database state, sync jobs, and errors once the core pipeline is stable.
