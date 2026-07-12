# Phase 02: Node.js Orchestrator Foundation (PC A) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md â€” this log preserves the alternatives considered.

**Date:** 2026-07-12
**Phase:** 02-node-js-orchestrator-foundation-pc-a
**Areas discussed:** Project Structure, Configuration Management, Drop Folder Monitoring Strategy, File Movement Logic

---

## Drop Folder Monitoring Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Stability Polling | Wait for file size to stop changing | |
| Atomic Rename | Ignore `*.tmp` and trigger on final rename | âœ“ |

**User's choice:** The WhatsApp bot writes files atomically by downloading them to a `.tmp` file first and renaming them to the final filename only when 100% complete.
**Notes:** Confirmed the bot's atomic behavior.

---

## Node.js Project Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Flat / Simple | Simplified structure for speed | |
| Structured / Modular | Dedicated `src/`, `lib/`, `config/` folders | âœ“ |

**User's choice:** Structured / Modular
**Notes:** Recommended for future Web UI integration.

---

## Initial File Movement Logic

| Option | Description | Selected |
|--------|-------------|----------|
| Direct Move | Directly move from drop folder to PC B | |
| Staging Area | Copy to local staging on PC A then push | |
| Direct Mirroring | Copy directly to PC B with atomic commit on PC B | âœ“ |

**User's choice:** Direct Mirroring with Atomic Commit.
**Notes:** User corrected the "transfer queue" approach. Since the source is synced with WhatsApp, files must remain on PC A to avoid triggering deletions on WhatsApp. Goal is true mirror sync.

---

## Configuration Management

| Option | Description | Selected |
|--------|-------------|----------|
| Shared config.json | Use the existing `config.json` shared with PowerShell | âœ“ |
| Decoupled .env | Use a Node-native `.env` file for PC A | |

**User's choice:** Shared config.json
**Notes:** Single source of truth.

---

## the agent's Discretion

- Exact library choices (e.g., `fs-extra` vs `fs`).
- Internal naming and folder structure within the modular layout.

## Deferred Ideas

- Database/State Tracking (Phase 3)
- Error Recovery (Phase 4)
-LACK OF ACKNOWLEDGE LOOP (Phase 4)
- Network Diode Logic (Phase 5)

---

*Phase: 02-node-js-orchestrator-foundation-pc-a*
*Discussion log generated: 2026-07-12*
