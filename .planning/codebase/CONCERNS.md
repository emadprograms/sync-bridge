---
last_mapped_commit: 9f20ab3
---
# Technical Concerns & Debt

**Date:** 2026-07-12

## Technical Debt & Fragility
- `Write-SyncLog` reads `config.json` dynamically from disk *every time* a log is written. If high volume logging occurs, this will cause heavy I/O overhead and potential read-locks on the config file.
- Error handling in the core utilities uses `throw`, meaning callers must explicitly use `try/catch` or risk terminating the entire process.

## Security
- No major security risks found in the utilities, though `.env` parsing requires careful permission lockdown so credentials aren't exposed.
