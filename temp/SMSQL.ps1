
function SMSQL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]
        $databasename = $null
    )
    $BackUpStatus = [[PSCustomObject]@ {
        name = "SMSQL",
        status = $false
    }]

    Set-Location -Path "C:\Program Files\NetApp"
    Get-ChildItem -Directory "SnapManager for*" | Set-Location
    Set-Location Report
    Get-ChildItem -Directory "Backup *" | Set-Location

    $d = Get-Date
    $date = $d.ToString("MM-dd-yyyy")
    $file = Get-ChildItem -File "$($date)*"
    if ($file) {
        $result = Get-Content $file -tail 3 | Select-String "Backup Group: OK"
        if ($result) {
            $BackUpStatus.status = $true
        }
    }

    $BackUpStatus
}