# Phase 01 Research: PC B Robust Sync Scripts

## Objective
Identify technical unknowns and key considerations required to plan the implementation of the PC B PowerShell synchronization script.

## Key Areas to Research / Plan For

### 1. Robust FileSystemWatcher Implementation (Outbound Push)
*   **Buffer Overflows**: The native `FileSystemWatcher` can drop events if too many files change quickly and its internal buffer overflows.
    *   *Consideration*: Set an appropriate `.InternalBufferSize` property. Ensure the event handler (`Register-ObjectEvent`) executes quickly.
*   **File Locking/In-Use Errors**: An event (like `Created` or `Changed`) often fires the moment a file *starts* writing, meaning it is still locked by the source application.
    *   *Consideration*: Implement an "Is File Locked?" helper function (using a `Try-Catch` block attempting to open the file with `[System.IO.FileShare]::None`). The script must retry or wait until the file is fully written before pushing it to `\\tsclient\C\...\Staging_Out`.
*   **Event Duplication**: Certain applications trigger multiple `Changed` events for a single save.
    *   *Consideration*: The script needs to handle or debounce duplicate events gracefully so it doesn't try to sync the same file concurrently.

### 2. Stream-Based Copying via `Get-Content`
*   **Binary File Handling**: The requirements explicitly specify using `Get-Content`/`Set-Content` for copying. By default, these cmdlets read files as strings, which will corrupt binary formats (images, PDFs, Office docs—which are on our allowlist).
    *   *Consideration*: For Windows PowerShell 5.1 (native), we MUST use the `-Encoding Byte` parameter. (In PS 6+, it would be `-AsByteStream`). 
    *   *Memory Efficiency*: To prevent loading massive files into RAM all at once, we should use `-ReadCount` (e.g., `-ReadCount 8192`) and pipeline it to `Set-Content`, ensuring true stream-based processing.

### 3. RDP Tunnel Stability (`\\tsclient\C`)
*   **Transient Disconnections**: RDP sessions can drop, lock, or reconnect. If `\\tsclient\c` is suddenly inaccessible, the script must not crash.
    *   *Consideration*: The polling loop (Inbound) and the event handler (Outbound) must wrap their file operations in strict `Try-Catch` blocks. If the path is unreachable, log the error to the defined application log and calmly wait for the next cycle.
*   **Path Availability Check**: The script should verify the existence of the remote staging directories via `Test-Path` before attempting operations to save time and error logs.

### 4. Single Long-Running Script Architecture
*   **Combining Polling and Events**: The script needs to listen to `FileSystemWatcher` asynchronously while simultaneously running a polling loop.
    *   *Consideration*: `Register-ObjectEvent` handles events in the background (using PowerShell's eventing system). The main thread can run the infinite `while ($true)` polling loop with a `Start-Sleep -Seconds 5` interval. This keeps the script alive and satisfies the [INT-02] requirement for a single background process.

### 5. Scheduled Task Integration & Logging
*   **Non-Interactive Execution**: Running via Task Scheduler at log-on means no console UI. 
    *   *Consideration*: Fulfill the requirement to log errors strictly to a standard application log file (e.g., `C:\Temp\SyncUtilityCheck.log`). Standard output can be suppressed or redirected.

## Open Questions for the Plan
*   **PowerShell Version constraints**: Assume Windows PowerShell 5.1 (since it's "native" on Windows), meaning we use `-Encoding Byte`. 
*   **Queue Cleanup**: Once a file is successfully copied via `Get-Content`/`Set-Content`, the script should likely delete the original file from the Staging folder to prevent endless re-processing. The Plan should define the exact cleanup behavior.
