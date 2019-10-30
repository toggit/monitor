
function IsNonInteractiveShell {
    if ([Environment]::UserInteractive) {
        foreach ($arg in [Environment]::GetCommandLineArgs()) {
            # Test each Arg for match of abbreviated '-NonInteractive' command.
            if ($arg -like '-NonI*') {
                return $true
            }
        }
    }
}
# test
Clear-Host
$MyInvocation.MyCommand.Path
$PSScriptRoot
Join-Path $PSScriptRoot Functions

# $script:varA = @{one = "one1" }
# $script:varA
. .\testb.ps1
Write-Output "back to test.ps1: -------->"
$script:varA
updateHash "five"
$script:varA
IsNonInteractiveShell