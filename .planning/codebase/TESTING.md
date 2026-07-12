---
last_mapped_commit: 9f20ab3
---
# Testing Practices

**Date:** 2026-07-12

## Framework
- The project uses **Pester** for testing.

## Execution
- Tests are segregated into the `Tests/` directory and map to their respective script files (e.g., `CoreUtils.Tests.ps1` tests `Sync-Utils.ps1`).
- The testing boundary dictates that Pester is for dev-only local validation; production scripts use native PowerShell only.
