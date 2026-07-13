# External Integrations

## Ingestion Points
*   **WhatsApp Bot**: Files are dropped by an external WhatsApp bot into an internet-facing drop folder (`WhatsAppDropFolder`) on PC A, kicking off the orchestration pipeline.

## Storage & Bridging
*   **SMB Share**: Serves as the primary bridging connection between the external-facing Node.js orchestrator (PC A) and the air-gapped PowerShell worker (PC B). Authenticated dynamically via credentials injected through `.env`.
*   **Local File System (Command Queue)**: Atomic JSON instructions and `.tmp` payload files are written to local folders, acting as an integration queue mechanism for state machine commands between the master and worker nodes.

## System Interfaces
*   **Windows Network Adapters (Switched Network Diode)**: Direct integration with native Windows network management APIs (via PowerShell `Enable-NetAdapter` / `Disable-NetAdapter`). The system physically toggles interfaces (Internet vs. University network) on PC B to maintain a strict air-gapped state during transfers.

---
*Last updated: 2026-07-13*
