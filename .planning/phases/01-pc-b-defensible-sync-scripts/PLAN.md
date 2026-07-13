---
wave: 1
depends_on: []
files_modified:
  - pc-b/WindowsBackupAgent.ps1
autonomous: true
---
# Phase 01: PC B Robust Sync Scripts

## Artifacts this phase produces
- `pc-b/WindowsBackupAgent.ps1`

## must_haves
- requirements: [SEC-01, SEC-02, SYNC-01, INT-02]
- truths:
  - The script runs entirely in native PowerShell without any external binary dependencies.
  - The script polls `\\tsclient\C\Staging_In` on a fixed interval of 5-10 seconds for the inbound chain.
  - The script uses `Get-Content` and `Set-Content` for copying files to ensure reliable stream-based copying.
  - The script implements a `FileSystemWatcher` watching the local Outbound folder for the outbound chain.
  - The script checks file extensions against a strict allowlist (e.g., .jpg, .png, .docx, .xlsx, .pptx, .pdf, .mp4).
  - A try-catch block is used to verify file locking before syncing to ensure files are fully written.
  - Error logs are written to an innocent-looking file path `C:\Temp\WindowsUpdateCheck.log`.
- prohibitions: []

## Tasks

```xml
<task>
  <read_first>
    <file>.planning/phases/01-pc-b-defensible-sync-scripts/01-CONTEXT.md</file>
    <file>.planning/phases/01-pc-b-defensible-sync-scripts/01-PATTERNS.md</file>
  </read_first>
  <action>
    Create `pc-b/WindowsBackupAgent.ps1`.
    Implement the script scaffolding and helper functions:
    1. Define the variables for paths:
       - `$rdpStagingIn = "\\tsclient\C\Staging_In"`
       - `$rdpStagingOut = "\\tsclient\C\Staging_Out"`
       - `$localIn = "C:\Users\Public\Documents\Backup_In"`
       - `$localOut = "C:\Users\Public\Documents\Backup_Out"`
       - `$logPath = "C:\Temp\WindowsUpdateCheck.log"`
    2. Define allowed extensions: `$allowedExts = @(".jpg", ".png", ".docx", ".xlsx", ".pptx", ".pdf", ".mp4")`.
    3. Ensure the local directories and log file directory exist, create them if not.
    4. Implement a helper function `Test-FileLock` that takes a `$Path`. It should use `[System.IO.File]::Open($Path, 'Open', 'Read', 'None')` inside a try-catch to determine if the file is free to read, returning `$true` or `$false`.
    5. Implement a helper function `Copy-Stream` that takes `$Source` and `$Destination`. It must use `Get-Content $Source -Encoding Byte -ReadCount 0 | Set-Content $Destination -Encoding Byte`. On success, it should `Remove-Item $Source`. On failure, it should append a standard error (e.g., "File copy failed error 0x80244018 at [Time] for [File]") to `$logPath`.
  </action>
  <acceptance_criteria>
    `pc-b/WindowsBackupAgent.ps1` exists.
    It contains variable declarations for `$rdpStagingIn`, `$rdpStagingOut`, `$localIn`, `$localOut`, `$logPath`, and `$allowedExts`.
    It contains a `Test-FileLock` function using `[System.IO.File]::Open`.
    It contains a `Copy-Stream` function that copies via `Get-Content ... -Encoding Byte | Set-Content ... -Encoding Byte`.
    It logs errors to `C:\Temp\WindowsUpdateCheck.log`.
  </acceptance_criteria>
</task>

<task>
  <read_first>
    <file>pc-b/WindowsBackupAgent.ps1</file>
  </read_first>
  <action>
    Append the outbound synchronization logic using `FileSystemWatcher` to `pc-b/WindowsBackupAgent.ps1`:
    1. Instantiate a `System.IO.FileSystemWatcher` pointing to `$localOut`.
    2. Set `EnableRaisingEvents = $true` and `IncludeSubdirectories = $false`.
    3. Register an event subscriber for the `Created` event using `Register-ObjectEvent`.
    4. In the `-Action` block for the event:
       - Extract the full path of the created file.
       - Check if the file's extension is in `$allowedExts`. If not, exit the block.
       - Use a `while` loop with a maximum timeout (e.g., 30 seconds) and `Start-Sleep -Seconds 1` to wait for `Test-FileLock` to return true.
       - Once the file is free, compute the destination path in `$rdpStagingOut`.
       - Call `Copy-Stream` to move the file from local to the RDP staging directory.
  </action>
  <acceptance_criteria>
    `pc-b/WindowsBackupAgent.ps1` contains `New-Object System.IO.FileSystemWatcher`.
    `Register-ObjectEvent` is used to trigger on the `Created` event in `$localOut`.
    The event Action block filters by `$allowedExts`.
    The event Action block loops using `Test-FileLock` to wait for the file to be ready before calling `Copy-Stream`.
  </acceptance_criteria>
</task>

<task>
  <read_first>
    <file>pc-b/WindowsBackupAgent.ps1</file>
  </read_first>
  <action>
    Append the inbound polling loop to `pc-b/WindowsBackupAgent.ps1`:
    1. Create an infinite `while ($true)` loop at the end of the script to act as the long-running background process.
    2. Inside the loop, check if `$rdpStagingIn` exists. If so, use `Get-ChildItem -Path $rdpStagingIn -File` to get files.
    3. For each file found:
       - Verify its extension against `$allowedExts`.
       - Call `Test-FileLock` to ensure the file isn't still being written by the staging PC.
       - If unlocked and allowed, compute the destination path in `$localIn`.
       - Call `Copy-Stream` to move the file from the RDP staging directory to local.
    4. End the loop with `Start-Sleep -Seconds 10` to maintain a low-frequency polling rhythm.
  </action>
  <acceptance_criteria>
    `pc-b/WindowsBackupAgent.ps1` contains a `while ($true)` loop at the end of the file.
    The loop uses `Get-ChildItem` on `$rdpStagingIn`.
    The loop validates extensions against `$allowedExts`.
    The loop calls `Test-FileLock` before moving the file with `Copy-Stream`.
    The loop includes a `Start-Sleep -Seconds 10` command.
  </acceptance_criteria>
</task>
```
