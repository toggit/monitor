
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

function secuity {
    $Credential = Get-Credential
    $Credential | Export-CliXml -Path "${env:\userprofile}\Jaap.Cred"
    $Credential = Import-CliXml -Path "${env:\userprofile}\Jaap.Cred"
    Invoke-Command -Computername 'Server01' -Credential $Credential { whoami }

    $Hash = @{
        'Admin'      = Get-Credential -Message 'Please enter administrative credentials'
        'RemoteUser' = Get-Credential -Message 'Please enter remote user credentials'
        'User'       = Get-Credential -Message 'Please enter user credentials'
    }
    $Hash | Export-Clixml -Path "${env:\userprofile}\Hash.Cred"
    $Hash = Import-CliXml -Path "${env:\userprofile}\Hash.Cred"
    Invoke-Command -ComputerName Server01 -Credential $Hash.Admin -ScriptBlock { whoami }
    Invoke-Command -ComputerName Server01 -Credential $Hash.RemoteUser -ScriptBlock { whoami }
    Invoke-Command -ComputerName Server01 -Credential $Hash.User -ScriptBlock { whoami }
}
Clear-Host
IsNonInteractiveShell
$host.Name