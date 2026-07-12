---
last_mapped_commit: 9f20ab3
---
# Tech Stack & Configuration

**Date:** 2026-07-12

## Core Technologies
- **Language**: Native PowerShell (PS5.1+ compatibility for Windows)
- **Testing**: Pester framework for testing (`Tests/`)
- **Configuration**: JSON files (`config.json`) and `.env` parsing (`.env.example`)

## Configuration Management
- `config.json` stores primary configuration keys: `LocalSyncPath`, `SmbSharePath`, and `LogFilePath`.
- A `.env` parser (`Get-SyncEnv`) exists to handle `.env` fallback reading without third-party dependencies.
