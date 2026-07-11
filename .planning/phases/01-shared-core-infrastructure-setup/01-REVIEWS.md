---
phase: 01
reviewers: [gemini, antigravity]
reviewed_at: 2026-07-11T15:45:00+03:00
plans_reviewed: [01-PLAN.md]
---

# Cross-AI Plan Review — Phase 01

## Gemini Review

## Summary
The plan for Phase 01 is well-structured, focused, and demonstrates a strong understanding of the project's primary constraints—specifically the need for EDR evasion (native PowerShell) and strict network isolation. By prioritizing a "pre-flight" verification and a testing-first approach (Wave 0), the plan ensures that the foundation is stable before the complex synchronization logic is implemented in later phases. The focus on UNC paths and externalized configuration is architecturally sound for this specific environment.

## Strengths
*   **Security-First Posture:** The explicit mitigation of EDR flags (SEC-01) and secret leakage (T-01-02) through native cmdlets and `.env` files is excellent.
*   **Reliability Engineering:** The "Fail-Fast" requirement (D-03) and the pre-flight I/O test in `Test-NetworkIsolation.ps1` prevent the system from entering a "zombie" state where a watcher thinks it is syncing to a disconnected share.
*   **Stability Choice:** Using UNC paths (`\\PC-B\BridgeSync`) over mapped drives (D-01) is a critical decision that avoids common Windows session/permission issues with drive letters in background tasks.
*   **Test-Driven Foundation:** Establishing Pester test stubs in Wave 0 ensures that core utilities are validated before they are integrated into the watchers.

## Concerns
*   **Pester Dependency (MEDIUM):** The plan relies on `Invoke-Pester`. While Pester is the standard for PowerShell testing, it is a module that may not be installed by default on all Windows environments. If the target PCs are locked down, installing Pester might trigger the very EDR flags the project is trying to avoid. *(Resolved: Pester is explicitly marked as dev-machine only in the updated plan.)*
*   **SMB Authentication Implementation (LOW):** The plan mentions `New-SmbMapping` or `net use`. `New-SmbMapping` requires specific PowerShell modules (SmbShare) which might not be available on older OS versions or restricted environments, whereas `net use` is a legacy binary available on every Windows machine.
*   **Logging Lock Contention (LOW):** The plan suggests `Out-File -Append` or `[System.IO.File]::AppendAllText`. In an event-driven system with potential high-frequency file changes, simple append operations can occasionally hit file-lock collisions if multiple threads/processes write simultaneously.

## Suggestions
*   **Pester Fallback:** *(Resolved: Dev-only testing boundary clarified.)*
*   **Standardize on `net use`:** For maximum compatibility and minimal footprint, use `net use` for the initial SMB connection within the pre-flight check.
*   **Logging Robustness:** For `Write-SyncLog`, implement a simple `try-catch` loop with a small sleep (e.g., 100ms) for retrying writes if a file lock is encountered, ensuring no log entries are lost during burst syncs.
*   **Credential Scoping:** Ensure the `.env` parser specifically handles trimmed whitespace to prevent authentication failures caused by trailing spaces in the `.env` file.

## Risk Assessment
**Overall Risk: LOW**

The plan is highly conservative and adheres strictly to the project's constraints. The primary risks are environmental (Pester installation and SMB module availability) rather than architectural. These are easily mitigated during the implementation of Wave 1.

---

## Antigravity Review

## Summary

The Phase 01 plan is well-structured and tightly scoped to its two assigned requirements (SEC-01, SEC-02). The CONTEXT and RESEARCH documents provide solid grounding, and the threat model correctly identifies the two highest-priority risks: EDR detection and credential leakage. The wave sequencing is logical — test stubs first, utilities second, pre-flight verifier third — and the testing boundary is explicitly and correctly documented (dev-machine only, zero external deps on production scripts). A small number of gaps exist: the `.env` credential parsing does not specify the exact authentication mechanism used to mount the UNC share, the pre-flight I/O test leaves the cleanup path unspecified if the write succeeds but the delete fails, and `config.json` has no schema validation or fallback for missing keys. None of these are blockers, but they should be addressed before implementation begins.

## Strengths

- **Clear requirement traceability.** Both SEC-01 and SEC-02 are cited per task; ROADMAP.md success criteria map 1-to-1 to task outputs (`Test-NetworkIsolation.ps1`, SMB mapping, `Write-SyncLog`).
- **Explicit testing boundary.** `01-PLAN.md:17` clearly states "DEV MACHINE ONLY" and specifies `Install-Module Pester` is required — production scripts use zero external module dependencies. This directly satisfies the key security constraint.
- **Correct wave ordering.** Test stubs (Wave 0) precede implementation (Waves 1–2), enabling test-driven development without circular dependencies.
- **Threat model is present and appropriate.** T-01-01 (EDR) and T-01-02 (credential leakage) are the correct top-two threats for this environment; mitigations are concrete and native-only.
- **Decision fidelity.** All ten implementation decisions (D-01 through D-10 in CONTEXT.md) are addressed or explicitly deferred — the Scheduled Tasks deferral is correctly documented.
- **`.gitignore` update is explicitly included.** Task 01-01-01 includes patching `.gitignore` as a step, preventing accidental `.env` commits (T-01-02 mitigation).
- **Config structure is concrete.** `01-RESEARCH.md:34–40` provides an example JSON schema, reducing ambiguity for the implementer.

