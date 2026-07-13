# Phase 01 Context: PC B Robust Sync Scripts

## Domain
Build the native PowerShell background script for PC B. This single script uses FileSystemWatcher for outbound and polling for inbound (via `Get-Content`/`Set-Content`). It must follow standard backup script conventions.

## Canonical Refs
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`

## Code Context
No specific existing files yet, we are starting fresh with the PowerShell script.

## Decisions
- **Polling rhythm (Inbound)**: Fixed, low-frequency interval (e.g., 5-10 seconds). User noted that since polling happens on the RDP shared drive and not the enterprise network, it minimizes unnecessary network traffic, while keeping CPU usage efficient.
- **File locking & partial copies**: Use a strict allowlist of extensions (images like jpg/png, Office docs like docx/excel/ppt, PDFs, videos) to naturally filter out temp files. Combine this with a Try-Catch block to ensure the file can be exclusively opened (is finished writing) before syncing.
- **Logging**: Log errors only to a standard application log file (e.g., `C:\Temp\SyncUtilityCheck.log`).
- **Script initialization**: Use a Scheduled Task triggering on log-on, designed as a standard system backup task.

## Deferred Ideas
- None captured during this session.
