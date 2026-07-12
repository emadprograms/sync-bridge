---
last_mapped_commit: 9f20ab3
---
# Directory Structure

**Date:** 2026-07-12

## Key Locations
- `Scripts/`: Contains the executable PowerShell logic.
  - `Sync-Utils.ps1`: Shared utility functions.
  - `Test-NetworkIsolation.ps1`: Connectivity checker.
- `Tests/`: Contains Pester tests.
  - `CoreUtils.Tests.ps1`: Unit tests for `Sync-Utils.ps1`.
  - `NetworkIsolation.Tests.ps1`: Unit tests for network logic.

## Naming Conventions
- PowerShell verbs are used strictly (e.g., `Write-SyncLog`, `Test-Config`).
- Tests follow the `*.Tests.ps1` naming convention for automatic Pester discovery.
- Variables use PascalCase with standard `$Prefix`.