## Concerns

- **[HIGH] SMB credential mounting mechanism is unspecified.** `01-PLAN.md:43–44` says "parse .env" and "test SMB share reachability via standard PowerShell cmdlets" but does not specify *how* the parsed credentials are used to authenticate the UNC connection. `01-RESEARCH.md:21` mentions `New-SmbMapping` or `net use`, but the plan itself leaves it open. Without an explicit choice, the implementer may make inconsistent decisions that break later phases.

- **[HIGH] Pre-flight I/O test cleanup is not specified.** `01-PLAN.md:45` says "perform a temporary hidden file I/O test on the remote share" but does not define a `finally` / `Remove-Item` cleanup step. If the write succeeds but the delete fails (e.g., permissions issue), orphaned temp files accumulate and may interfere with sync logic in later phases.

- **[MEDIUM] `config.json` has no missing-key error handling defined.** Neither PLAN nor RESEARCH defines what happens when a required key (e.g. `SmbSharePath`) is absent or null. A misconfigured `config.json` could cause a cryptic null-dereference rather than a clear failure message.

- **[MEDIUM] `.env` parsing regex is not specified for edge cases.** Does not address: lines with `#` comments, lines where `=` appears in the value (e.g. base64 passwords), or lines with leading/trailing whitespace. This creates risk that a slightly malformed `.env` silently yields empty credentials.

- **[MEDIUM] No explicit repo folder layout / artifact file paths.** Scripts are mentioned (`Sync-Utils.ps1`, `Test-NetworkIsolation.ps1`) but the root folder structure is not defined, creating friction when Wave 2 needs to dot-source Wave 1 utilities via a known relative path.

- **[LOW] `Write-SyncLog` thread-safety approach leaves two options open.** Plan offers `Out-File -Append` OR `[System.IO.File]::AppendAllText` as alternatives. For SEC-01 compliance, `Out-File -Append` is the safer default (no `Add-Type` required); the plan should commit to one approach.

- **[LOW] No rollback plan if SMB authentication leaves a stale mapping.** A `finally` block with `Remove-SmbMapping` or `net use /delete` is not mentioned.

- **[LOW] Pester version not pinned.** `Install-Module Pester` without a version risks Pester v4/v5 API breaking differences.

## Suggestions

- **Commit to one UNC authentication mechanism** in the plan and document a `finally` block that removes the mapping on script exit or failure.
- **Add a `finally` cleanup step to the pre-flight I/O test** that removes the temporary file regardless of test outcome (`Remove-Item -Force -ErrorAction SilentlyContinue`).
- **Define config validation in `Sync-Utils.ps1`.** Add a `Test-Config` helper that checks for required keys immediately after parsing, throwing a descriptive terminating error if any are missing.
- **Specify a strict `.env` parser** that: strips comment lines (`#`), splits only on the *first* `=` character, and trims surrounding whitespace from keys and values.
- **Define the repo folder layout explicitly** (e.g., `scripts/`, `tests/`) so Wave 2 can dot-source Wave 1 outputs with a known relative path.
- **Commit to `Out-File -Append` for logging** (without `Add-Type`) to guarantee SEC-01 compliance and simplify implementation.
- **Pin the Pester version** in both Wave 0 task notes (e.g. `Install-Module Pester -RequiredVersion 5.6.1 -Force`).

## Risk Assessment

**Overall Risk: LOW**

The plan correctly covers both Phase 1 requirements (SEC-01, SEC-02), documents a sound threat model, enforces the testing boundary, and defers out-of-scope work cleanly. The identified concerns are implementation-level gaps — unspecified mechanism choices, missing cleanup steps, parser edge cases — rather than architectural or security failures. The two HIGH-severity concerns can each be resolved with a single sentence added to the respective task descriptions before coding begins.

---

## Consensus Summary

Phase 01 was reviewed by 2 independent AI systems. Both rated the overall risk as **LOW**, and both praised the security-first design and testing boundary clarity.

### Agreed Strengths
- Security-first posture with native PowerShell only on production scripts
- "Fail-Fast" reliability design for the pre-flight verifier
- UNC path over mapped drives is the correct stability choice
- Test-driven wave sequencing (stubs → utilities → verifier)
- Testing boundary clearly documented as dev-machine only

### Agreed Concerns
- **SMB credential mounting mechanism left unresolved** (HIGH) — should explicitly commit to `New-SmbMapping` or `net use` with documented cleanup
- **Pre-flight I/O test has no `finally` cleanup** (HIGH) — orphaned temp files risk
- **`.env` parser edge cases unspecified** (MEDIUM) — comments, `=` in values, whitespace
- **`config.json` missing-key handling undefined** (MEDIUM) — needs a `Test-Config` helper
- **Logging approach has two options open** (LOW) — should commit to `Out-File -Append`

### Divergent Views
- Gemini flagged logging lock contention under burst load; Antigravity did not raise this specifically but both agreed on committing to `Out-File -Append`.
- Antigravity additionally flagged missing repo folder layout and stale SMB mapping rollback, which Gemini did not raise.
