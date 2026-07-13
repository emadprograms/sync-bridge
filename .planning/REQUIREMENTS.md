# Requirements

## Active
- [SYNC-01] Two independent, event-driven sync chains (Inbound from Staging, Outbound from PC B).
- [SYNC-02] Pure file-based triggers. No databases, no state machines, no complex command files.
- [SEC-01] PC B runs native PowerShell only. Scripts must look like simple file-copy backup scripts for plausible deniability, but use `Get-Content`/`Set-Content` to break EDR file lineage tracking.
- [SEC-02] Connectivity is maintained via a persistent RDP Drive Redirection tunnel (`\\tsclient\C`), completely isolating the transport from Uni network monitoring without requiring a script-based Network Diode.
- [INT-02] PC B runs a single, dormant background script (to evade Process Creation EDR alerts). It uses `FileSystemWatcher` for instantaneous push events, and silent loops for the inbound pull.
