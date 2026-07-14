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

$rdpFile = Join-Path -Path $PSScriptRoot -ChildPath "AutoRDP.rdp"
$rdpContent = @"
full address:s:$RDP_IP
drivestoredirect:s:*
prompt for credentials:i:0
"@
Set-Content -Path $rdpFile -Value $rdpContent

# Launch Remote Desktop using the dynamically generated RDP file
Start-Process "mstsc.exe" -ArgumentList "`"$rdpFile`""
