
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

    $Credential = $null
    $SecurityPath = Join-Path $PSScriptRoot $("$Security.Cred")

    if (-not $($global:Security)) {
        $global:Security = @{ }
    }
    $global:Security
    

    if (Test-Path -Path $SecurityPath) {
        $Credential = Import-CliXml -Path "$SecurityPath"
    }
    elseif (IsNonInteractiveShell) {
        $Credential = Get-Credential - -Message "Please enter $Security credentials" 
        $Credential | Export-CliXml -Path "$SecurityPath"
        $global:Security["$Security"] = $Credential
    }

    return $Credential
}

Clear-Host
IsNonInteractiveShell
GetSecuity -Security "tog"
$host.Name