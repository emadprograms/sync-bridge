# Sync Bridge

## What This Is

Sync Bridge is a reliable, bi-directional file synchronization utility that moves files between a staging area (PC A) and an enterprise network environment (PC B). It uses a persistently mapped RDP Drive tunnel and simple, event-driven file drops to maintain compliance with standard administrative practices. Note: This repository strictly contains the PowerShell synchronization logic for PC B. External tools are handled in separate repositories.

## Core Value

Transfer files bi-directionally across network boundaries using natively allowed Windows features (RDP Drive Redirection and native PowerShell background scripts) without requiring the installation of any third-party software on the enterprise machine.

## Architecture

The system consists of two completely independent, event-driven chains:

### Chain 1: Inbound (Staging -> PC B)
1. **PC B (PowerShell):** A single background script polls `\\tsclient\C\...\Staging_In` on a set interval. When found, it copies the file to the local folder using robust stream processing (`Get-Content | Set-Content`) for reliability, then deletes it from staging.

### Chain 2: Outbound (PC B -> Staging)
1. **PC B (PowerShell):** The background script uses a native `FileSystemWatcher` (event-driven) on the local `Outbound` folder. When a file is dropped, it instantly triggers a push across the tunnel to `\\tsclient\C\...\Staging_Out` and deletes the local copy.

## Constraints

- **Design Philosophy**: The scripts on PC B must follow standard file backup script patterns. They should prioritize simplicity and avoid complex parsing to maintain readability and adherence to standard practices.
- **Resource Efficiency**: PC B avoids process-creation overhead by using one long-running background script instead of high-frequency Scheduled Tasks. It ensures reliable file copying by using byte-stream copying (`Get-Content` to `Set-Content`).
- **Environment**: Zero-Installation on PC B — The worker must be pure PowerShell 5.1+ to comply with enterprise IT policies.

---
*Last updated: 2026-07-13 after pivoting to a simplified, database-free, event-driven RDP architecture.*
