function Invoke-IEWait {
    #Begin function Invoke-IEWait
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeLine
        )]
        $ieObject
    )

    While ($ieObject.Busy) {

        Start-Sleep -Milliseconds 10

    }

} #End function Invoke-IEWait

function Invoke-IECleanUp {
    #Begin function Invoke-IECleanUp
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeLine
        )]
        $ieObject
    )

    #Store logout URL
    $logoutURL = $currentDocument.links | Where-Object { $_.outerText -eq 'log out' } | Select-Object -ExpandProperty href -First 1

    #Use logout URL to logout via the Navigate method
    $ieObject.Navigate($logoutURL)

    #Wait for logout
    $ieObject | Invoke-IEWait

    #Clean up IE Object
    $ieObject.Quit()

    #Release COM Object
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($ieObject)

} #End function Invoke-IECleanUp

function Invoke-SiteLogon {
    #Begin function Invoke-SiteLogon
    [cmdletbinding()]
    param()

    #Set the URL we want to navigate to
    $webURL = 'https://login.netapp.com/ssologinext/'

    #Create / store object invoked in a variable
    $ieObject = New-Object -ComObject 'InternetExplorer.Application'

    #By default it will not be visible, and this is likely how you'd want it set in your scripts
    #But for demo purposes, let's set it to visible
    $ieObject.Visible = $true

    #Navigate to the URL we set earlier
    $ieObject.Navigate($webURL)

    #Wait for the page to load
    $ieObject | Invoke-IEWait

    #Store current document in a variable
    $currentDocument = $ieObject.Document

    #Username field
    $userNameBox = $currentDocument.IHTMLDocument3_getElementsByTagName('input') | Where-Object { $_.name -eq 'username' }

    #Fill out username value
    $userNameBox.value = $myCredentials.UserName
    $userNameBox.value
    #Password field
    $passwordBox = $currentDocument.IHTMLDocument3_getElementsByTagName('input') | Where-Object { $_.name -eq 'password' }

    #Fill out password value
    $passwordBox.value = $myCredentials.GetNetworkCredential().Password
    $passwordBox.value
    #Submit button
    $submitButton = $currentDocument.IHTMLDocument3_getElementsByTagName('input') | Where-Object { $_.type -eq 'submit' }
    # $submitButton | Get-Member -MemberType method
    #Invoke click method on submit button
    $submitButton.click()

    #Wait for the page to load
    $ieObject | Invoke-IEWait

    #Return the object so we can work with it further in the script
    Return $ieObject

} #End function Invoke-SiteLogon

#Get credentials
$myCredentials = Get-Credential
$myCredentials

# $ieObject = New-Object -ComObject 'InternetExplorer.Application'
# $ieObject | Get-Member
$ieObject = Invoke-SiteLogon
# $ieObject.Visible = $true
# $ieObject.Navigate('https://login.netapp.com/ssologinext/')
# $currentDocument = $ieObject.Document
# $currentDocument.IHTMLDocument3_getElementsByTagName("input") | Select-Object Type, Name
# $currentDocument.links | Select-Object outerText, href
# $currentDocument
# $downloadLink = $currentDocument.links | Where-Object { $_.outerText -eq 'Download' } | Select-Object -ExpandProperty href -First 1
# $downloadLink
$ieObject.Quit()
[void][Runtime.Interopservices.Marshal]::ReleaseComObject($ieObject)