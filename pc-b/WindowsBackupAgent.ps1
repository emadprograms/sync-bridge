$LocalInbound = "C:\SyncBridge\Inbound"
$LocalOutbound = "C:\SyncBridge\Outbound"
$RemoteStagingIn = "\\tsclient\C\SyncStaging\In"
$RemoteStagingOut = "\\tsclient\C\SyncStaging\Out"
$LogFile = "C:\Temp\SyncUtilityCheck.log"

if (!(Test-Path $LocalInbound)) { New-Item -ItemType Directory -Path $LocalInbound -Force | Out-Null }
if (!(Test-Path $LocalOutbound)) { New-Item -ItemType Directory -Path $LocalOutbound -Force | Out-Null }

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $LocalOutbound
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true
$watcher.InternalBufferSize = 65536

$action = {
    $file = $Event.SourceEventArgs.FullPath
    if (!(Test-Path $file)) { return }
    
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    $allowlist = @(".jpg", ".jpeg", ".png", ".docx", ".xlsx", ".pptx", ".pdf", ".mp4", ".mov", ".avi")
    if ($allowlist -notcontains $extension) { return }

    try {
        $stream = [System.IO.File]::Open($file, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
        $stream.Close()
        $stream.Dispose()
    } catch {
        return
    }

    try {
        if (Test-Path $RemoteStagingOut) {
            $destFile = Join-Path -Path $RemoteStagingOut -ChildPath (Split-Path $file -Leaf)
            Get-Content -Path $file -Encoding Byte -ReadCount 8192 | Set-Content -Path $destFile -Encoding Byte
            Remove-Item -Path $file -Force
        }
    } catch {
        $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Outbound Sync Error: $_"
        Out-File -FilePath $LogFile -InputObject $errorMsg -Append
    }
}

Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier "FileCreated" -Action $action | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier "FileChanged" -Action $action | Out-Null

while ($true) {
    Start-Sleep -Seconds 5
    
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
                
                $localDest = Join-Path -Path $LocalInbound -ChildPath $remoteFileItem.Name
                Get-Content -Path $remoteFile -Encoding Byte -ReadCount 8192 | Set-Content -Path $localDest -Encoding Byte
                Remove-Item -Path $remoteFile -Force
            }
        }
    } catch {
        $errorMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Inbound Sync Error: $_"
        Out-File -FilePath $LogFile -InputObject $errorMsg -Append
    }
}
