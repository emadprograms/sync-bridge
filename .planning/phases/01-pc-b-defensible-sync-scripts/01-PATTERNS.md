# Phase 01 Pattern Mapping: PC B Robust Sync Scripts

## 1. Files to Create/Modify
- `pc-b/WindowsBackupAgent.ps1` (or similar standard name): The native PowerShell background script for PC B.

## 2. Role and Data Flow Classification
- `pc-b/WindowsBackupAgent.ps1`:
  - **Role**: Background synchronizer (daemon).
  - **Data Flow**:
    - **Outbound (Local -> Shared Drive)**: Uses `FileSystemWatcher` on the local watched directory. Upon file creation or modification, applies an extension allowlist (e.g., jpg, png, docx, excel, ppt, pdf, videos) and a Try-Catch file-locking check to ensure the file is completely written, then copies it to the RDP shared drive.
    - **Inbound (Shared Drive -> Local)**: Uses a low-frequency fixed polling loop (e.g., 5-10 seconds) on the RDP shared drive directory to detect new files, minimizing network traffic while keeping CPU usage efficient. Copies new files to the local directory.
    - **Logging**: Standard error logging to an application log file (e.g., `C:\Temp\SyncUtilityCheck.log`).
    - **Execution**: Initialized via a Windows Scheduled Task on log-on, configured as a standard system backup task.

## 3. Closest Existing Analogs
- **Analog**: None.
- **Reasoning**: The codebase is currently empty of functional project files (only contains `.planning` documentation). This script will be built from scratch, leveraging standard PowerShell `System.IO.FileSystemWatcher` and polling mechanisms.

## 4. Concrete Code Excerpts
*(No existing code analogs to extract excerpts from, as this is a greenfield implementation.)*
