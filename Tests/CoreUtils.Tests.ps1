# Import the utility functions
. 'C:\Users\Emad\Documents\GitHub\sync-bridge\Scripts\Sync-Utils.ps1'

Describe "Core Utilities Tests" {
    Context "Write-SyncLog" {
        It "Should create the log file and write a message" {
            $LogFile = "C:\Users\Emad\Documents\GitHub\sync-bridge\Tests\test_sync.log"
            # Temporarily override config.json for testing
            $Config = @{
                LocalSyncPath = "C:\Temp\Local"
                SmbSharePath = "\\Temp\Share"
                LogFilePath = $LogFile
            }
            $Config | ConvertTo-Json | Out-File -FilePath 'C:\Users\Emad\Documents\GitHub\sync-bridge\config.json' -Encoding utf8
            
            Write-SyncLog -Message "Test Log Entry" -Level "INFO"
            
            Test-Path $LogFile | Should Be $true
            $Content = Get-Content $LogFile
            $Content | Should Match "\[.*\] \[INFO\] Test Log Entry"
            
            Remove-Item $LogFile -ErrorAction SilentlyContinue
        }
    }

    Context "Test-Config" {
        It "Should pass for a valid configuration" {
            $ValidConfig = [PSCustomObject]@{
                LocalSyncPath = "C:\Local"
                SmbSharePath = "\\Server\Share"
                LogFilePath = "C:\Logs\sync.log"
            }
            # In Pester, if the block throws, the test fails.
            Test-Config -Config $ValidConfig
        }

        It "Should throw for missing keys" {
            $InvalidConfig = [PSCustomObject]@{
                LocalSyncPath = "C:\Local"
                # SmbSharePath is missing
                LogFilePath = "C:\Logs\sync.log"
            }
            { Test-Config -Config $InvalidConfig } | Should Throw "Configuration Error: Missing required key 'SmbSharePath' in config.json"
        }

        It "Should throw for null or empty values" {
            $InvalidConfig = [PSCustomObject]@{
                LocalSyncPath = "C:\Local"
                SmbSharePath = ""
                LogFilePath = "C:\Logs\sync.log"
            }
            { Test-Config -Config $InvalidConfig } | Should Throw "Configuration Error: Required key 'SmbSharePath' cannot be null or empty in config.json"
        }
    }

    Context "Get-SyncEnv" {
        It "Should correctly parse a .env file" {
            $EnvFile = "C:\Users\Emad\Documents\GitHub\sync-bridge\Tests\test.env"
            $EnvContent = @"
# This is a comment
SMB_USERNAME = admin
SMB_PASSWORD = secret=password123
  SPACED_KEY  =   spaced_value  
"@
            $EnvContent | Out-File -FilePath $EnvFile -Encoding utf8
            
            $Results = Get-SyncEnv -EnvFilePath $EnvFile
            
            $Results['SMB_USERNAME'] | Should Be 'admin'
            $Results['SMB_PASSWORD'] | Should Be 'secret=password123'
            $Results['SPACED_KEY'] | Should Be 'spaced_value'
            
            Remove-Item $EnvFile -ErrorAction SilentlyContinue
        }

        It "Should throw if .env file does not exist" {
            { Get-SyncEnv -EnvFilePath "C:\non_existent_env_file" } | Should Throw "Environment file not found at C:\non_existent_env_file"
        }
    }
}
