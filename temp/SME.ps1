
function SME {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]
        $databasename = $null
    )
    $BackUpStatus = [[PSCustomObject]@ {
        name = "SME",
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
        if ($file.count -gt 1) {
            $file = $file[$file.count - 1]
        }
        $result = Get-Content $file -tail 3 | Select-String "Backup of storage groups/databases successfully completed."
        if ($result) {
            $BackUpStatus.status = $true
        }
    }

    $BackUpStatus
}