# Retrieve all Windows Server Computer
Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address
# Retrieve all Windows Client Computer
Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and enabled -eq "true"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address
# Retrieve all Domain-Controllers (no Member-Server)
Get-ADComputer -Filter 'primarygroupid -eq "516"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address

# Retrieve all Member-Server
Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true" -and primarygroupid -ne "516"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address
# Retrieve all Computer sorted by Operatingsystem
Get-ADComputer -Filter 'enabled -eq "true"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address


Get-ADComputer -Filter 'enabled -eq "true"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Out-GridView

Get-ADComputer -Filter 'enabled -eq "true"' `
    -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    Sort-Object -Property Operatingsystem |
    Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address |
    ConvertTo-Html | Out-File C:\Temp\listcomputer.htm


# Username = 'domain\username'
# $Password = 'password'
# $pass = ConvertTo-SecureString -AsPlainText $Password -Force
    
# $SecureString = $pass
# # Users you password securly
# $MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$SecureString 
    
# gwmi win32_service –credential $MySecureCreds –computer PC#

# $pass="FooBoo"|ConvertTo-SecureString -AsPlainText -Force
# $Cred = New-Object   System.Management.Automation.PsCredential('user@domain',$pass)
# gwmi win32_service –credential $cred –computer $computer

# Invoke-Command -ComputerName $remoteMachineName  -ScriptBlock {& $args[0]} -ArgumentList $x

function Save-Password {
    param(
        [Parameter(Mandatory)]
        [string]$Label
    )

    Write-Host 'Input password:'
    $securePassword = Read-host -AsSecureString | ConvertFrom-SecureString

    $securePassword | Out-File -FilePath "C:\MyPasswords\$Label.txt"
}

function Get-Password {
    param(
        [Parameter(Mandatory)]
        [string]$Label
    )

    $filePath = "C:\MyPasswords\$Label.txt"
    if (-not (Test-Path -Path $filePath)) {
        throw "The password with label [$($Label)] was not found!"
    }

    $password = Get-Content -Path $filePath | ConvertTo-SecureString
    $decPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    [pscustomobject]@{
        Label    = $Label
        Password = $decPassword
    }
}



# # $encodedPass = $securePassword | ConvertTo-SecureString
# # [pscustomobject]@{
# #     Label = $label
# #     Password = ([pscredential]::new($label,$encodedPass)).GetNetworkCredential().Password
# # }

# # Try without doing anything bad

# Stop-Computer -WhatIf

# # Stop the local computer

# Stop-Computer

# # Try without doing anything bad on multiple systems

# Stop-computer -ComputerName ‘computer01′,’computer02′, ’computer03’ -whatif

# # Stop multiple systems

# Stop-computer -ComputerName ‘computer01′,’computer02′, ’computer03’



# <# Set and encrypt credentials to file using default method #>

# $credential = Get-Credential
# $credential.Password | ConvertFrom-SecureString | Set-Content c:scriptsencrypted_password1.txt

<# 
    Set some variables
    ...
#>

# $emailusername = "myemail"
# $encrypted = Get-Content c:scriptsencrypted_password.txt | ConvertTo-SecureString
# $credential = New-Object System.Management.Automation.PsCredential($emailusername, $encrypted)

# if($something = $somethingElse)
# {
#     <#
#         Do some stuff
#         ...
#     #>

#     $EmailFrom = "myemail@gmail.com"
#     $EmailTo = "myemail+alerts@gmail.com"
#     $Subject = "I did some stuff!" 
#     $Body = "This is a notification from Powershell." 
#     $SMTPServer = "smtp.gmail.com" 
#     $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
#     $SMTPClient.EnableSsl = $true 
#     $SMTPClient.Credentials = $credential;
#     $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
# }
