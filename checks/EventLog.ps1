function EventLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Int32]
        $threshold = 0
    )

    $EVENTLOG = Get-EventLog -LogName "system" -EntryType "warning", "error" -After (Get-Date).AddHours(-24)
    $Result = @{ }
    $temp = $EVENTLOG | group EntryType | Select-Object Count, Name
    if ($temp -and $temp.Count -ge 2) {
        if ($temp[0].Count -gt 0) {
            $Result.error = $temp[0].Count
        }
        if ($temp[1].Count -gt 0) {
            $Result.warning = $temp[1].Count
        }
        $Result.Message = $EVENTLOG | Sort-Object Message -Unique | Select-Object EventID, InstanceID, Source, Message
        $Result.status = $true
        # $EVENTLOG | ft -AutoSize
        if ($temp[0].Count -gt 0) {
            $Result.status = $false
        }
    }
    $Result
}
# Clear-Host
# EventLog