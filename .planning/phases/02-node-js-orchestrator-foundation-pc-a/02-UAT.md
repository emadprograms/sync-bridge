---
status: partial
phase: 02-node-js-orchestrator-foundation-pc-a
source: .planning/phases/02-node-js-orchestrator-foundation-pc-a/02-VALIDATION.md
started: 2026-07-12T16:30:00Z
updated: 2026-07-13T10:00:00Z
---

## Current Test

[testing paused — hardware verification deferred to post-Phase 3]

## Tests

### 1. Cold Start Smoke Test
expected: Kill any running server/service. Clear ephemeral state. Start the application from scratch. Server boots without errors, and basic functionality is active.
result: pending (physical)

### 2. Happy Path Transfer
expected: Drop `test_document.pdf` into `WhatsAppDropFolder`. `test_document.pdf` and `test_document.pdf.json` appear on PC B SMB share. Original file remains in `WhatsAppDropFolder`.
result: pending (physical)

### 3. Atomic Sequence Validation
expected: Drop a large file. Observe `.tmp` extension on the SMB share during transfer, renaming to final name only after completion. Same for the `.json` signal file.
result: pending (physical)

### 4. Filter Validation
expected: Create `temp_download.tmp` in `WhatsAppDropFolder`. No activity logged; no files transferred to SMB share.
result: pass (logic verified)

### 5. JobID Uniqueness
expected: Drop three different files. The three resulting `.json` files on the SMB share contain three distinct `jobId` values.
result: pass (logic verified)

### 6. Serial Queue Validation
expected: Drop 5 files simultaneously. Logs show each transfer starts only after the previous one has completed.
result: pending (physical)

## Summary

total: 6
passed: 2
issues: 0
pending: 4
skipped: 0

## Gaps

[none yet]
