# Phase 01 Validation: PC B Robust Sync Scripts

This document defines the automated and manual validation steps required to ensure the robustness and correctness of the PC B synchronization scripts.

## Validation Matrix

| Requirement | Validation Method | Test Case | Expected Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Inbound Polling** | Static Analysis | `Check-InboundPolling` | Script contains `while ($true)` and `Start-Sleep -Seconds 5`. | PASSED |
| **Outbound Watcher** | Static Analysis | `Check-OutboundWatcher` | Script contains `System.IO.FileSystemWatcher` initialization. | PASSED |
| **Binary Safety** | Static Analysis | `Check-BinarySafety` | `Get-Content` and `Set-Content` use `-Encoding Byte`. | PASSED |
| **Lock Detection** | Static Analysis | `Check-LockDetection` | Script uses `[System.IO.FileShare]::None` for lock verification. | PASSED |
| **Queue Cleanup** | Static Analysis | `Check-QueueCleanup` | `Remove-Item` is called after successful copy in both chains. | PASSED |
| **Allowlist** | Static Analysis | `Check-Allowlist` | Outbound chain filters by the specified extension allowlist. | PASSED |
| **Logging** | Static Analysis | `Check-Logging` | Errors are logged to `C:\Temp\SyncUtilityCheck.log`. | PASSED |
| **Installation** | Static Analysis | `Check-Installation` | `Install-BackupAgent.ps1` configures the task as hidden and at logon. | PASSED |

## Automated Test Suite: `pc-b/Verify-Phase01.ps1`

The automated suite performs static analysis of the PowerShell scripts to verify the implementation of the "must-haves" without requiring a live RDP environment.

### Execution
```powershell
# Phase 01 Validation: PC B Robust Sync Scripts

This document defines the automated and manual validation steps required to ensure the robustness and correctness of the PC B synchronization scripts.

## Validation Matrix

| Requirement | Validation Method | Test Case | Expected Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Inbound Polling** | Static Analysis | `Check-InboundPolling` | Script contains `while ($true)` and `Start-Sleep -Seconds 5`. | PASSED |
| **Outbound Watcher** | Static Analysis | `Check-OutboundWatcher` | Script contains `System.IO.FileSystemWatcher` initialization. | PASSED |
| **Binary Safety** | Static Analysis | `Check-BinarySafety` | `Get-Content` and `Set-Content` use `-Encoding Byte`. | PASSED |
| **Lock Detection** | Static Analysis | `Check-LockDetection` | Script uses `[System.IO.FileShare]::None` for lock verification. | PASSED |
| **Queue Cleanup** | Static Analysis | `Check-QueueCleanup` | `Remove-Item` is called after successful copy in both chains. | PASSED |
| **Allowlist** | Static Analysis | `Check-Allowlist` | Outbound chain filters by the specified extension allowlist. | PASSED |
| **Logging** | Static Analysis | `Check-Logging` | Errors are logged to `C:\Temp\SyncUtilityCheck.log`. | PASSED |
| **Installation** | Static Analysis | `Check-Installation` | `Install-BackupAgent.ps1` configures the task as hidden and at logon. | PASSED |

## Automated Test Suite: `pc-b/Verify-Phase01.ps1`

The automated suite performs static analysis of the PowerShell scripts to verify the implementation of the "must-haves" without requiring a live RDP environment.

### Execution
```powershell
powershell.exe -File pc-b/Verify-Phase01.ps1
```

## Manual Validation (UAT)
1. **Deploy**: Run `pc-b/Install-BackupAgent.ps1` on a Windows target.
2. **Verify Task**: Check Task Scheduler for "SyncUtilityCheck" (Hidden, Highest Privileges, At Log On).
3. **Test Inbound**: Place a file in `\tsclient\C\Users\Emad Arshad alam\Documents\SyncStaging\In` $\rightarrow$ Verify it appears in `C:\Users\Administrator\Documents\Inbound` and is deleted from source.
4. **Test Outbound**: Place an allowed file in `C:\Users\Administrator\Documents\Outbound` $\rightarrow$ Verify it appears in `\tsclient\C\Users\Emad Arshad alam\Documents\SyncStaging\Out` and is deleted from source.
5. **Test Block**: Place a `.txt` file in `C:\Users\Administrator\Documents\Outbound` $ightarrow$ Verify it is NOT moved.
6. **Test Lock**: Open a file in an exclusive editor $ightarrow$ Verify the script skips it and does not crash.
