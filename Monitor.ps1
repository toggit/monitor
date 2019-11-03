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
(Get-ChildItem -Path (Join-Path $PSScriptRoot config) -Filter *.ps1 -Recurse) | % {
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


##################################################################
# Start Monitor
foreach ($srv in $Servers) {

    #check for dns
    Write-Verbose "Resolve Dns: $($srv.Name)"
    if ($srv.Name -as [ipaddress]) {
        $srv | Add-Member -MemberType NoteProperty -Name "IP" -Value $srv.Name
    }
    else {
        $DnsRecord = Resolve-DnsName -Name $srv.Name -ErrorAction SilentlyContinue
        if ($DnsRecord -and $DnsRecord.IP4Address) {
            $srv | Add-Member -MemberType NoteProperty -Name "IP" -Value $DnsRecord.IP4Address
        }
    }

    # check connection - isalive?
    Write-Verbose "Check Ping: $($srv.Name)"
    if (test-Connection -ComputerName $srv.Name -Count 1 -Quiet ) {
        $srv | Add-Member -MemberType NoteProperty -Name "IsAlive" -Value $true
    }
    else {
        $srv | Add-Member -MemberType NoteProperty -Name "IsAlive" -Value $false
    }

    # Create Session for each server
    Write-Verbose "Create Sessions: $($srv.Name)"
    if ($srv.IsAlive) {
        $Login = GetSecuity -Security $srv.Security
        $SrvSession = New-PSSession -ComputerName $srv.Name -Credential $Login -ErrorAction SilentlyContinue
        if ($SrvSession) {
            $srv | Add-Member -MemberType NoteProperty -Name "Session" -Value $SrvSession
        }
        else {
            Write-Error "Session Creation faild for server $($srv.name)"
        }
    }

    # Start monitor checks on server
    if ($srv.Session) {
        foreach ($chk in $srv.Check) {
            # TODO: check if function exist
            $cmd = Get-Command -Name $chk.Name
            if ($chk -and $chk.Name -eq $cmd.Name) {
                $scriptBlock = Get-Item -Path function:$($cmd.Name)
                Invoke-Command -Session $srv.Session -ScriptBlock { $scriptBlock } -ArgumentList $x, $y
            }
        }
    }
}

# $Pass = $Servers[0].Check[0].Security
# $Login = GetSecuity -Security $Pass
# ADHealth -DC $Servers[0].Name -Cred $Login
# Get-WmiObject -Credential $Login -ComputerName $Servers[0].Name -Class Win32_OperatingSystem
# $Servers[0].GetType()

# Clean all jobs and sessions
Get-Job | Stop-Job
Get-Job | Remove-Job
Get-PSSession | Remove-PSSession

$Servers | select * | FT -AutoSize