# Phase 01: Shared Core & Infrastructure Setup - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-11
**Phase:** 01-Shared Core & Infrastructure Setup
**Areas discussed:** SMB Access, Queue Organization, Logging Strategy, Configuration Management, Startup Method, Manifest Depth, Connection Failure, Validation

---

## SMB Access Method

| Option | Description | Selected |
|--------|-------------|----------|
| UNC Paths (\PC-B\BridgeSync) | Recommended for scripts. avoids drive letter conflicts and doesn't require manual mapping on the bridge PC. | ✓ |
| Mapped Drives (Z:\) | Easier for manual file browsing, but can be flaky in background scripts if the session isn't active. | |
| Other | Captures a custom hybrid or specific requirement. | |

**User's choice:** UNC Paths (\PC-B\BridgeSync)
**Notes:** None

---

## Queue Organization

| Option | Description | Selected |
|--------|-------------|----------|
| Sub-folders (\ToUni, \ToLocal) | Explicitly separates 'outgoing' and 'incoming' files, preventing any possibility of the script processing its own output. | |
| Single Root Folder | Simplest setup. Relies entirely on the manifest files to track what has been processed. | ✓ |
| Other | Captures a custom hybrid or specific requirement. | |

**User's choice:** Single Root Folder
**Notes:** User confirmed that the two-folder structure was previously discarded in favor of a JSON manifest system to prevent echo loops.

---

## Logging Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Detailed File Logging | Recommended. Since these watchers run in the background, writing to a `.log` file is the only way to debug issues without keeping a terminal open. | ✓ |
| Critical-Only Logging | Minimal overhead. Only logs critical failures to a file, with standard info sent to the console. | |
| Console Only | | |

**User's choice:** Detailed File Logging
**Notes:** None

---

## Configuration Management

| Option | Description | Selected |
|--------|-------------|----------|
| External config.json | Best for maintainability. You can grow the project or change paths in one JSON file without touching the script logic. | ✓ |
| Internal Constants | Fastest to implement. Good for very small projects where paths rarely change. | |
| Internal Constants | Fastest to implement. Good for very small projects where paths rarely change. | |

**User's choice:** External config.json
**Notes:** None

---

## Startup Method

| Option | Description | Selected |
|--------|-------------|----------|
| Windows Scheduled Tasks | The most native and reliable way. Can be set to run as 'System' or and automatically restarts on failure. | ✓ |
| Startup Folder Shortcut | Simplest for the user. Just a shortcut in `shell:startup`. However, it requires the user to be logged in. | |
| Background Service (NSSM) | Turns the PowerShell scripts into true Windows Services. Most robust, but requires installing a third-party wrapper (NSSM). | |

**User's choice:** Windows Scheduled Tasks
**Notes:** None

---

## Manifest Depth

| Option | Description | Selected |
|--------|-------------|----------|
| Timestamps & File Size | Lightweight and fast. Works for 99% of cases. | |
| SHA256 Hashes | The gold standard. Guaranteed to detect changes regardless of timestamp manipulation. | |
| Filename-only | Consistent with current WhatsApp bot's `sync-manifest.json`. Only syncs new filenames. | ✓ |
| Hybrid (Timestamp then Hash) | Store the timestamp for the initial check, and then hash only if the timestamp changes. | |

**User's choice:** Filename-only (Existence-Based)
**Notes:** User explicitly decided to ignore edits to existing files to keep the system simple and aligned with the bot.

---

## Connection Failure

| Option | Description | Selected |
|--------|-------------|----------|
| Infinite Background Retry | The script will try to reconnect every 30-60 seconds. | |
| Log Error and Exit | Inform immediately upon failure, do not retry. | ✓ |
| Limited Retries | Try 5 times, then stop and alert the user. | |

**User's choice:** Log Error and Exit
**Notes:** User wants immediate notification of failures so they are not unaware of the bridge being down.

---

## SMB Credentials

| Option | Description | Selected |
|--------|-------------|----------|
| .env File | Store credentials in a local, non-committed file. Secure and flexible. | ✓ |
| Hardcoded | Simple but highly insecure. | |
| Windows Vault | Uses native Windows Credential Manager. | |

**User's choice:** .env File
**Notes:** Username and password will be stored in .env to handle the authenticated UNC path access.

---

## Validation

| Option | Description | Selected |
|--------|-------------|----------|
| Pre-flight Check | The script checks for Read/Write access to \\BridgeSync *before* starting the watcher loop. | ✓ |
| On-the-fly Handling | The script starts the watcher and handles errors as they happen. | |

**User's choice:** Pre-flight Check
**Notes:** None

---


