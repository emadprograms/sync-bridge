# Directory Structure

**Date:** 2026-07-13

## 1. Layout Overview
Since the codebase relies on a pure PowerShell implementation for maximum stealth and OPSEC, the directory structure is kept intentionally minimal. No heavy frameworks or deeply nested module structures are used, mimicking a simple operational backup script.

```text
sync-bridge/
├── .planning/           # Project management, requirements, and architecture docs
├── src/                 # Main source code directory (planned)
│   └── Sync-Bridge.ps1  # Core background worker script
├── docs/                # Operational documentation (planned)
└── README.md            # Project overview and basic setup instructions
```

## 2. Key Locations
- **`.planning/`**: Contains architectural blueprints, requirements (`REQUIREMENTS.md`), roadmap (`ROADMAP.md`), and this codebase documentation.
- **`src/`** (Planned): Will house the main script (`Sync-Bridge.ps1`). This script will encapsulate the `FileSystemWatcher`, polling loops, and file transfer logic.

## 3. Naming Conventions
- **Scripts:** PowerShell scripts use standard `Verb-Noun` or descriptive PascalCase naming (e.g., `Sync-Bridge.ps1`).
- **Variables/Functions:** Standard PowerShell CamelCase/PascalCase variables and descriptive function names that mimic innocent administrative tasks (e.g., `Update-BackupFiles` rather than `Exfiltrate-Data`).
- **Directories:** Lowercase for system folders (`src`, `docs`), PascalCase for sync directories to match standard Windows folder conventions (e.g., `Staging_In`, `Staging_Out`).
