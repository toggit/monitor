# Clear Command Line Screen
Clear-Host

# import scripts
# (Get-ChildItem -Path (Join-Path $PSScriptRoot checks) -Filter *.ps1 -Recurse) | % {
#     . $_.FullName
# }

# Load Servers to Monitor
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Write-Output $myDir\servers.json
$Servers = Get-Content -Raw -Path $myDir\servers.json | ConvertFrom-Json
$Servers[8].Name
$Servers[8].Check[1]

Get-Variable -Scope local
# Start Monitor
# foreach ($srv in $Servers) {
#     if (test-Connection -ComputerName $srv.Name -Count 2 -Quiet ) {
#         $srv | Add-Member -MemberType NoteProperty -Name "IsAlive" -Value $true
#     }
#     else {
#         $srv | Add-Member -MemberType NoteProperty -Name "IsAlive" -Value $false
#     }
# }
# function addIP {
#     foreach ($srv in $Servers) {
#         $index = $Servers.IndexOf($srv)
#         Write-Output "$index"
#         Write-Output "$srv"
#         Write-Output $srv.GetType()
#         $srv | Add-Member -MemberType NoteProperty -Name "IP" -Value 10.0.0.1
#         $srv | Add-Member -MemberType NoteProperty -Name "Version" -Value 2.0.14
#         $srv | Add-Member -MemberType NoteProperty -Name "MyList" -Value @("A", "B")
#         Write-Output "$srv"
#         Write-Output $srv.GetType()
#         # $Servers[$index] = 4
#     }
# }

# addIP
# $Servers.IP
# $Servers | select * | FT -AutoSize