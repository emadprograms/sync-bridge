# Phase 02: Node.js Orchestrator Foundation (PC A) - Context

**Gathered:** 2026-07-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Initialize the Node.js project on PC A. Implement the basic infrastructure to watch the WhatsApp bot drop folder and push payload files and JSON instructions to PC B's Local Folder. This phase focuses on connectivity and ingestion "plumbing" only.

</domain>

<decisions>
## Implementation Decisions

### Project Structure
- **D-01:** Use a Structured/Modular layout (e.g., `src/`, `lib/`, `config/`) to ensure maintainability and ease of future Web UI integration.

### Configuration Management
- **D-02:** Use the shared `config.json` as the single source of truth for paths and environment settings.

### Drop Folder Monitoring Strategy
- **D-03:** Implement `chokidar` to watch the WhatsApp bot folder.
- **D-04:** Ignore `*.tmp` files. Only trigger actions when the final atomic rename occurs.
- **D-05:** Preserve source files in the drop folder (Mirror Sync). Do not delete or move source files, as this would trigger deletions on WhatsApp.

### File Movement & Transfer
- **D-06:** Direct Mirroring. Copy files directly from PC A to PC B's Local Folder.
- **D-07:** Atomic Commit on PC B. To prevent PC B from processing partial files, the orchestrator writes the file as `filename.tmp` on PC B and renames it to `filename` only after the transfer is 100% complete.
- **D-08:** Signal-first approach. The orchestrator will implement the utility to drop both a JSON instruction file and the payload file to PC B's Local Folder.

### the agent's Discretion
- Exact Node.js library choices for file manipulation (e.g., `fs-extra` vs native `fs`).
- Internal folder naming within the modular structure.
- Logging format for the orchestrator.

</decisions>

<specifics>
## Specific Ideas

- The WhatsApp bot writes files atomically by downloading them to a `.tmp` file first and renaming them to the final filename only when 100% complete.

</specifics>

<canonical_refs>
## Canonical References

### Project Foundation
- `.planning/PROJECT.md` â€” Core value, requirements, and architecture pivot to Node.js Master-Worker.
- `.planning/REQUIREMENTS.md` â€” Requirements INT-01.
- `.planning/ROADMAP.md` â€” Phase 02 description and dependencies.

### Codebase Maps
- `.planning/codebase/ARCHITECTURE.md` â€” Current system layers.
- `.planning/codebase/STACK.md` â€” Core technologies.

</canonical_refs>

<code_context>
## Existing Code Insights

### Established Patterns
- Shared `config.json` for path management.
- Use of `.tmp` files for atomic operations (consistent with the bot's behavior).

### Integration Points
- The Node.js orchestrator connects to the SMB share of PC B.
- Output of this phase (files/JSON on PC B) will be consumed by the PowerShell worker in Phase 4.

</code_context>

<deferred>
## Deferred Ideas

- **Database/State Tracking**: Moved to Phase 3.
- **Error Recovery/Retries**: Moved to Phase 4.
- **Acknowledge Loop**: Moved to Phase 4.
- **Network Diode Logic**: Moved to Phase 5.

</deferred>

---

*Phase: 02-node-js-orchestrator-foundation-pc-a*
*Context gathered: 2026-07-12*
