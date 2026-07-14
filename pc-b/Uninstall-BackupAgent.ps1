$TaskName = "SyncUtilityCheck"
$TargetDir = "C:\Users\Public\BackupScripts"

# 1. Unregister the Scheduled Task
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Unregistered Scheduled Task: $TaskName"
} else {
    Write-Host "Scheduled Task $TaskName not found."
}

# 2. Stop running instances of the script
Get-WmiObject Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match "WindowsBackupAgent.ps1" } | ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force
    Write-Host "Stopped process ID $($_.ProcessId) running WindowsBackupAgent.ps1"
}

# 3. Clean up script files
if (Test-Path $TargetDir) {
    Remove-Item -Path $TargetDir -Recurse -Force
    Write-Host "Removed directory: $TargetDir"
} else {
    Write-Host "Directory not found: $TargetDir"
}

Write-Host "Uninstall complete."
