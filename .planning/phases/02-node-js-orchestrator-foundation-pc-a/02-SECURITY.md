# Phase 02: Node.js Orchestrator Foundation - Security & Reliability Audit

## 1. Threat Model & Mitigations

This phase focuses on the reliable movement of files from PC A to PC B. The primary "threats" are operational failures and race conditions rather than malicious actors.

| Threat | Impact | Mitigation | Status |
| :--- | :--- | :--- | :--- |
| **Partial File Writes** | PC B processes a file before it is fully copied, leading to corruption. | **Atomic Rename Strategy**: Files are copied as `.tmp` and renamed only after completion. | Verified |
| **Watcher Triggering on Incomplete Files** | Orchestrator attempts to transfer a file that is still being written by the OS/App. | **Write Stability Threshold**: `chokidar` configured with `awaitWriteFinish` (2000ms). | Verified |
| **Concurrent Transfer Collisions** | Multiple files transferring simultaneously cause disk I/O bottlenecks or out-of-order signal files. | **Serial Job Queue**: A Promise-based queue ensures only one transfer occurs at a time. | Verified |
| **Signal/Payload Mismatch** | Unable to correlate a payload file with its corresponding metadata/instruction. | **Unique JobID**: Every transfer is assigned a UUID, included in the `.json` signal file. | Verified |
| **Recursive Watcher Loops** | Watcher triggers on its own temporary files or metadata files. | **Explicit Filtering**: `.tmp` files and `.git` directories are ignored by the watcher. | Verified |

## 2. Implementation Evidence

### Atomic Sequence (`src/lib/transfer.js`)
The `atomicTransfer` function implements the sequence:
1. Copy `source` $ightarrow$ `target.tmp`
2. Write `metadata` $ightarrow$ `target.json.tmp`
3. Rename `target.json.tmp` $ightarrow$ `target.json`
4. Rename `target.tmp` $ightarrow$ `target`

### Stability & Filtering (`src/lib/watcher.js`)
The watcher is initialized with:
- `awaitWriteFinish: { stabilityThreshold: 2000, pollInterval: 100 }`
- `ignored: [/\.tmp$/, /\.git$/]`

### Concurrency Control (`src/index.js`)
A `JobQueue` class manages a `pendingJobs` array, processing them sequentially using `async/await` to ensure strict order and zero overlap.

## 3. Residual Risks
- **Network Interruption**: If the SMB connection drops during the `.tmp` copy, a `.tmp` file may be left orphaned on PC B.
    - *Mitigation*: Future phases should implement a cleanup task for orphaned `.tmp` files.
- **Disk Full**: If PC B runs out of space, the rename will fail.
    - *Mitigation*: Current implementation relies on Node.js error handling to log the failure.
