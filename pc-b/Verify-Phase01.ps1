# Verify-Phase01.ps1 - Nyquist Validation for Phase 01
# This script performs static analysis to verify the must-haves of Phase 01.

$AgentPath = "pc-b/WindowsBackupAgent.ps1"
$InstallPath = "pc-b/Install-BackupAgent.ps1"

function Test-Requirement {
    param([string]$Name, [string]$File, [string]$Pattern)
    $content = Get-Content -Path $File -Raw
    if ($content -match $Pattern) {
        Write-Host "[PASS] $Name" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[FAIL] $Name" -ForegroundColor Red
        return $false
    }
}

$results = @()

Write-Host "--- Validating WindowsBackupAgent.ps1 ---"
$results += Test-Requirement "Inbound Polling (while loop)" $AgentPath 'while\s*\(.*true.*\)'
$results += Test-Requirement "Inbound Sleep (5s)" $AgentPath 'Start-Sleep\s*-Seconds\s*5'
$results += Test-Requirement "Outbound Watcher" $AgentPath 'New-Object\s+System.IO.FileSystemWatcher'
$results += Test-Requirement "Binary Safety (Encoding Byte)" $AgentPath '-Encoding\s+Byte'
$results += Test-Requirement "Lock Detection (FileShare None)" $AgentPath '\[System\.IO\.FileShare\]::None'
$results += Test-Requirement "Queue Cleanup (Remove-Item)" $AgentPath 'Remove-Item\s+-Path\s+\$\w+\s+-Force'
$results += Test-Requirement "Logging (C:\Temp\SyncUtilityCheck.log)" $AgentPath 'C:\\Temp\\SyncUtilityCheck\.log'
$results += Test-Requirement "Allowlist Implementation" $AgentPath '\$allowlist\s*=\s*@\(\".*\"\)'




Write-Host "`n--- Validating Install-BackupAgent.ps1 ---"
$results += Test-Requirement "Target Directory (C:\Users\Administrator\Documents\BackupScripts)" $InstallPath 'C:\\Users\\Administrator\\Documents\\BackupScripts'
$results += Test-Requirement "Scheduled Task Name (SyncUtilityCheck)" $InstallPath 'Register-ScheduledTask\s+-TaskName\s+"SyncUtilityCheck"'
$results += Test-Requirement "Trigger (AtLogOn)" $InstallPath '-AtLogOn'
$results += Test-Requirement "Execution Style (Hidden)" $InstallPath '-WindowStyle\s+Hidden'

$passCount = ($results | Where-Object { $_ -eq $true }).Count
$totalCount = $results.Count

Write-Host "`n---------------------------------------"
Write-Host "Final Result: $passCount / $totalCount passed"
if ($passCount -eq $totalCount) {
    Write-Host "PHASE 01 VALIDATION SUCCESSFUL" -ForegroundColor Green
    exit 0
} else {
    Write-Host "PHASE 01 VALIDATION FAILED" -ForegroundColor Red
    exit 1
}
