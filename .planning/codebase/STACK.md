# Technology Stack

## Languages
*   **JavaScript (CommonJS)**: Used for the main orchestrator (Master on PC A).
*   **Windows PowerShell (5.1+)**: Used for the worker scripts (PC B) to strictly comply with zero-installation and EDR constraints on the University network.

## Runtimes
*   **Node.js**: Executes the main orchestrator.
*   **Windows PowerShell**: Executes the worker and networking scripts natively.

## Frameworks & Libraries
*   **chokidar** (`^5.0.0`): Provides superior file system event watching over native Windows solutions on the orchestrator.
*   **fs-extra** (`^11.3.6`): Used for atomic file transfers and extended file system operations.
*   **uuid** (`^14.0.1`): Generates unique identifiers for transfer jobs.
*   **better-sqlite3** *(Planned/Intended)*: Specified in requirements for state tracking via `Files` and `SyncJobs` tables.

## Configuration
*   `config.json`: The main application configuration, defining paths for drop folders, sync locations, and log files. (Gitignored)
*   `.env`: Manages secrets securely, specifically SMB authentication credentials (`SMB_USERNAME`, `SMB_PASSWORD`). (Gitignored)

---
*Last updated: 2026-07-13*
