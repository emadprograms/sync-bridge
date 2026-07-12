# Phase 02: Node.js Orchestrator Foundation (PC A) - Research

## 1. Objective
Research the technical approach needed to plan and execute Phase 02 successfully. This phase is responsible for setting up the foundational Node.js application on PC A, establishing a robust file watcher, and implementing atomic file transfers over SMB to PC B.

## 2. Technical Approach & Tooling

### Node.js Project Initialization
- **Environment:** Node.js running on Windows (PC A).
- **Structure:** Adopt a modular structure (e.g., `src/index.js`, `src/lib/watcher.js`, `src/lib/transfer.js`, `src/config/index.js`) as mandated by decision D-01.
- **Dependencies:**
  - `chokidar`: Required for robust, cross-platform directory watching. It handles the nuances of the Windows filesystem better than the native `fs.watch`.
  - `fs-extra`: Simplifies file system operations (like copying) and provides promise-based API equivalents for easy `async/await` usage.

### Configuration Management
- Use the shared `config.json` at the root as the single source of truth.
- **Identified Gap:** The current `config.json` defines `SmbSharePath` and `LocalSyncPath`, but it lacks a specific path for the WhatsApp bot drop folder. A new key (e.g., `"WhatsAppDropFolder"`) will need to be added to the configuration.

### Drop Folder Monitoring Strategy (`chokidar`)
- **Event Handling:** The watcher should primarily listen to the `add` event. Since the bot downloads to a `.tmp` file and renames it when finished, the completion of a download appears as an `add` event for the final filename.
- **Exclusions:** We must explicitly ignore `.tmp` files. In `chokidar`, this can be done using the `ignored` property (e.g., `ignored: /\.tmp$/`).
- **File Preservation:** Adhering to decision D-05, the orchestrator must *copy* files. Moving or deleting the source files in the drop folder would cause the WhatsApp bot to synchronize a deletion.

### Atomic File Transfer to PC B
- **Destination:** The orchestrator will write over the network to the path defined by `SmbSharePath` (PC B's SMB share).
- **Atomic Operations:** To prevent the PC B PowerShell worker from reading incomplete files, all transfers must be atomic (Decision D-07 & D-08).
  - **Payload Transfer:** 
    1. Copy the detected file to `SmbSharePath\filename.ext.tmp`.
    2. Upon success, rename `filename.ext.tmp` to `filename.ext`.
  - **Instruction Transfer:** 
    1. Generate a JSON instruction payload for the file.
    2. Write this JSON to `SmbSharePath\filename.json.tmp`.
    3. Upon success, rename `filename.json.tmp` to `filename.json`.

## 3. Potential Gotchas & Edge Cases

- **File Locks (EPERM / EBUSY):** On Windows, a newly renamed file (from `.tmp` to final) might momentarily be locked by an antivirus scan or the bot itself. The read operation should gracefully catch lock errors and potentially wait a few milliseconds before retrying.
- **Network Drops:** Writing across an SMB share can fail if the connection drops. While comprehensive retry logic is deferred to Phase 4, the transfer functions must include basic `try/catch` blocks so that a network failure doesn't crash the entire Node.js process.
- **Path Escaping:** Windows paths have backslashes (`\`). Care must be taken when reading paths from `config.json` and joining them using Node's `path` module (`path.join`) to avoid escaping errors.

## 4. Key Takeaways for the PLAN Phase

1. **Setup Steps:** Outline `npm init` and dependency installation (`npm i chokidar fs-extra`).
2. **Config Updates:** Plan the addition of `"WhatsAppDropFolder"` (or equivalent) to `config.json`.
3. **Module Design:** Draft the API for `watcher.js` (to encapsulate chokidar logic) and `transfer.js` (to encapsulate the `.tmp` to final renaming logic).
