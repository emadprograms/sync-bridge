# Requirements

## v1 Requirements

### Sync Core
- [ ] **SYNC-01**: The system shall bidirectionally synchronize files between the local PC and the university network using a single shared SMB folder (`\BridgeSync`).
- [ ] **SYNC-02**: The system shall prevent infinite echo loops (ping-ponging) and handle network disconnects by maintaining state caches on both sides (`uni-sync-manifest.json` on PC A, and `pcb-sync-manifest.json` on PC B).
- [ ] **SYNC-03**: The system shall use event-driven `FileSystemWatcher` for immediate syncing, falling back to polling if the network share drops.

### Integration
- [ ] **INT-01**: The local PC watcher shall read the WhatsApp bot's `sync-manifest.json` to identify newly downloaded files without writing to it.
- [ ] **INT-02**: The system shall handle file locks gracefully (e.g., if the bot is writing while the watcher reads).

### Security & Infrastructure
- [ ] **SEC-01**: The system shall be implemented entirely in native PowerShell to avoid EDR flags.
- [ ] **SEC-02**: The system shall utilize a Two-PC drop-box architecture over an isolated local LAN to prevent network bridging.

## v2 Requirements
- Bandwidth throttling for large syncs.
- Anti-virus scanning of files in the DMZ.

## Out of Scope
- Compiled executables (C# / PyInstaller) — Explicitly avoided to prevent Defender flags.
- Single-PC network adapter toggling — Deemed too unreliable for network share drops.

## Traceability

| Requirement | Phase |
|---|---|
| SEC-01 | Phase 1 |
| SEC-02 | Phase 1 |
| SYNC-02 | Phase 2 |
| INT-01 | Phase 3 |
| INT-02 | Phase 3 |
| SYNC-01 | Phase 4 |
| SYNC-03 | Phase 5 |
