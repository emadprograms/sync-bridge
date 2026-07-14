$envPath = Join-Path -Path $PSScriptRoot -ChildPath ".env"
if (!(Test-Path $envPath)) {
    Write-Error ".env file not found."
    exit 1
}

$envContent = Get-Content $envPath
foreach ($line in $envContent) {
    if ($line -match '^RDP_IP=(.*)$') { $RDP_IP = $matches[1].Trim() }
    if ($line -match '^RDP_USER=(.*)$') { $RDP_USER = $matches[1].Trim() }
    if ($line -match '^RDP_PASS=(.*)$') { $RDP_PASS = $matches[1].Trim() }
}

# Save credentials to Windows Credential Manager
cmdkey /generic:"TERMSRV/$RDP_IP" /user:$RDP_USER /pass:$RDP_PASS | Out-Null

# Launch Remote Desktop
# Note: RDP must be configured previously to share the C: drive in the default settings,
# or the user can save a .rdp file and pass it here instead.
Start-Process "mstsc.exe" -ArgumentList "/v:$RDP_IP"
