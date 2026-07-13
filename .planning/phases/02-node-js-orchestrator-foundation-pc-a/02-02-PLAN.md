---
requirements: [INT-01]
depends_on: [PLAN-1.md]
wave: 2
must_haves:
  truths:
    - "Files are copied to PC B using a .tmp rename strategy for atomicity."
    - "JSON instruction files are created and renamed atomically."
    - "The watcher ignores .tmp files and uses awaitWriteFinish for stability."
    - "Source files are preserved (Mirror Sync)."
    - "Every transfer is assigned a unique jobId using uuid."
    - "Transfers are processed via a serial job queue."
  artifacts:
    - {path: "src/index.js", provides: "Orchestrator entry point with job queue", min_lines: 15}
    - {path: "src/lib/transfer.js", provides: "Atomic transfer logic with jobId", min_lines: 25}
    - {path: "src/lib/watcher.js", provides: "File watcher logic with awaitWriteFinish", min_lines: 20}
  key_links:
    - {from: "src/config/index.js", to: "src/lib/watcher.js", via: "Config import"}
    - {from: "src/config/index.js", to: "src/lib/transfer.js", via: "Config import"}
    - {from: "src/lib/watcher.js", to: "src/lib/transfer.js", via: "Job queue dispatch"}
    - {from: "src/index.js", to: "src/lib/watcher.js", via: "Initialization"}
---

# Phase 02: Node.js Orchestrator Foundation (PC A) - Plan 2: Implementation

## 1. Objective
Implement the core logic for file watching and atomic transfer to PC B, incorporating reliability improvements from cross-AI review.

## 2. Execution Tasks

<task id="T2.4">
  <description>Implement src/lib/transfer.js with atomic rename logic and jobId support.</description>
  <files>
    - "src/lib/transfer.js"
  </files>
  <action>Implement the atomicTransfer function. It must generate a UUID for the job and perform the .tmp rename sequence for both the payload and the JSON signal file (which now includes the jobId).</action>
  <verify>
    <automated>node -e "require('./src/lib/transfer.js'); console.log('Module loads')"</automated>
    Manual check: transfer a file and verify the resulting .json on PC B contains a unique 'jobId' field.
  </verify>
  <done>Atomic transfer logic with jobId implemented.</done>
</task>

<task id="T2.5">
  <description>Implement src/lib/watcher.js using chokidar with awaitWriteFinish.</description>
  <files>
    - "src/lib/watcher.js"
  </files>
  <action>Implement the watcher. It must ignore .tmp files and utilize the `awaitWriteFinish` option (e.g., stabilityThreshold: 2000) to ensure files are fully written before triggering the event.</action>
  <verify>
    <automated>node -e "require('./src/lib/watcher.js'); console.log('Module loads')"</automated>
    Log output confirms that files are only processed after the write-stability threshold is met.
  </verify>
  <done>Stable file watcher implemented.</done>
</task>

<task id="T2.6">
  <description>Implement src/index.js as the orchestrator entry point with a serial job queue.</description>
  <files>
    - "src/index.js"
  </files>
  <action>Connect the watcher and transfer logic. Implement a simple Promise-based serial queue (e.g., an array of pending jobs processed one-by-one) to ensure transfers occur in sequence and avoid concurrency issues.</action>
  <verify>
    <automated>node -e "require('./src/index.js'); console.log('Entry point loads')"</automated>
    Run `node src/index.js` and drop 5 files simultaneously; verify logs show they are processed sequentially, not in parallel.
  </verify>
  <done>Orchestrator entry point with serial queue implemented.</done>
</task>
