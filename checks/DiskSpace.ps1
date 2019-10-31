
function DiskSpace {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Int32]
        $threshold
    )
    $DISKS = Get-WmiObject -ComputerName "localhost" Win32_LogicalDisk -Filter "DriveType='3'" |
        select @{n = "Drive"; e = { $_.DeviceId } },
        @{n = "Size(GB)"; e = { [math]::Round($_.Size / 1gb, 2) } },
        @{n = "FreeSpace(GB)"; e = { [math]::Round($_.FreeSpace / 1gb, 2) } },
        @{n = "UsedSpace(%)"; e = { [Int32](100 - (([math]::Round($_.FreeSpace / 1gb, 2)) / ([math]::Round($_.Size / 1gb, 2))) * 100) } },
        @{n = "status"; e = { [Int32](100 - (([math]::Round($_.FreeSpace / 1gb, 2)) / ([math]::Round($_.Size / 1gb, 2))) * 100) -le $threshold } }

    return $DISKS
}

DiskSpace 90