function Get-OperatingSystem {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName
    )

    (Get-CimInstane -ComputerName $ServerName -Class 'Win32_OperatingSystem').Caption
}

function Get-FileCount {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName
    )

    (Get-ChildItem -Path "\\$ServerName\c$\SomeSpecificFolder").Count
}

function Get-ServerInventory {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $osName = Get-OperatingSystem -ServerName $Name
    $fileCount = Get-FileCount -ServerName $Name
    [pscustomobject]@{
        OperatingSystem = $osName
        FileCount       = $fileCount
    }
}