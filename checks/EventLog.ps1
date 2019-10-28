function EventLog {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Int32]
        $threshold
    )

    $EVENTLOG = Get-EventLog -LogName "system" -EntryType "warning", "error" -After (Get-Date).AddHours(-24)
    $Result = @{ }
    $temp = $EVENTLOG | group EntryType | select Count, Name 
    $Result.error = $temp[0].Count
    $Result.warning = $temp[1].Count
    $Result.Message = $EVENTLOG | Sort-Object Message -Unique | select EventID, InstanceID, Source, Message
    $Result.status = $true
    # $EVENTLOG | ft -AutoSize
    if ($temp[0].Count -gt 0) {
        $Result.status = $false    
    }
    $Result
}
# Clear-Host
EventLog 