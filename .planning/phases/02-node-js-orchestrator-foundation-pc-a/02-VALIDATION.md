# Phase 02: Node.js Orchestrator Foundation - Validation

## 1. Acceptance Criteria
The phase is considered complete when the following behavioral truths are verified:

- [ ] **AC-01: Flawless Watching**: New files added to the `WhatsAppDropFolder` trigger a transfer.
- [ ] **AC-02: .tmp Filtering**: Files with `.tmp` extension in the source folder are ignored by the watcher.
- [ ] **AC-03: Payload Atomicity**: Files arrive on PC B's share via a `.tmp` $\rightarrow$ final rename.
- [ ] **AC-04: Signal Atomicity**: JSON instruction files arrive on PC B's share via a `.tmp` $\rightarrow$ final rename.
- [ ] **AC-05: Mirror Integrity**: The original file in the source `WhatsAppDropFolder` remains untouched after transfer.
- [ ] **AC-06: Job Traceability**: Every transferred file has a corresponding JSON signal file containing a unique `jobId`.
- [ ] **AC-07: Serial Processing**: Multiple simultaneous file additions are processed sequentially, not in parallel.

## 2. Test Cases

### TC-01: Happy Path Transfer
- **Setup**: Start the orchestrator.
- **Action**: Drop `test_document.pdf` into `WhatsAppDropFolder`.
- **Expected Result**: 
    1. `test_document.pdf` appears on PC B SMB share.
    2. `test_document.pdf.json` appears on PC B SMB share containing correct metadata.
    3. `test_document.pdf` still exists in `WhatsAppDropFolder`.

### TC-02: Atomic Sequence Validation
- **Setup**: Start orchestrator.
- **Action**: Drop a large file (e.g., 100MB) into `WhatsAppDropFolder`.
- **Expected Result**:
    1. Observe `large_file.ext.tmp` on the SMB share during transfer.
    2. Observe it rename to `large_file.ext` only after the transfer is finished.
    3. Same sequence observed for the `.json` signal file.

### TC-03: Filter Validation
- **Setup**: Start orchestrator.
- **Action**: Create a file named `temp_download.tmp` in `WhatsAppDropFolder`.
- **Expected Result**: No activity logged; no files transferred to SMB share.

### TC-04: JobID Uniqueness
- **Setup**: Start orchestrator.
- **Action**: Drop three different files into `WhatsAppDropFolder`.
- **Expected Result**: The three resulting `.json` files on the SMB share contain three distinct `jobId` values.

### TC-05: Serial Queue Validation
- **Setup**: Start orchestrator.
- **Action**: Drop 5 files simultaneously into `WhatsAppDropFolder`.
- **Expected Result**: Orchestrator logs show that each transfer starts only after the previous one has completed.


## 3. Structural Checklist
- [ ] `package.json` exists with `chokidar` and `fs-extra`.
- [ ] Project structure follows modular layout: `src/config`, `src/lib`, `src/index.js`.
- [ ] All paths are sourced from `config.json`.
