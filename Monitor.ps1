###################################################################
#
#   Description: Monitor and create report.
#   Version: 1.0
#   Author: Tomer Grinberg
#
###################################################################
Clear-Host

# TODO: Template Configuration with hashtable object @{} (not file depending)
# NOTE: maybe in the future  i will change the loading and reading configuration
#       to be from default template/file

# import scripts from config folder
(Get-ChildItem -Path (Join-Path $PSScriptRoot checks) -Filter *.ps1 -Recurse) | % {
    . $_.FullName
}

# import scripts from checks folder
(Get-ChildItem -Path (Join-Path $PSScriptRoot checks) -Filter *.ps1 -Recurse) | % {
    . $_.FullName
}

# Load Servers to Monitor from servers.json file in the current directory
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose "to server file path: $myDir\servers.json"
<#  TODO: need to check if the servers.json file exist and then to read from it
          if the file does not exist need to send mail alert and exit the script
#>
$Servers = Get-Content -Raw -Path $myDir\servers.json | ConvertFrom-Json
Write-Verbose "show server content: $($Servers[8].Name)"

##################################################################
# Start Monitor
# foreach ($srv in $Servers) {
#     if (test-Connection -ComputerName $srv.Name -Count 2 -Quiet ) {
#         $srv | Add-Member -MemberType NoteProperty -Name "IsAlive" -Value $true
#     }
#     else {
#         $srv | Add-Member -MemberType NoteProperty -Name "IsAlive" -Value $false
#     }
# }

# TODO: AddIP function resolve Server name and add his ip to the Servers Object(hashtable)
function addIP {
    foreach ($srv in $Servers) {
        $index = $Servers.IndexOf($srv)
        Write-Output "$index"
        Write-Output "$srv"
        Write-Output $srv.GetType()
        $srv | Add-Member -MemberType NoteProperty -Name "IP" -Value 10.0.0.1
        Write-Output "$srv"
        Write-Output $srv.GetType()
        # $Servers[$index] = 4
    }
}

$Servers | select * | FT -AutoSize | Write-Verbose