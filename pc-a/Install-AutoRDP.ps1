$TargetDir = "C:\Users\Public\AutoRDP"
if (!(Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

Copy-Item -Path (Join-Path $PSScriptRoot "Connect-AutoRDP.ps1") -Destination $TargetDir -Force
Copy-Item -Path (Join-Path $PSScriptRoot "Disconnect-AutoRDP.ps1") -Destination $TargetDir -Force
if (Test-Path (Join-Path $PSScriptRoot ".env")) {
    Copy-Item -Path (Join-Path $PSScriptRoot ".env") -Destination $TargetDir -Force
}

$connectAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""$TargetDir\Connect-AutoRDP.ps1"""
$connectTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday,Monday,Tuesday,Wednesday,Thursday,Friday -At 7:00AM
Register-ScheduledTask -TaskName "AutoRDP_Connect" -Action $connectAction -Trigger $connectTrigger -RunLevel Highest -Force | Out-Null

$disconnectAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File ""$TargetDir\Disconnect-AutoRDP.ps1"""
$disconnectTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday,Monday,Tuesday,Wednesday,Thursday,Friday -At 2:00PM
Register-ScheduledTask -TaskName "AutoRDP_Disconnect" -Action $disconnectAction -Trigger $disconnectTrigger -RunLevel Highest -Force | Out-Null

Write-Host "PC-A Auto-RDP Scheduled Tasks have been successfully installed!"
