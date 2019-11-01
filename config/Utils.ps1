
function IsNonInteractiveShell {
    if ([Environment]::UserInteractive) {
        foreach ($arg in [Environment]::GetCommandLineArgs()) {
            # Test each Arg for match of abbreviated '-NonInteractive' command.
            if ($arg -like '-NonI*') {
                return $true
            }
        }
    }

    return $false
}

function GetSecuity {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Security
    )
    #TODO: create hidden directory .cred  for security files and remove the suffix .cred
    $Credential = $null
    $CredentialPath = Join-Path $PSScriptRoot ".cred"
    $SecurityPath = Join-Path $CredentialPath "$Security"
    if (-not $($script:SecurityList)) {
        $script:SecurityList = @{ }
    }
    Write-Verbose "SecurityList: $script:SecurityList"
    if (-not $script:SecurityList.contains($Security)) {
        if (Test-Path -Path $SecurityPath ) {
            $Credential = Import-CliXml -Path "$SecurityPath"
        }
        elseif (IsNonInteractiveShell) {
            $Credential = Get-Credential -Message "Please enter $Security credentials"
            if (-not (Test-Path -Path $CredentialPath)) {
                New-Item -ItemType Directory -Force -Path $CredentialPath
            }
            $Credential | Export-CliXml -Path "$SecurityPath"
        }
        $script:SecurityList.Add($Security, $Credential)
    }
    else {
        $Credential = $script:SecurityList.Get_Item($Security)
    }
    return $Credential
}

Clear-Host
# IsNonInteractiveShell
GetSecuity -Security "tog"
# $host.Name