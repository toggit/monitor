$IE = New-Object -ComObject 'InternetExplorer.Application'
$IE.Visible = $true
Start-Sleep -Seconds 5
$IE.navigate("https://")
Start-Sleep -Seconds 5
$HomePage = $IE.Document
#$HomePage.IHTMLDocument3_getElementsByTagName("Input")
Start-Sleep -Milliseconds 500
$UserName = $HomePage.IHTMLDocument3_getElementsByTagName("Input") | where-object { $_.name -eq 'UserName' }
$Password = $HomePage.IHTMLDocument3_getElementsByTagName("Input") | where-object { $_.name -eq 'Password' }
Start-Sleep -Milliseconds 500
$SubmitButton = $HomePage.all | Where-Object { $_.tagname -like 'DIV*' } | Where-Object { $_.classname -eq 'SubmitButton' }
#read-host -assecurestring | convertfrom-securestring | out-file C:\temp\pw.txt
$pwcheck = get-content C:\temp\pw.txt | convertto-securestring
$Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist "XXXXXXXXXXXXx", $pwcheck
Start-Sleep -Milliseconds 500
$UserName.value = $Credential.UserName
$Password.value = $credential.GetNetworkCredential().Password
Start-Sleep -Milliseconds 500
$SubmitButton.click()
Start-Sleep -Seconds 5


$Search = $HomePage.all | Where-Object { $_.tagname -like 'DIV*' } | Where-Object { $_.classname -eq 'search' } | foreach { $_.children }

Start-Sleep -Seconds 3
$Search.value = "XXXXXXXXX"
Start-Sleep -Milliseconds 500
$SearchButton = $HomePage.all | Where-Object { $_.tagname -like 'DIV*' } | Where-Object { $_.classname -eq 'ButtonGroup ExecuteSearch' } | foreach { $_.children }
Start-Sleep -Milliseconds 500
$SearchButton.click()
Start-Sleep -Seconds 5


$frame = ($ie.document.getElementsByTagName("iframe"))[0]
$Iframe = $frame.contentWindow.document

$TicketNumber = $Iframe.getElementsByTagName("td") | where-object { $_.classname -like 'Text C  U3' } 

Start-Sleep -Seconds 5

$TicketNumber.click()
Start-Sleep -Seconds 5

$FirstPopUp = New-Object -ComObject Shell.Application
$NewIE = $FirstPopUp.windows()
$AccessIE = ($NewIE | Where-Object { $_.LocationName -like "*XXXXXXXX*" }).document
$AccessIE


#$EditButton = $AccessIE.all | Where-Object {$_.tagname -like 'DIV'} | Where-Object {$_.classname -eq 'ToolBarItem Left ButtonGroupStart'} | Where-Object {$_.textcontent -like 'edit'}
#$EditButton = $AccessIE.all | Where-Object {$_.tagname -eq "SPAN" -and $_.classname -eq "Text" -and $_.innertext -eq "edit"}