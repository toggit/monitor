[CmdletBinding()]
param
(
    [Parameter(ParameterSetName = "1", Position = 1, Mandatory = $true)][Switch]$Start,
    [Parameter(ParameterSetName = "2", Position = 1, Mandatory = $true)][Switch]$Stop,
    # [Parameter(Mandatory = $false)][string]$VMX_Group,
    [Parameter(Mandatory = $false)][string]$VMX_Path3
)

# Load modules

Import-Module vmxtoolkit -Force

#Global Varibales
$timeout = 120
$VMS_list = $null
$vm_list_file_path = "$PWD\vms.json"
$isWindowClosed = $null

# Main Script
$MainFunction = {
    #Init
    Clear-Host
    ###close vmware workstation window if its open
    $script:isWindowClosed = Close-VmwareWorkstationWindow -FilterName "vmware"
    Write-Verbose "isWindowClosed: $script:isWindowClosed"

    ### Load default File
    if ($MyInvocation.MyCommand.Path) {
        $myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $script:vm_list_file_path = "$myDir\vms.json"
    }

    if ($VMX_Path3 -And (Test-Path $VMX_Path3 -PathType Leaf)) {
        $script:vm_list_file_path = $VMX_Path3
    }
    Write-Verbose "file path: $script:vm_list_file_path"

    ### read vms list from json file into object
    if ($script:vm_list_file_path -And (Test-Path $script:vm_list_file_path -PathType Leaf)) {
        $script:VMS_list = Get-Content -Raw -Path $script:vm_list_file_path | ConvertFrom-Json
        $script:VMS_list | Write-Verbose
    }

    if ($PSCmdlet.ParameterSetName -eq "2" -and $Stop.IsPresent -eq $true) {
        [array]::Reverse($script:VMS_list)
        # $Servers | FT -AutoSize
    }

    if ($Start.IsPresent -eq $true) {
        Measure-Command {
            VMStart
        }
    }
    elseif ($Stop.IsPresent -eq $true) {
        Measure-Command {
            VMStop
        }
    }

    # Report
    $script:VMS_list | Select-Object * | FT -AutoSize
    Get-VMXRun
}


#functions
function VMStart {

    foreach ($vm in $script:VMS_list) {
        $result = $null
        $vmx = Get-VMX -VMXName $vm.Name -UUID $vm.UUID
        if ($vmx.State -ne "running") {
            if ($script:isWindowClosed -eq $true) {
                $result = $vmx | Start-VMX -nogui
            }
            else {
                $result = $vmx | Start-VMX
            }
        }
        $timer = 0
        $isAlive = $false
        if ( $result.Status -eq "Started" -or $vmx.State -eq "running") {
            $vm | Add-Member -MemberType NoteProperty -Name "State" -Value "running"
            while ( !$isAlive -and $timer -lt $script:timeout) {
                if (test-Connection -ComputerName $vm.IP -Count 2 -Quiet ) {
                    Write-Verbose "VMXName: $($vm.Name) - $($vm.IP) is Alive"
                    $isAlive = $true
                    break;
                }
                else {
                    Write-Verbose "timer: $timer sleeping for 10 second"
                    Start-Sleep -Seconds 10
                    $timer += 10;
                }
            }
        }
        if (!$isAlive) {
            Write-Verbose "VMXName: $($vm.Name) - $($vm.IP) is Offline"
        }
        $vm | Add-Member -MemberType NoteProperty -Name "isAlive" -Value $isAlive
    }
}

