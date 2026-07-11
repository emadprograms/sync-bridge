# Phase 01: Shared Core & Infrastructure Setup - Context

**Gathered:** 2026-07-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish the core shared infrastructure and communication patterns for the sync bridge. This includes defining the SMB access method, folder structure, configuration management, and logging strategy to ensure a stable foundation for the sync watchers in subsequent phases.

</domain>

<decisions>
## Implementation Decisions

### SMB & Network Access
- **D-01:** Use UNC Paths (`\\PC-B\BridgeSync`) to ensure script reliability and avoid mapped drive instability.
- **D-02:** Implement a 'Pre-flight Check' to verify read/write access to the SMB share before the watcher loop starts.
- **D-03:** If the network share is unreachable, the script must log a critical error and stop immediately (no retries).
- **D-10:** Store SMB credentials (username/password) in a local `.env` file to authenticate the UNC connection securely without hardcoding secrets.

### Folder & State Management
- **D-04:** Use a Single Root Folder (`\BridgeSync`) for the shared area.
- **D-05:** Use a dual-manifest system for echo prevention and state tracking: `uni-sync-manifest.json` on PC A and `pcb-sync-manifest.json` on PC B.
- **D-06:** Use Filename-only tracking in manifests (Existence-Based). If a filename has been seen, it is ignored. Edits to existing files will not be synced unless the filename is changed.

### Infrastructure & Ops
- **D-07:** Configuration (paths, network shares) must be stored in an external `config.json` file.
- **D-08:** Implement Detailed File Logging for background watchers to allow for asynchronous debugging.
- **D-09:** Launch scripts using Windows Scheduled Tasks (at logon/system) to ensure persistence.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Foundation
- `.planning/PROJECT.md` — High-level architecture and core value.
- `.planning/REQUIREMENTS.md` — Functional and security requirements.
- `sync-manifest.json` — Example of the existing WhatsApp bot's manifest structure.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `sync-manifest.json`: Provides the pattern for the existence-based tracking used by the WhatsApp bot.

### Established Patterns
- Native PowerShell: All implementation must remain native to avoid EDR flags.

### Integration Points
- PC A's `Documents\Sync` folder: The source for uploads and destination for downloads.
- PC B's `\BridgeSync` SMB share: The intermediate hand-off point.

</code_context>

<specifics>
## Specific Ideas

- The user explicitly wants "immediate failure" on network disconnects to ensure they are alerted to bridge outages.
- Filename-only sync logic is a deliberate choice to maintain simplicity and consistency with existing bot behavior.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-Shared Core & Infrastructure Setup*
*Context gathered: 2026-07-11*
