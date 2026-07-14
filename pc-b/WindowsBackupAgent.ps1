$LocalReceive = "C:\Users\Administrator\Documents\Receive"
$LocalSend = "C:\Users\Administrator\Documents\Send"
$RemoteStagingIn = "\\tsclient\C\Users\Emad Arshad alam\Documents\SyncStaging\In"
$RemoteStagingOut = "\\tsclient\C\Users\Emad Arshad alam\Documents\SyncStaging\Out"
$LogFile = "C:\Temp\SyncUtilityCheck.log"

if (!(Test-Path "C:\Temp")) { New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null }
if (!(Test-Path $LocalReceive)) { New-Item -ItemType Directory -Path $LocalReceive -Force | Out-Null }
if (!(Test-Path $LocalSend)) { New-Item -ItemType Directory -Path $LocalSend -Force | Out-Null }

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $LocalSend
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true
$watcher.InternalBufferSize = 65536

$action = {
    $RemoteStagingOut = "\\tsclient\C\Users\Emad Arshad alam\Documents\SyncStaging\Out"
    $LogFile = "C:\Temp\SyncUtilityCheck.log"
    $file = $Event.SourceEventArgs.FullPath
    
    $now = Get-Date
    if ($now.DayOfWeek -eq 'Saturday' -or $now.Hour -lt 7 -or $now.Hour -ge 14) { return }

    if (!(Test-Path $file)) { return }
    
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    $allowlist = @(".jpg", ".jpeg", ".png", ".docx", ".xlsx", ".pptx", ".pdf", ".mp4", ".mov", ".avi")
    if ($allowlist -notcontains $extension) { return }

    $locked = $true
    $retries = 0
    while ($locked -and $retries -lt 10) {
        try {
            $stream = [System.IO.File]::Open($file, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
            $stream.Close()
            $stream.Dispose()
            $locked = $false
        } catch {
            Start-Sleep -Milliseconds 500
            $retries++
        }
    }
    if ($locked) { return }

    try {
        if (Test-Path $RemoteStagingOut) {
            $destFile = Join-Path -Path $RemoteStagingOut -ChildPath (Split-Path $file -Leaf)
            Get-Content -Path $file -Encoding Byte -ReadCount 8192 | Set-Content -Path $destFile -Encoding Byte
            Remove-Item -Path $file -Force
        }
    } catch {
        $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Send Sync Error: $_"
        Out-File -FilePath $LogFile -InputObject $errorMsg -Append
    }
}

Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier "FileCreated" -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier "FileChanged" -Action $action | Out-Null

while ($true) {
    Start-Sleep -Seconds 5
    
    $now = Get-Date
    if ($now.DayOfWeek -eq 'Saturday' -or $now.Hour -lt 7 -or $now.Hour -ge 14) {
        continue
    }
    
    try {
        if (Test-Path $RemoteStagingIn) {
            $files = Get-ChildItem -Path $RemoteStagingIn -File
            foreach ($remoteFileItem in $files) {
                $remoteFile = $remoteFileItem.FullName
                
                try {
                    $stream = [System.IO.File]::Open($remoteFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
                    $stream.Close()
                    $stream.Dispose()
                } catch {
                    continue
                }
                
                $localDest = Join-Path -Path $LocalReceive -ChildPath $remoteFileItem.Name
                Get-Content -Path $remoteFile -Encoding Byte -ReadCount 8192 | Set-Content -Path $localDest -Encoding Byte
                Remove-Item -Path $remoteFile -Force
            }
        }
    } catch {
        $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Receive Sync Error: $_"
        Out-File -FilePath $LogFile -InputObject $errorMsg -Append
    }

    try {
        if (Test-Path $RemoteStagingOut) {
            $files = Get-ChildItem -Path $LocalSend -File
            $allowlist = @(".jpg", ".jpeg", ".png", ".docx", ".xlsx", ".pptx", ".pdf", ".mp4", ".mov", ".avi")
            foreach ($localFileItem in $files) {
                $localFile = $localFileItem.FullName
                $extension = [System.IO.Path]::GetExtension($localFile).ToLower()
                if ($allowlist -notcontains $extension) { continue }
                
                try {
                    $stream = [System.IO.File]::Open($localFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
                    $stream.Close()
                    $stream.Dispose()
                } catch {
                    continue
                }
                
                $destFile = Join-Path -Path $RemoteStagingOut -ChildPath $localFileItem.Name
                Get-Content -Path $localFile -Encoding Byte -ReadCount 8192 | Set-Content -Path $destFile -Encoding Byte
                Remove-Item -Path $localFile -Force
            }
        }
    } catch {
        $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Send Sync Polling Error: $_"
        Out-File -FilePath $LogFile -InputObject $errorMsg -Append
    }
}
