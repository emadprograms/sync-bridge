# Requirements

## Active
- [SYNC-01] Two independent, event-driven sync chains (Inbound from Staging, Outbound from PC B).
- [SYNC-02] Pure file-based triggers. No databases, no state machines, no complex command files.
- [SEC-01] PC B runs native PowerShell only. Scripts must follow standard backup script conventions for simplicity and use `Get-Content`/`Set-Content` to ensure reliable stream-based copying.
- [SEC-02] Connectivity is maintained via a persistent RDP Drive Redirection tunnel (`\\tsclient\C`), ensuring reliable transport without requiring complex network configurations.
- [INT-02] PC B runs a single background script (to minimize process creation overhead). It uses `FileSystemWatcher` for instantaneous push events, and standard loops for the inbound pull.
