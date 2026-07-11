# Phase 01: Shared Core & Infrastructure Setup - Patterns

## Files to be Created/Modified

### 1. `config.json`
*   **Role:** Configuration file defining critical paths (local and network) and log file locations.
*   **Data Flow:** Read-only at script startup. Parsed natively by PowerShell (`ConvertFrom-Json`).
*   **Existing Analog:** `sync-manifest.json` (basic JSON structure).
*   **Concrete Code Excerpt** (from RESEARCH.md):
    ```json
    {
      "LocalSyncPath": "C:\\Users\\Emad\\Documents\\Sync",
      "SmbSharePath": "\\\\PC-B\\BridgeSync",
      "LogFilePath": "C:\\Users\\Emad\\Documents\\Sync\\bridge.log"
    }
    ```

### 2. `.env`
*   **Role:** Secure storage for SMB authentication credentials (username/password) to avoid hardcoding secrets.
*   **Data Flow:** Read securely by a custom `.env` PowerShell parser during the pre-flight routine.
*   **Existing Analog:** None (New pattern for this project).
*   **Concrete Code Excerpt** (Inferred standard `.env` format):
    ```env
    SMB_USERNAME=user
    SMB_PASSWORD=secure_password
    ```

### 3. `Test-NetworkIsolation.ps1`
*   **Role:** Pre-flight test script and immediate failure gatekeeper. Ensures the network share is accessible and readable/writable before watchers start.
*   **Data Flow:** Reads `config.json` and `.env`. Attempts an SMB connection (e.g., `New-SmbMapping`). Tests I/O on `SmbSharePath`. Fails and halts execution if disconnected.
*   **Existing Analog:** None (New Native PowerShell pattern).
*   **Concrete Code Excerpt** (Native Cmdlets Concept from RESEARCH.md):
    ```powershell
    # Native parsing constraint
    $config = Get-Content 'config.json' | ConvertFrom-Json
    ```

### 4. Core Utilities (e.g., `Sync-Utils.ps1` or similar logging/parsing module)
*   **Role:** Provides reusable `.env` parsing logic and a thread-safe file logger for asynchronous watcher tasks.
*   **Data Flow:** Included by other scripts. Writes formatted text entries to the `LogFilePath`.
*   **Existing Analog:** None (New pattern for this project).
*   **Concrete Code Excerpts** (from RESEARCH.md):
    ```powershell
    # Custom .env parsing
    Get-Content .env | Where-Object { $_ -match '=' } | ...
    
    # Detailed File Logging format
    # [YYYY-MM-DD HH:mm:ss] [LEVEL] Message
    # Concurrent-safe writing
    # [System.IO.File]::AppendAllText or Out-File -Append
    ```

### 5. `uni-sync-manifest.json` & `pcb-sync-manifest.json`
*   **Role:** Dual-manifest files for echo prevention and state tracking. Implements filename-only tracking.
*   **Data Flow:** Read at startup by sync watchers. Updated when new files are seen or transferred.
*   **Existing Analog:** `sync-manifest.json` (which already implements existence-based tracking).
*   **Concrete Code Excerpt** (from `sync-manifest.json`):
    ```json
    {
      "091E7_Screenshot 2026-06-05 085148.png": "true_120363428915737962@g.us_3EB026F037C5FE15C091E7_84143174107277@lid"
    }
    ```
