# Phase 1: Shared Core & Infrastructure Setup

## Goal
Establish the native PowerShell foundation, logging utilities, and the basic Two-PC drop-box architecture using isolated SMB shares. Provide answers to "What do I need to know to PLAN this phase well?".

<threat_model>
- **Threat (T-01-01)**: EDR detection and flagging of syncing processes.
  - **Mitigation**: Strictly use native PowerShell cmdlets for all network mapping and file system operations without reflective DLL injection or compiled executables.
  - **Risk Level**: High
- **Threat (T-01-02)**: Hardcoded secrets and credential leakage in the codebase.
  - **Mitigation**: Store SMB credentials in a local `.env` file that is parsed dynamically and excluded from version control.
  - **Risk Level**: High
</threat_model>

## Testing Boundary

> **DEV MACHINE ONLY:** All files in `Tests/` (Pester) run exclusively on the developer's local machine. They must never be deployed or executed on the university network. Production scripts (`Sync-Utils.ps1`, `Test-NetworkIsolation.ps1`) use **zero external module dependencies** — native PowerShell cmdlets only.

---

## Repo Folder Layout

The following folder structure is canonical for this phase. All future waves must respect these paths when dot-sourcing or referencing outputs.

```
sync-bridge/
├── Scripts/
│   ├── Sync-Utils.ps1                  # Core utilities: logger, config reader, .env parser
│   └── Test-NetworkIsolation.ps1       # Pre-flight verifier: SMB auth, I/O test
├── Tests/
│   ├── CoreUtils.Tests.ps1             # Pester tests for Sync-Utils.ps1 (dev-only)
│   └── NetworkIsolation.Tests.ps1      # Pester tests for Test-NetworkIsolation.ps1 (dev-only)
├── config.json                         # External configuration (paths, share names)
├── .env                                # SMB credentials — NEVER commit to VCS
├── .env.example                        # Template for .env — committed to VCS
└── .gitignore                          # Must include .env exclusion
```

**Dot-source convention** (Wave 2 referencing Wave 1 output):
```powershell
. $PSScriptRoot\..\Scripts\Sync-Utils.ps1
```

---

## Wave 0: Validation & Test Setup

- **W0-01**: Initialize testing infrastructure for Core Utilities.
  - *Action*: Create `Tests/CoreUtils.Tests.ps1` with Pester test stubs for the logging and configuration utilities.
  - *Note*: Dev machine only. Requires Pester module (`Install-Module Pester -RequiredVersion 5.6.1 -Force -Scope CurrentUser`).

- **W0-02**: Initialize testing infrastructure for Network Isolation.
  - *Action*: Create `Tests/NetworkIsolation.Tests.ps1` with Pester test stubs for validating SMB credential parsing, share I/O checks, and pre-flight tests.
  - *Note*: Dev machine only. Requires Pester module (`Install-Module Pester -RequiredVersion 5.6.1 -Force -Scope CurrentUser`).

---

## Wave 1: Core Configuration and Utilities (Task 01-01-01)

- **Task 01-01-01**: Implement Core Configuration & Logger (`Sync-Utils.ps1`, `config.json`, `.env` parsing, `.gitignore` update)
  - *Requirement*: SEC-01
  - *Description*:
    - Create `config.json` containing properties for `LocalSyncPath`, `SmbSharePath`, and `LogFilePath`.
    - Create an example `.env` file (`.env.example`) containing keys for `SMB_USERNAME` and `SMB_PASSWORD`.
    - Update `.gitignore` to explicitly exclude the `.env` file from version control (Mitigation for T-01-02).
    - Develop `Scripts/Sync-Utils.ps1` featuring a thread-safe `Write-SyncLog` function using **`Out-File -Append`** exclusively — do NOT use `[System.IO.File]::AppendAllText` (that path risks requiring `Add-Type`, which may trigger EDR flags and violates SEC-01).
    - Implement a **`Test-Config` helper** in `Sync-Utils.ps1` that validates all required keys (`LocalSyncPath`, `SmbSharePath`, `LogFilePath`) are present and non-null immediately after parsing `config.json`, throwing a descriptive terminating error if any are missing (e.g., `throw "config.json is missing required key: SmbSharePath"`).
    - Implement a **custom `.env` parsing function** in `Sync-Utils.ps1` with the following exact rules:
      - Strip lines beginning with `#` (comments).
      - Split each line only on the **first** `=` character (allowing `=` to appear in values, e.g., base64 passwords).
      - Trim whitespace from both key and value after splitting.
  - *Validation*: Automated tests via `Invoke-Pester -Path ./Tests/CoreUtils.Tests.ps1`. Core logging module writes a formatted entry to a local log file without errors.

