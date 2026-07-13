# Technical Concerns & Debt

**Date:** 2026-07-13

## Current Codebase State
As of the recent pivot to the simplified, database-free, event-driven RDP architecture, the repository is currently in a transitional planning phase. The old Node.js master-worker codebase has been deprecated and removed. The concerns below apply to the incoming Phase 1 architectural design.

## Architecture & Fragility
- **FileSystemWatcher Reliability**: The outbound chain relies entirely on native PowerShell `FileSystemWatcher` (Chain 2). This class is notoriously fragile under high volume or rapid file creation scenarios and can silently drop events. Without a database or secondary sweep mechanism, dropped events mean permanently stalled file transfers.
- **RDP Drive Mapping Stability**: The entire transport relies on `\\tsclient\C`. RDP drive redirection is historically sensitive to session state changes. If the RDP session drops, minimizes to the background, or locks, the `\\tsclient` mapping may temporarily disconnect, causing the script to fail silently or throw errors unless aggressively handled.
- **Atomic File Transfers**: Since the new requirements state "no complex command files", transferring large files carries a risk of race conditions. If the script attempts to read or push a file that is still actively being written to disk by the user/system, it will crash or transfer an incomplete file.

## Security & EDR Stealth
- **Lineage Evasion**: Using `Get-Content | Set-Content` to break EDR lineage is effective against basic copy tracking, but highly advanced EDRs may still flag sudden high-volume read/write operations from a background PowerShell process.
- **Script Block Logging**: Although the script avoids Event ID 4688 (Process Creation) by running as a single dormant background process, PowerShell 5.1+ natively features Script Block Logging (Event ID 4104). Unless obfuscated or purely composed of standard cmdlets, the exact logic of the polling and pushing loops will be logged to the Event Viewer, which could breach the "plausible deniability" constraint if inspected manually.

## Performance
- **Polling Overhead**: Chain 1 relies on silently polling `\\tsclient\C\...\Staging_In`. Polling an RDP redirected drive over SMB/TSClient can incur high latency and network noise. A very aggressive polling loop could saturate the RDP virtual channel, while a slow polling loop creates noticeable transfer delays.
