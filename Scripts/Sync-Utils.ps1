function Write-SyncLog {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $LogPath = (Get-Content -Path "$PSScriptRoot\..\config.json" | ConvertFrom-Json).LogFilePath
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"

    # Ensure the directory exists
    $LogDir = Split-Path -Path $LogPath -Parent
    if (-not (Test-Path -Path $LogDir)) {
        New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    }

    Out-File -FilePath $LogPath -Append -InputObject $LogEntry -Encoding utf8
}

function Test-Config {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )

    $RequiredKeys = @('LocalSyncPath', 'SmbSharePath', 'LogFilePath')
    foreach ($Key in $RequiredKeys) {
        if (-not $Config.PSObject.Properties[$Key]) {
            throw "Configuration Error: Missing required key '$Key' in config.json"
        }
        if ([string]::IsNullOrWhiteSpace($Config.$Key)) {
            throw "Configuration Error: Required key '$Key' cannot be null or empty in config.json"
        }
    }
}

function Get-SyncEnv {
    param (
        [Parameter(Mandatory=$true)]
        [string]$EnvFilePath
    )

    if (-not (Test-Path -Path $EnvFilePath)) {
        throw "Environment file not found at $EnvFilePath"
    }

    $EnvVars = @{}
    Get-Content -Path $EnvFilePath | ForEach-Object {
        $Line = $_.Trim()
        if ($Line -and -not $Line.StartsWith('#')) {
            $Parts = $Line.Split('=', 2)
            if ($Parts.Count -eq 2) {
                $Key = $Parts[0].Trim()
                $Value = $Parts[1].Trim()
                $EnvVars[$Key] = $Value
            }
        }
    }
    return $EnvVars
}
