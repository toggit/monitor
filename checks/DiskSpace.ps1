function DiskSpace {
    [CmdletBinding()]
    param (
        [Parameter()]
        [TypeName]
        $ParameterName
    )
    $DISKS = Get-WmiObject -ComputerName "localhost" Win32_LogicalDisk -Filter "DriveType='3'" |
        select @{n = "Drive"; e = { $_.DeviceId } },
        @{n = "Size(GB)"; e = { [math]::Round($_.Size / 1gb, 2) } },
        @{n = "FreeSpace(GB)"; e = { [math]::Round($_.FreeSpace / 1gb, 2) } }

    $DISKS
}


