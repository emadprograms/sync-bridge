# Project Roadmap

## Phase 1: PC B Robust Sync Scripts

- **Requirements:** SEC-01, SEC-02, SYNC-01, INT-02
- **Description:** Build the native PowerShell background script for PC B. This single, long-running script will: 1) Poll the RDP tunnel (`\\tsclient\C\...\Staging_In`) and use `Get-Content` to copy files to the local PC B folder (for robust stream processing), and 2) Use a native `FileSystemWatcher` to instantly push files from PC B's local outbound folder back into the RDP tunnel (`\\tsclient\C\...\Staging_Out`).
