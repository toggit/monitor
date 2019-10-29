
# Find-Module -Name "*nagios*" -Repository PSGallery | ft -AutoSize


# # Create a PSCustomObject (ironically using a hashtable)
# $ht1 = @{ A = 'a'; B = 'b'; DateTime = Get-Date }
# $theObject = new-object psobject -Property $ht1

# # Convert the PSCustomObject back to a hashtable
# $ht2 = @{}
# $theObject.psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }

# $result = ( get-VMX -VMXName CentOS | start-VMX -nogui)
# $result
# Start-Sleep 30
# $result = ( get-VMX -VMXName ChromeOS | stop-VMX -Mode soft)
# $result
# get-VMX -VMXName ChromeOS | stop-VMX -Mode "Soft"
# get-VMX -VMXName tog10dev | stop-VMX -Mode "Soft"

#guestOS = "freebsd-64"
#guestOS = "windows9-64"
# guestOS = "other-64"
# guestOS = "windows7srv-64"
#guestOS = "windows9srv-64"
# guestOS = "windows8srv-64"
# guestOS = "centos-64"

# Get-ChildItem | Group {$_.LastWriteTime.ToString("yyyy-MM-dd")} | Sort Name
# $flat = Get-ChildItem . | ? { ($_.Name -like '*flat*')} | Group {$_.LastWriteTime.ToString("yyyy")} | Sort Name
# foreach ($grp in $flat) { $grp | Add-Member -MemberType NoteProperty -Name "Filesname" -Value $grp.Group.Name}

# $data = $data | ? {$_.Server -ne "Total"}
# $data = $data[0..($data.Count-2)
# $data = [System.Collections.ArrayList]$data
# $data.GetType()
# $data.Count
# $data.Remove("Machine")
# $data.count
# $data.RemoveAt($data.Count-1)

# Invoke-Item C:\temp\opens-in-excel.csv

# Get-VMX | ? { ($_.State -eq 'running') -and ($_Name)}

# $Numbers = 4..7 
# 1..10 | foreach-object { if ($Numbers -contains $_) { continue }; $_ }

# New-TimeSpan -Start (get-process vmrun).StartTime
# [Int32](New-TimeSpan -Start (get-process notepad).StartTime).TotalSeconds

# Get-PSReadlineKeyHandler | ? {$_.function -like '*hist*'}
# Get-PSReadlineOption | select HistoryNoDuplicates, MaximumHistoryCount, HistorySearchCursorMovesToEnd, HistorySearchCaseSensitive, HistorySavePath, HistorySaveStyle

# Get-PSRepository
# New-Item -Path .\Scripts -Name ATARegistry -ItemType Directory
# New-Item -Path .\Scripts\ATARegistry -Name ATARegistry.psm1
# PS51> New-ModuleManifest -Path .\Scripts\ATARegistry\ATARegistry.psd1 -Author 'Tyler Muir' -CompanyName 'Adam the Automator' -RootModule ATARegistry.psm1 -Description 'Used for interacting with registry keys'
# ModuleVersion = '1.1'
# FunctionsToExport = 'Get-RegistryKey'

# [pscustomobject]@{
#     OperatingSystem = $osName
#     FileCount = $fileCount
# }

# $module = @{
#     Author = 'Kevin Marquette' 
#     Description = 'GraphViz helper module for generating graph images' 
#     RootModule = 'PSGraph.psm1'
#     Path = 'PSGraph.psd1'
#     ModuleVersion = '0.0.1'
# }
# New-ModuleManifest @module

# # Execute the program.  Change the -FilePath argument as needed.
# $script:exitCode = (Start-Process -FilePath `"setup.exe`" -Passthru -Wait).ExitCode;    
    
# # Wait for process to complete. Use the Get-Process CmdLet to determine the name
# # of the process you need to wait for, then change the name of that process as
# # needed below.
# $running = $true;
# while( $running -eq $true ) {

#     $running = ( ( Get-Process | where ProcessName -eq "setup").Length -gt 0);
#     Start-Sleep -s 5
# }

# Start-Process -FilePath 'C:\Windows\System32\calc.exe'
# Start-Sleep -Seconds 5

# $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
# $timeSpan = New-TimeSpan -Minutes 1 -Seconds 30
# $stopWatch.Start()

# do
# {
#     Write-Output -InputObject 'Checking if calculator is running...'
#     $calcProcess = Get-Process -Name Calculator -ErrorAction SilentlyContinue
#     if ($calcProcess)
#     {
#         Write-Output -InputObject ('Calculator is running, PID {0}' -f $calcProcess.Id)
#     }
#     Start-Sleep -Seconds 5
# }
# until ((-not $calcProcess) -or ($stopWatch.Elapsed -ge $timeSpan))

# $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'c:\script\myscript.ps1'
# $trigger = New-ScheduledTaskTrigger -Daily -At 9am
# Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AppLog" -Description "Daily dump of Applog"

# $timeout = [timespan]::FromMinutes(1)
# $now = Get-Date
# Get-Job | Where {$_.State -eq 'Running' -and 
#                  (($now - $_.PSBeginTime) -gt $timeout)} | Stop-Job


# [Int32](New-TimeSpan -Start (get-job).PSBeginTime).TotalSeconds


# Invoke-Command -Computername 'Server01' -Credential $Credential { whoami }
# $Hash = @{
#     'Admin'      = Get-Credential -Message 'Please enter administrative credentials'
#     'RemoteUser' = Get-Credential -Message 'Please enter remote user credentials'
#     'User'       = Get-Credential -Message 'Please enter user credentials'
# }
# $Hash | Export-Clixml -Path "${env:\userprofile}\Hash.Cred"
# $Hash = Import-CliXml -Path "${env:\userprofile}\Hash.Cred"
# Invoke-Command -ComputerName Server01 -Credential $Hash.Admin -ScriptBlock { whoami }
# Invoke-Command -ComputerName Server01 -Credential $Hash.RemoteUser -ScriptBlock { whoami }
# Invoke-Command -ComputerName Server01 -Credential $Hash.User -ScriptBlock { whoami }
