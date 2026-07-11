# Pre-flight Connection Checker
# Requirement: SEC-02

. "$PSScriptRoot\Sync-Utils.ps1"

try {
    # Load and validate configuration
    $Config = Get-Content -Path "$PSScriptRoot\..\config.json" | ConvertFrom-Json
    Test-Config -Config $Config

    # Load environment variables from .env
    $EnvVars = Get-SyncEnv -EnvFilePath "$PSScriptRoot\..\.env"

    $sharePath = $Config.SmbSharePath

    try {
        Write-SyncLog -Message "Attempting to authenticate with SMB share: $sharePath"
        # Authenticate using SMB credentials
        # Using net use as requested. Redirecting output to avoid cluttering console.
        net use $sharePath /user:$($EnvVars.SMB_USERNAME) $($EnvVars.SMB_PASSWORD) 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "SMB authentication failed for $sharePath with exit code $LASTEXITCODE"
        }

        Write-SyncLog -Message "Authentication successful. Performing I/O test..."

        # Pre-flight I/O test
        $tempFilePath = Join-Path $sharePath ".sync_probe"
        try {
            # Create a temporary hidden file to verify read/write access
            New-Item -Path $tempFilePath -ItemType File -Attributes Hidden -Force | Out-Null
            Set-Content -Path $tempFilePath -Value "Sync-Bridge Pre-flight Probe"
            Write-SyncLog -Message "I/O test successful: Write access verified."
        }
        finally {
            # Ensure the probe file is removed
            Remove-Item -Path $tempFilePath -Force -ErrorAction SilentlyContinue
        }

        Write-SyncLog -Message "Pre-flight connection check completed successfully."
        exit 0
    }
    finally {
        # Always disconnect the share on exit
        Write-SyncLog -Message "Cleaning up SMB connection to $sharePath"
        net use $sharePath /delete /y 2>$null
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-SyncLog -Message "CRITICAL ERROR: Pre-flight connection check failed: $ErrorMessage" -Level 'ERROR'
    Write-Error "Pre-flight connection check failed: $ErrorMessage"
    exit 1
}
