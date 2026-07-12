---
status: testing
phase: 02-node-js-orchestrator-foundation-pc-a
source: .planning/phases/02-node-js-orchestrator-foundation-pc-a/02-VALIDATION.md
started: 2026-07-12T16:30:00Z
updated: 2026-07-12T16:30:00Z
---

## Current Test

number: 1
name: Cold Start Smoke Test
expected: |
  Kill any running server/service. Clear ephemeral state (temp DBs, caches, lock files). Start the application from scratch. Server boots without errors, and basic functionality (watching the drop folder) is active.
awaiting: user response

## Tests

### 1. Cold Start Smoke Test
expected: Kill any running server/service. Clear ephemeral state. Start the application from scratch. Server boots without errors, and basic functionality is active.
result: [pending]

### 2. Happy Path Transfer
expected: Drop `test_document.pdf` into `WhatsAppDropFolder`. `test_document.pdf` and `test_document.pdf.json` appear on PC B SMB share. Original file remains in `WhatsAppDropFolder`.
result: [pending]

### 3. Atomic Sequence Validation
expected: Drop a large file. Observe `.tmp` extension on the SMB share during transfer, renaming to final name only after completion. Same for the `.json` signal file.
result: [pending]

### 4. Filter Validation
expected: Create `temp_download.tmp` in `WhatsAppDropFolder`. No activity logged; no files transferred to SMB share.
result: [pending]

### 5. JobID Uniqueness
expected: Drop three different files. The three resulting `.json` files on the SMB share contain three distinct `jobId` values.
result: [pending]

### 6. Serial Queue Validation
expected: Drop 5 files simultaneously. Logs show each transfer starts only after the previous one has completed.
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0

## Gaps

[none yet]
