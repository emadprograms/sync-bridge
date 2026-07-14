# Kills the local Remote Desktop client, effectively disconnecting the session
Stop-Process -Name "mstsc" -Force -ErrorAction SilentlyContinue

# Optionally remove the credentials for security
$envPath = Join-Path -Path $PSScriptRoot -ChildPath ".env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath
    foreach ($line in $envContent) {
        if ($line -match '^RDP_IP=(.*)$') { $RDP_IP = $matches[1].Trim() }
    }
    if ($RDP_IP) {
        cmdkey /delete:"TERMSRV/$RDP_IP" | Out-Null
    }
}
