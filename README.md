# Sync Bridge

A zero-trust, event-driven file synchronization system designed to maintain strict network isolation. This system ensures that a host machine is **never** simultaneously connected to the public internet and a sensitive internal university network.

## Architecture & Compliance

- **Native Implementation:** Written entirely in Windows PowerShell. No third-party binaries, no compiled PyInstaller executables, ensuring full compliance with Endpoint Detection and Response (EDR) agents like Windows Defender.
- **Event-Driven Gatekeeping:** The scripts actively monitor source directories. Network interfaces are toggled exclusively when a file transfer is actively occurring.
- **Mutual Exclusion:** Both scripts utilize a shared `System.Threading.Mutex`. This guarantees that if both scripts run on the same machine, they will not enter a race condition and attempt to toggle the network adapters at the same time.

## Scripts

1. **`LocalToUniWatcher.ps1`**:
   - Uses `System.IO.FileSystemWatcher` to monitor a local directory in real-time.
   - When a new file is dropped, it disables the Internet adapter, enables the University adapter, copies the file to the university network share, and reverts the network state.

2. **`UniToLocalWatcher.ps1`**:
   - Uses a robust, low-footprint polling loop to monitor the University network share. (Polling is used instead of `FileSystemWatcher` because disconnecting the network adapter would crash a live event watcher listening to a UNC path).
   - When a new file appears, it downloads it to a local temp folder, disables the University adapter, enables the Internet adapter, and moves the file to the final destination before reverting.

## Setup & Configuration

1. **Identify Network Adapters:**
   Open an elevated PowerShell prompt and run `Get-NetAdapter` to find the exact names of your network interfaces (e.g., "Ethernet", "Wi-Fi").

2. **Configure Parameters:**
   Both scripts accept parameters that you should customize for your environment.
   - `$InternetAdapterName`: The exact string name of your internet-facing adapter.
   - `$UniAdapterName`: The exact string name of your university-facing adapter.
   - Directories: Update the `$LocalWatchDir`, `$UniWatchDir`, etc., to point to the correct paths.

3. **Execution:**
   Since these scripts use `Enable-NetAdapter` and `Disable-NetAdapter`, they **must** be run as an Administrator.
   
   You can run them manually in separate elevated PowerShell windows:
   ```powershell
   .\LocalToUniWatcher.ps1 -InternetAdapterName "Ethernet" -UniAdapterName "Wi-Fi"
   ```

## Security Considerations

- **Execution Policy:** You may need to set your execution policy to allow the scripts to run (`Set-ExecutionPolicy RemoteSigned`).
- **State Management:** Ensure that the computer starts in the correct state (e.g., Internet adapter enabled, Uni adapter disabled) depending on which watcher you intend to run primarily, though the scripts handle toggling during transfers automatically.
