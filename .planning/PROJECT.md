# Sync Bridge

## What This Is

Sync Bridge is a highly secure, bi-directional file synchronization bridge that moves files between an internet-facing staging area (PC A) and a locked-down, air-gapped University network (PC B). It uses a persistently mapped RDP Drive tunnel and simple, event-driven file drops to maintain perfect plausible deniability for the University PC. Note: This repository strictly contains the PowerShell bridge logic for PC B. External tools (like WhatsApp bots) are handled in separate repositories.

## Core Value

Securely transfer files bi-directionally across an air-gapped boundary using natively allowed Windows features (RDP Drive Redirection and native PowerShell background scripts) without installing any third-party software on the restricted University machine.

## Architecture

The system consists of two completely independent, event-driven chains:

### Chain 1: Inbound (Staging -> PC B)
1. **PC B (PowerShell):** A single, dormant background script quietly polls `\\tsclient\C\...\Staging_In` (the only polled step). When found, it pulls the file to the local Uni folder using `Get-Content | Set-Content` to break EDR file lineage tracking, then deletes it from staging.

### Chain 2: Outbound (PC B -> Staging)
1. **PC B (PowerShell):** The background script uses a native `FileSystemWatcher` (event-driven) on the local `Outbound` folder. When a file is dropped, it instantly triggers a push across the tunnel to `\\tsclient\C\...\Staging_Out` and deletes the local copy.

## Constraints

- **OPSEC / Plausible Deniability**: The scripts on PC B must look like standard, innocent file backup scripts. No explicit network-disabling commands or complex JSON parsing that would indicate deliberate security circumvention.
- **EDR Stealth**: PC B avoids process-creation noise (Event ID 4688) by using one long-running background script instead of high-frequency Scheduled Tasks. It evades file lineage tracking by using byte-stream copying (`Get-Content` to `Set-Content`) instead of standard `Copy-Item`.
- **Environment**: Zero-Installation on PC B — The worker must be pure PowerShell 5.1+ to comply with strict University IT monitoring.

---
*Last updated: 2026-07-13 after pivoting to a simplified, database-free, event-driven RDP architecture.*
