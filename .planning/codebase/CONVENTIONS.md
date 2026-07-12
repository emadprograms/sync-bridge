---
last_mapped_commit: 9f20ab3
---
# Coding Conventions

**Date:** 2026-07-12

## Error Handling
- The codebase uses explicit `throw` statements for missing configuration (`Test-Config`) or missing files (`Get-SyncEnv`).
- Logging is standardized through `Write-SyncLog`, which appends timestamped entries to a configured log file.

## File Formatting
- UTF-8 encoding is explicitly enforced when writing to logs (`Out-File -Encoding utf8`).
- Strict PowerShell validation is used on parameters (`[ValidateSet('INFO', 'WARN', 'ERROR')]`).
