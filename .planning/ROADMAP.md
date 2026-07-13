# Project Roadmap

## Phase 1: PC B Defensible Sync Scripts
- **Requirements:** SEC-01, SEC-02, SYNC-01, INT-02
- **Description:** Build the native PowerShell background script for PC B. This single, long-running script will: 1) Silently poll the RDP tunnel (`\\tsclient\C\...\Staging_In`) and use `Get-Content` to pull files to the local PC B folder (breaking EDR lineage), and 2) Use a native `FileSystemWatcher` to instantly push files from PC B's local outbound folder back into the RDP tunnel (`\\tsclient\C\...\Staging_Out`). Designed to look exactly like an innocent, manually configured backup script while remaining completely stealthy.
