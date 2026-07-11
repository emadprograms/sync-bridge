# Phase 01: Shared Core & Infrastructure Setup - Research

## Objective
Establish the native PowerShell foundation, logging utilities, and the basic Two-PC drop-box architecture using isolated SMB shares. Provide answers to "What do I need to know to PLAN this phase well?".

## Key Constraints & Requirements
*   **Native PowerShell Only (SEC-01):** Must not use compiled executables (C# / PyInstaller) to strictly avoid EDR flags.
*   **Two-PC Drop-box Architecture (SEC-02):** Network communication is limited to an isolated local LAN using SMB.
*   **Fail Fast on Disconnect (D-03):** Network share disconnects must trigger an immediate script failure (no retries) to alert the user of bridge outages.
*   **Configuration & Secrets (D-07, D-10):**
    *   Paths and network share settings must be loaded from `config.json`.
    *   SMB credentials (username/password) must be loaded from a `.env` file securely without hardcoding.

## Technical Approaches & Considerations

### 1. EDR Evasion & Pure PowerShell
*   **Approach:** Rely exclusively on standard PowerShell cmdlets (`Test-Path`, `Get-Content`, `ConvertFrom-Json`, etc.). Avoid reflective DLL injection, `Add-Type` with inline C# if it involves suspicious network libraries, or obfuscated code.
*   **`Test-NetworkIsolation.ps1`:** This script should validate the setup without triggering alarms. It will likely perform basic read/write tests on the configured UNC paths and verify local paths.

### 2. SMB Authentication & Connection
*   **Approach:** Since the decision (D-01) is to use UNC paths (`\\PC-B\BridgeSync`) instead of mapped drives for stability, authentication can be handled via `New-SmbMapping` or `net use` under the hood if credentials are required. 
*   **`.env` Parsing:** PowerShell does not have a native `Get-Env` cmdlet that reads `.env` files for scripts out-of-the-box, so a custom utility function will be needed to parse the `.env` file (e.g., `Get-Content .env | Where-Object { $_ -match '=' } | ...`) to extract the SMB credentials.

### 3. Pre-flight Check & Immediate Failure
*   **Approach:** Before any watcher loop begins, a pre-flight routine must run. It should:
    1. Parse `config.json` for paths.
    2. Parse `.env` for credentials.
    3. Authenticate to the SMB share.
    4. Validate read/write permissions on `\\PC-B\BridgeSync` (e.g., by creating and deleting a temporary hidden file).
    *   If any step fails, the script must throw an error, log a critical message, and `exit` immediately.

### 4. Configuration Management
*   **Approach:** Create a standard structure for `config.json` defining properties like:
    ```json
    {
      "LocalSyncPath": "C:\\Users\\Emad\\Documents\\Sync",
      "SmbSharePath": "\\\\PC-B\\BridgeSync",
      "LogFilePath": "C:\\Users\\Emad\\Documents\\Sync\\bridge.log"
    }
    ```
*   PowerShell's `ConvertFrom-Json` will natively handle parsing this into a usable custom object.

### 5. Detailed File Logging
*   **Approach:** Implement a robust `Write-SyncLog` or similar function.
    *   Must handle concurrent writes or lock gracefully (using `Out-File -Append` or `[System.IO.File]::AppendAllText` with a `Mutex` or standard `try/catch` retry mechanism).
    *   Format: `[YYYY-MM-DD HH:mm:ss] [LEVEL] Message`.
    *   Essential for debugging asynchronous background tasks (D-08).

## Checklist for Planning
- [x] Design the structure of `config.json` and `.env` formats.
- [x] Plan the logic for the `.env` parser and config loader in PowerShell.
- [x] Plan the core logging module (`Write-Log` wrapper).
- [x] Plan the logic for `Test-NetworkIsolation.ps1` to handle the SMB authentication and pre-flight read/write checks.
- [x] Ensure all planned scripts abide by SEC-01 (native PowerShell).
