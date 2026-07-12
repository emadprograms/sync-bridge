---
last_mapped_commit: 9f20ab3
---
# Architecture

**Date:** 2026-07-12

## Design Patterns
The system uses a simple imperative script architecture based on PowerShell functions.

## Layers
- **Core Utilities** (`Scripts/Sync-Utils.ps1`): Provides foundational functions like `Write-SyncLog`, `Test-Config`, and `Get-SyncEnv` that are intended to be dot-sourced into the main watchers.
- **Testing Layer** (`Tests/`): Pester-based test files that execute against the core scripts.
- **Network Validation** (`Scripts/Test-NetworkIsolation.ps1`): Dedicated script for network environment validation.

## Data Flow
Configuration is read from `config.json` at runtime, which dictates the drop paths (`LocalSyncPath` and `SmbSharePath`). The utilities rely on JSON structures parsed via `ConvertFrom-Json`.
