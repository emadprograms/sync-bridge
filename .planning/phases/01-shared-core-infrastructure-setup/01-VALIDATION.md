---
phase: 01
slug: shared-core-infrastructure-setup
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-11
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Pester (PowerShell) |
| **Config file** | none — Wave 0 installs |
| **Quick run command** | `Invoke-Pester -Path ./Tests/` |
| **Full suite command** | `Invoke-Pester -Path ./Tests/` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `Invoke-Pester -Path ./Tests/`
- **After every plan wave:** Run `Invoke-Pester -Path ./Tests/`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | SEC-01 | T-01-01 | Isolation check | unit | `Invoke-Pester -Path ./Tests/NetworkIsolation.Tests.ps1` | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | SEC-02 | T-01-02 | SMB isolated | unit | `Invoke-Pester -Path ./Tests/SMB.Tests.ps1` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `Tests/NetworkIsolation.Tests.ps1` — stubs for SEC-01
- [ ] `Tests/SMB.Tests.ps1` — stubs for SEC-02

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Network connection check outside of dev context | SEC-01 | Requires separate host | Validate network connectivity from external system |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