function VMStop {
    <#
        1. Power off VM from the VMS_list.

    #>
    $AllRunVms = Get-VMXRun
    $VMStop_list = [System.Collections.ArrayList]$script:VMS_list
    $Names = $($VMStop_list | Select-Object Name)
    # for ($index = 0; $index -lt $AllVms.Count; $index++) {
    #     if ($AllVms[$index].State -eq 'running' -and $AllVms[$index].VMXName -notin $Names.Name) {
    #         $VMStop_list.Add($AllVms[$index].PsObject.Copy())
    #     }
    # }
    # $test = $AllVms | foreach-object { if ( $_.State -eq 'running' -and $_.VMXName -notin $Names.Name ) { continue }; $_ } | select * 
    $RunningVMs = $AllRunVms | Where-Object { $_.VMXName -notin $Names.Name } | Select-Object *
    if ( $RunningVMs -is [array]) {
        $VMStop_list.AddRange($RunningVMs)
    }
    elseif ($RunningVMs) {
        $VMStop_list.Add($RunningVMs)
    }
    $VMStop_list

    $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
    $timeSpan = New-TimeSpan -Seconds 30

    foreach ($vm in $VMStop_list) {

        $vmx = Get-VMX -VMXName $vm.Name -UUID $vm.UUID
        if ($vmx.State -eq "running") {
            $job = Start-Job -Name "Stop_$($vm.name)" -ScriptBlock {
                If (!(Get-module vmxtoolkit )) {
                    Import-Module vmxtoolkit
                }
                $GuestOS = (Get-VMXGuestOS -VMXName $using:vmx.VMXName -config ($using:vmx.config)).GuestOS
                $using:vm | Add-Member -MemberType NoteProperty -Name "GuestOS" -Value $GuestOS
                $GuestIPAddress = (Get-VMXIPAddress -VMXName $using:vmx.VMXName -config (Get-VMX -VMXName $using:vmx.VMXName).config)
                if ($LASTEXITCODE -eq 0) {
                    $using:vm | Add-Member -MemberType NoteProperty -Name "GuestIPAddress" -Value $GuestIPAddress
                }
                $using:vmx | Stop-VMX -mode Soft
            }
            get-job -Id $job.Id | select *
            Write-Output -InputObject ('Job is running, PID: {0},seconds: {1}' -f $job.Id, (New-TimeSpan -Start $job.PSBeginTime).TotalSeconds)
            Wait-Job -Id $job.Id -Timeout 60
            Write-Output -InputObject ('Job is running, PID: {0},seconds: {1}' -f $job.Id, (New-TimeSpan -Start $job.PSBeginTime).TotalSeconds)
            if ($(get-job -Id $job.Id).State -ne "Completed") {
                #stop proccess
                $stopWatch.Reset()
                $stopWatch.Start()
                do {
                    Write-Verbose 'Checking if vmrun is running...'
                    $vmrunProcess = Get-Process -Name vmrun -ErrorAction SilentlyContinue
                    if ($vmrunProcess) {
                        Write-Output -InputObject ('vmrun is running, PID: {0},seconds: {1}' -f $vmrunProcess.Id, ((New-TimeSpan -Start $vmrunProcess.StartTime ).TotalSeconds))
                        if ( ((New-TimeSpan -Start $vmrunProcess.StartTime).TotalSeconds) -gt 50) {
                            Write-Output -InputObject ('Killinh Job: vmrun , PID: {0},seconds: {1}' -f $vmrunProcess.Id, (New-TimeSpan -Start $vmrunProcess.StartTime).TotalSeconds)
                            $vmrunProcess.Kill()
                            get-job -Id $job.Id | stop-job
                            get-job -Id $job.Id | Remove-Job
                        }
                    }
                    Start-Sleep -Seconds 3
                    write-verbose "Time elapse: $($stopWatch.Elapsed)"
                }
                until ((-not $vmrunProcess) -or ($stopWatch.Elapsed -ge $timeSpan))
            }
            else {
                #job complete print result.
                write-Output InputObject ("total seconds job was running:  {0}" -f ((New-TimeSpan -Start (get-job -Id $job.Id).PSBeginTime).TotalSeconds))
                get-job -Id $job.Id | Receive-Job
            }
        }
    }
    get-job | stop-job
    get-job | Remove-Job
    Get-VMXRun | Stop-VMX
}
function Get-ProccessWithWindow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$FilterName
    )
    return  Get-Process | Where-Object { $_.mainwindowhandle -ne 0 -and $_.Name -eq "vmware" }
}
function Close-VmwareWorkstationWindow {
    $isWindowOpen = Get-ProccessWithWindow -FilterName "vmware"
    if ( $isWindowOpen) {
        Write-Verbose "Closeing the main open windows of the process"
        $isWindowOpen.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 2
    }
    $isWindowOpen = Get-ProccessWithWindow -FilterName  "vmware"
    if ( $isWindowOpen) {
        Write-Verbose "Could not Close the Process"
        return $false
    }
    return $true
}

& $MainFunction