# Phase 1: Shared Core & Infrastructure Setup

## Goal
Establish the native PowerShell foundation, logging utilities, and the basic Two-PC drop-box architecture using isolated SMB shares. Provide answers to "What do I need to know to PLAN this phase well?".

<threat_model>
- **Threat (T-01-01)**: EDR detection and flagging of syncing processes.
  - **Mitigation**: Strictly use native PowerShell cmdlets for all network mapping and file system operations without reflective DLL injection or compiled executables.
  - **Risk Level**: High
- **Threat (T-01-02)**: Hardcoded secrets and credential leakage in the codebase.
  - **Mitigation**: Store SMB credentials in a local `.env` file that is parsed dynamically and excluded from version control. 
  - **Risk Level**: High
</threat_model>

## Testing Boundary

> **DEV MACHINE ONLY:** All files in `Tests/` (Pester) run exclusively on the developer's local machine. They must never be deployed or executed on the university network. Production scripts (`Sync-Utils.ps1`, `Test-NetworkIsolation.ps1`) use **zero external module dependencies** — native PowerShell cmdlets only.

## Wave 0: Validation & Test Setup
- **W0-01**: Initialize testing infrastructure for Core Utilities.
  - *Action*: Create `Tests/CoreUtils.Tests.ps1` with Pester test stubs for the logging and configuration utilities.
  - *Note*: Dev machine only. Requires Pester module (`Install-Module Pester`).
- **W0-02**: Initialize testing infrastructure for Network Isolation.
  - *Action*: Create `Tests/NetworkIsolation.Tests.ps1` with Pester test stubs for validating SMB credential parsing, share I/O checks, and pre-flight tests.
  - *Note*: Dev machine only. Requires Pester module (`Install-Module Pester`).

## Wave 1: Core Configuration and Utilities (Task 01-01-01)
- **Task 01-01-01**: Implement Core Configuration & Logger (`Sync-Utils.ps1`, `config.json`, `.env` parsing, `.gitignore` update)
  - *Requirement*: SEC-01
  - *Description*: 
    - Create `config.json` containing properties for `LocalSyncPath`, `SmbSharePath`, and `LogFilePath`.
    - Create an example `.env` file (`.env.example`) containing keys for `SMB_USERNAME` and `SMB_PASSWORD`.
    - Update `.gitignore` to explicitly exclude the `.env` file from version control (Mitigation for T-01-02).
    - Develop `Sync-Utils.ps1` featuring a thread-safe `Write-SyncLog` function (using `Out-File -Append` or `[System.IO.File]::AppendAllText` with standard error catching).
    - Implement a custom `.env` parsing function in `Sync-Utils.ps1` to read `.env` securely without custom modules.
  - *Validation*: Automated tests via `Invoke-Pester -Path ./Tests/CoreUtils.Tests.ps1`. Core logging module writes a formatted entry to a local log file without errors.

## Wave 2: Pre-flight Verification Script (Task 01-01-02)
- **Task 01-01-02**: Implement Pre-flight Connection Checker (`Test-NetworkIsolation.ps1`)
  - *Requirement*: SEC-02
  - *Description*: 
    - Create `Test-NetworkIsolation.ps1` acting as the pre-flight gatekeeper.
    - Parse `config.json` and `.env` securely.
    - Test SMB share reachability (using `\\PC-B\BridgeSync` via standard PowerShell cmdlets).
    - Perform a temporary hidden file I/O test on the remote share.
    - Implement immediate failure (no retries) if the connection is dropped, writing a critical error to the log file.
  - *Validation*: Automated tests via `Invoke-Pester -Path ./Tests/NetworkIsolation.Tests.ps1`. Script successfully runs without triggering EDR and fails quickly on a bad network share configuration.

## Out of Scope for this Phase
- **Scheduled Tasks Registration (D-09)**: Launching scripts using Windows Scheduled Tasks (at logon/system) to ensure persistence is deferred. The task registration utilities will be built in a later phase when the actual synchronization watchers are developed and ready to be deployed.