---

## Wave 2: Pre-flight Verification Script (Task 01-01-02)

- **Task 01-01-02**: Implement Pre-flight Connection Checker (`Scripts/Test-NetworkIsolation.ps1`)
  - *Requirement*: SEC-02
  - *Description*:
    - Create `Scripts/Test-NetworkIsolation.ps1` acting as the pre-flight gatekeeper. Dot-source `Sync-Utils.ps1` using `. $PSScriptRoot\..\Scripts\Sync-Utils.ps1`.
    - Parse `config.json` via the `Test-Config` helper (validated config) and parse `.env` using the custom parser (both implemented in Task 01-01-01).
    - **SMB Authentication — committed mechanism**: After parsing `config.json` via `Test-Config`, store the share path in a local variable (e.g., `$sharePath = $config.SmbSharePath`). Authenticate using `net use $sharePath /user:$env:SMB_USERNAME $env:SMB_PASSWORD`. Use `net use` (NOT `New-SmbMapping`) for maximum compatibility — `net use` is a native binary available on every Windows version and requires no external PowerShell modules.
    - Include a **`finally` block** that runs on script exit regardless of success or failure. The `finally` block **must** reference the variable holding the parsed UNC share path — NOT a hardcoded string — e.g., `net use $sharePath /delete /y 2>$null`. This ensures cleanup targets the correct share even if `config.json` is changed, and prevents stale SMB mappings from being silently left behind.
    - **Pre-flight I/O test**: Write a temporary hidden file to the remote share to verify read/write access. The I/O test block **must** include its own `finally` clause to guarantee cleanup: `finally { Remove-Item -Path $tempFilePath -Force -ErrorAction SilentlyContinue }`. This prevents orphaned temp files from accumulating and interfering with sync logic in later phases.
    - Implement **immediate failure** (no retries) if the connection is dropped or the I/O test fails, writing a critical error to the log file via `Write-SyncLog`.
  - *Validation*: Automated tests via `Invoke-Pester -Path ./Tests/NetworkIsolation.Tests.ps1`. Script successfully runs without triggering EDR and fails quickly on a bad network share configuration.

---

## Out of Scope for this Phase
- **Scheduled Tasks Registration (D-09)**: Launching scripts using Windows Scheduled Tasks (at logon/system) to ensure persistence is deferred. The task registration utilities will be built in a later phase when the actual synchronization watchers are developed and ready to be deployed.

---

## Review Feedback Incorporated

| # | Severity | Concern | Resolution |
|---|----------|---------|------------|
| 1 | HIGH | SMB credential mounting mechanism unspecified | Committed to `net use` with explicit syntax in Task 01-01-02 |
| 2 | HIGH | Pre-flight I/O test has no `finally` cleanup | Added `finally { Remove-Item -Force -ErrorAction SilentlyContinue }` block in Task 01-01-02 |
| 3 | MEDIUM | `config.json` missing-key handling undefined | Added `Test-Config` helper requirement in Task 01-01-01 |
| 4 | MEDIUM | `.env` parser edge cases unspecified | Defined exact parser rules (strip `#`, split on first `=`, trim whitespace) in Task 01-01-01 |
| 5 | MEDIUM | No explicit repo folder layout defined | Added canonical folder layout section above Wave 0 |
| 6 | LOW | `Write-SyncLog` leaves two options open | Committed to `Out-File -Append` only; removed alternative |
| 7 | LOW | No rollback for stale SMB mapping | Added `net use /delete /y 2>$null` in `finally` block of Task 01-01-02 |
| 8 | LOW | Pester version not pinned | Pinned to `Install-Module Pester -RequiredVersion 5.6.1 -Force -Scope CurrentUser` in both W0 tasks |
| 9 | LOW | `finally` teardown hardcodes `\\PC-B\BridgeSync` literal | Changed to use parsed config variable (`$sharePath = $config.SmbSharePath`) in Task 01-01-02; hardcoded strings explicitly prohibited |
