$TargetDir = "C:\Users\em.alam\Documents\BackupScripts"
if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$SourceScript = Join-Path -Path $PSScriptRoot -ChildPath "WindowsBackupAgent.ps1"
$TargetScript = Join-Path -Path $TargetDir -ChildPath "WindowsBackupAgent.ps1"
Copy-Item -Path $SourceScript -Destination $TargetScript -Force

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""$TargetScript"""
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "SyncUtilityCheck" -Action $action -Trigger $trigger -Force | Out-Null

Write-Host "PC-B Sync Bridge has been successfully installed and scheduled to run automatically on login!"
