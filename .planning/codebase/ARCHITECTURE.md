# Codebase Architecture

**Date:** 2026-07-13

## 1. System Overview
Sync Bridge is a bi-directional file synchronization tool that transfers files between an internet-facing staging area (PC A) and an air-gapped, locked-down University network (PC B). It relies entirely on native Windows features—specifically RDP Drive Redirection (`\\tsclient\C`) and native PowerShell capabilities—without requiring third-party software on the restricted PC.

## 2. Pattern & Layers
The architecture uses an **Event-Driven & Polling Hybrid Pattern**, operating primarily as a dormant background service to avoid triggering Endpoint Detection and Response (EDR) alarms. 
- **Event-Driven (Outbound):** Uses native `.NET` `FileSystemWatcher` to instantly detect file drops and initiate transfers.
- **Polling (Inbound):** Uses a slow, silent loop to poll the RDP tunnel for new files, avoiding process-creation noise (Event ID 4688).

## 3. Data Flow
The system manages two independent synchronization chains:

### Inbound (Staging -> PC B)
1. **Source:** `\\tsclient\C\...\Staging_In` (via RDP Drive Tunnel)
2. **Action:** A background PowerShell script polls this directory.
3. **Transfer:** When a file is found, it is read as a byte-stream using `Get-Content` and written locally using `Set-Content`. This breaks EDR file lineage tracking compared to a standard `Copy-Item`.
4. **Cleanup:** The file is deleted from the staging directory.

### Outbound (PC B -> Staging)
1. **Source:** Local `Outbound` folder on PC B.
2. **Action:** `FileSystemWatcher` detects a new file drop.
3. **Transfer:** The script instantly pushes the file across the tunnel to `\\tsclient\C\...\Staging_Out`.
4. **Cleanup:** The local copy on PC B is deleted.

## 4. Abstractions & Components
Given the constraint of pure PowerShell 5.1+ and zero-installation on PC B, the architecture explicitly avoids complex abstractions (no state machines, databases, or complex command files).
- **Watcher Component:** Wraps `System.IO.FileSystemWatcher` to monitor the local outbound directory.
- **Poller Component:** A continuous `while($true)` loop with `Start-Sleep` to silently check for inbound files.
- **Transfer Component:** Implements stealth file copying (`Get-Content | Set-Content`) for both inbound and outbound traffic.

## 5. Entry Points
The core entry point will be a single PowerShell script (e.g., `Sync-Bridge.ps1`) designed to run as a background job or hidden process. This ensures it looks like a standard, innocent backup script for plausible deniability while executing both inbound and outbound chains concurrently within the same session.
