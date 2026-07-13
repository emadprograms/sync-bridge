# Testing Patterns

*Last updated: 2026-07-13*

## Framework & Structure
- **Framework:** Pester (PowerShell's standard testing framework).
- **Test Location:** Tests should be located in a `tests/` directory at the root of the project.
- **Naming Convention:** Test files should follow the `<ScriptName>.tests.ps1` format.

## Core Testing Philosophy
- **Local Isolation:** Since the system operates over a restricted network and relies on RDP Drive Redirection (`\\tsclient\C`), tests should mock the RDP paths using local temporary directories.
- **Behavioral Testing:** Focus on verifying that file drops trigger the appropriate copy and delete actions without leaving traces.

## Mocking & Stubs
- Use Pester's `Mock` functionality to simulate the behavior of network traversal, `Get-Content`, `Set-Content`, and `Remove-Item` to ensure destructive actions aren't executed against real files during tests.
- **FileSystemWatcher:** Since testing event-driven handlers (like `FileSystemWatcher`) in CI can be flaky, isolate the event-handling logic from the file processing logic. Test the processing function directly instead of waiting for file system events.

## Test Coverage Requirements
- **Core Functions:** 
  - Ensure the polling logic correctly triggers when a file is detected in the inbound path.
  - Ensure the byte-stream copying (`Get-Content | Set-Content`) works as expected without corrupting binary files.
  - Verify that the original file is cleanly deleted after a successful copy.
- **Stealth & Constraints:**
  - Tests should verify that `Copy-Item` is NOT used in the core transport logic (use abstract syntax tree (AST) checks or string scanning if necessary).

## Running Tests
Run all tests via Pester from the command line:
```powershell
Invoke-Pester -Path .\tests\ -Output Detailed
```
