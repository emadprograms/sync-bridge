---
wave: 1
depends_on: []
files_modified: ["pc-b/WindowsBackupAgent.ps1", "pc-b/Install-BackupAgent.ps1"]
autonomous: true
---

# Phase 01 Plan: PC B Robust Sync Scripts

## Requirements
SEC-01, SEC-02, SYNC-01, INT-02

## must_haves

truths:
  - pc-b/WindowsBackupAgent.ps1 exists and implements a continuous while loop for inbound file polling.
  - pc-b/WindowsBackupAgent.ps1 configures a System.IO.FileSystemWatcher for outbound file event-driven pushing.
  - pc-b/WindowsBackupAgent.ps1 copies files exclusively using Get-Content -Encoding Byte and Set-Content -Encoding Byte to ensure stream-based binary safety.
  - pc-b/WindowsBackupAgent.ps1 uses Try-Catch blocks to verify file locks via [System.IO.FileShare]::None before initiating copies.
  - pc-b/WindowsBackupAgent.ps1 deletes original files from the source directories immediately after a successful copy to prevent re-processing.
  - pc-b/WindowsBackupAgent.ps1 applies an extension allowlist (.jpg, .jpeg, .png, .docx, .xlsx, .pptx, .pdf, .mp4, .mov, .avi) for outbound synchronization.
  - pc-b/WindowsBackupAgent.ps1 logs any encountered errors to the application log at C:\Temp\SyncUtilityCheck.log.

prohibitions: []

## Artifacts this phase produces
- `pc-b/WindowsBackupAgent.ps1` (New file)
- `pc-b/Install-BackupAgent.ps1` (New file)

## Tasks

<task>
<read_first>
- .planning/phases/01-pc-b-defensible-sync-scripts/01-RESEARCH.md
- .planning/phases/01-pc-b-defensible-sync-scripts/01-CONTEXT.md
- pc-b/WindowsBackupAgent.ps1
</read_first>
<action>
Create `pc-b/WindowsBackupAgent.ps1` to serve as the background daemon handling bi-directional file synchronization on PC B.

1. Define paths:
   - `$LocalInbound = "C:\SyncBridge\Inbound"`
   - `$LocalOutbound = "C:\SyncBridge\Outbound"`
   - `$RemoteStagingIn = "\\tsclient\C\SyncStaging\In"`
   - `$RemoteStagingOut = "\\tsclient\C\SyncStaging\Out"`
   - `$LogFile = "C:\Temp\SyncUtilityCheck.log"`
2. Add logic to ensure the local directories (`$LocalInbound`, `$LocalOutbound`) exist, creating them via `New-Item -ItemType Directory -Force` if they do not.
3. Outbound Chain (Event-Driven):
   - Set up a `System.IO.FileSystemWatcher` for `$LocalOutbound` monitoring for file creation and changes. Set `$watcher.InternalBufferSize = 65536` to prevent dropped events.
   - Use `Register-ObjectEvent` for the `Created` and `Changed` actions.
   - In the event block, first verify the file still exists (`Test-Path`) to debounce duplicate events and avoid errors if it was already processed. Extract the file extension and verify it against an allowlist: `.jpg`, `.jpeg`, `.png`, `.docx`, `.xlsx`, `.pptx`, `.pdf`, `.mp4`, `.mov`, `.avi`. Ignore non-matching files.
   - Implement a locking check using a `Try-Catch` block trying to open the file with `[System.IO.FileShare]::None`. If it throws, it is locked, so skip processing (or retry).
   - Once unlocked, verify `$RemoteStagingOut` is accessible (`Test-Path`). If reachable, stream the file: `Get-Content -Path $SourceFile -Encoding Byte -ReadCount 8192 | Set-Content -Path $DestFile -Encoding Byte`.
   - On successful copy, execute `Remove-Item -Path $SourceFile -Force` to clear the outbound queue.
   - Wrap operations in a `Try-Catch` block that appends exceptions to `$LogFile` using `Out-File -Append`.
4. Inbound Chain (Polling):
   - Create a `while ($true)` loop at the end of the script acting as the primary thread lock.
   - Begin the loop with `Start-Sleep -Seconds 5`.
   - Wrap the loop body in a `Try-Catch` capturing and writing errors to `$LogFile`.
   - Use `Test-Path $RemoteStagingIn` to check connectivity. If unreachable, `continue` the loop.
   - If reachable, use `Get-ChildItem -File` on `$RemoteStagingIn`.
   - For each file, check file lock using `[System.IO.FileShare]::None`.
   - Stream copy to `$LocalInbound`: `Get-Content -Path $RemoteFile -Encoding Byte -ReadCount 8192 | Set-Content -Path $LocalDest -Encoding Byte`.
   - On successful copy, execute `Remove-Item -Path $RemoteFile -Force` to remove it from the staging directory.
</action>
<acceptance_criteria>
- `pc-b/WindowsBackupAgent.ps1` initializes a `New-Object System.IO.FileSystemWatcher`.
- `pc-b/WindowsBackupAgent.ps1` defines an event handler containing `-Encoding Byte -ReadCount 8192` parameters for `Get-Content`.
- `pc-b/WindowsBackupAgent.ps1` contains a `while ($true)` block with `Start-Sleep -Seconds 5`.
- `pc-b/WindowsBackupAgent.ps1` explicitly checks file locks using `[System.IO.FileShare]::None`.
- `pc-b/WindowsBackupAgent.ps1` writes to `C:\Temp\SyncUtilityCheck.log` via `Out-File -Append` or `Add-Content` in `catch` blocks.
</acceptance_criteria>
</task>

<task>
<read_first>
- pc-b/WindowsBackupAgent.ps1
- pc-b/Install-BackupAgent.ps1
</read_first>
<action>
Create `pc-b/Install-BackupAgent.ps1` to configure the persistent background execution of the synchronization daemon on PC B.

1. Ensure the directory `C:\SyncBridge\Scripts` exists via `New-Item -ItemType Directory -Force`.
2. Copy the `WindowsBackupAgent.ps1` script to `C:\SyncBridge\Scripts\`.
3. Create a scheduled task action using `New-ScheduledTaskAction` targeting `powershell.exe`.
4. Define the action arguments as `-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\SyncBridge\Scripts\WindowsBackupAgent.ps1"`.
5. Create a logon trigger using `New-ScheduledTaskTrigger -AtLogOn`.
6. Register the scheduled task in the system using `Register-ScheduledTask -TaskName "SyncUtilityCheck" -Action $action -Trigger $trigger -RunLevel Highest`.
</action>
<acceptance_criteria>
- `pc-b/Install-BackupAgent.ps1` contains `Register-ScheduledTask -TaskName "SyncUtilityCheck"`.
- `pc-b/Install-BackupAgent.ps1` includes `-AtLogOn` in the task trigger definition.
- `pc-b/Install-BackupAgent.ps1` configures the action to run `powershell.exe` with `-WindowStyle Hidden` and the path to the backup agent script.
</acceptance_criteria>
</task>
