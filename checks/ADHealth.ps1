#############################################################################
#       Description: AD Health Status
#       Satus: Ping,Netlogon,NTDS,DNS,DCdiag Test(Replication,sysvol,Services)
#############################################################################

function ADHealth {
   [CmdletBinding()]
   [OutputType([Hashtable])]
   param (
      [Parameter(Mandatory = $false)]
      [String]
      $DC = (Get-WmiObject Win32_OperatingSystem).CSName
   )

   $timeout = "60"
   $result = @{
      isDC             = $false
      NetLogon_Service = $false
      NTDS_Service     = $false
      DNS_Service      = $false
      Netlogon         = $false
      Replications     = $false
      sysvol           = $false
      Advertising      = $false
      FSMOCheck        = $false
      status           = $true
   }

   Write-Verbose "result: $result"
   Write-Verbose "DC: $DC"
   #####################################Get ALL DC Servers#################################
   #$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
   #$DCServers = $getForest.domains | ForEach-Object { $_.DomainControllers } | ForEach-Object { $_.Name }

   #########################################
   ##############isDC Status################
   $serviceStatus = start-job -scriptblock { Get-wmiObject -Class Win32_OperatingSystem }
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.ProductType -eq 2) {
         Write-Host $DC `t $serviceStatus1.CSName `t $serviceStatus1.status -ForegroundColor Green   
         $result.isDC = $true
      }
      else { 
         Write-Host $DC `t $serviceStatus1.CSName `t $serviceStatus1.status -ForegroundColor Red
      } 
   }
   wait-job $serviceStatus
   ##############Netlogon Service Status################
   $serviceStatus = start-job -scriptblock { get-service -Name "Netlogon" -ErrorAction SilentlyContinue }
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.status -eq "Running") {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green
         $result.NetLogon_Service = $true       
      }
      else {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red
      }
   }
   ######################################################
   ##############NTDS Service Status################
   $serviceStatus = start-job -scriptblock { get-service -Name "NTDS" -ErrorAction SilentlyContinue }
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t NTDS Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.status -eq "Running") {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         $result.NTDS_Service = $true         
      }
      else { 
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red       
      } 
   }
   ######################################################
   ##############DNS Service Status################
   $serviceStatus = start-job -scriptblock { get-service -Name "DNS" -ErrorAction SilentlyContinue }
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t DNS Server Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.status -eq "Running") {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         $result.DNS_Service = $true
      }
      else { 
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red          
      } 
   }
   ######################################################

   ####################Netlogons status##################
   add-type -AssemblyName microsoft.visualbasic 
   $cmp = "microsoft.visualbasic.strings" -as [type]
   $sysvol = start-job -scriptblock { dcdiag /test:netlogons /s:$($args[0]) } -ArgumentList $DC
   wait-job $sysvol -timeout $timeout
   if ($sysvol.state -like "Running") {
      Write-Host $DC `t Netlogons Test TimeOut -ForegroundColor Yellow
      stop-job $sysvol
   }
   else {
      $sysvol1 = Receive-job $sysvol
      if ($cmp::instr($sysvol1, "passed test NetLogons")) {
         Write-Host $DC `t Netlogons Test passed -ForegroundColor Green
         $result.Netlogon = $true
      }
      else {
         Write-Host $DC `t Netlogons Test Failed -ForegroundColor Red
      }
   }
   ########################################################
   ####################Replications status##################
   add-type -AssemblyName microsoft.visualbasic 
   $cmp = "microsoft.visualbasic.strings" -as [type]
   $sysvol = start-job -scriptblock { dcdiag /test:Replications /s:$($args[0]) } -ArgumentList $DC
   wait-job $sysvol -timeout $timeout
   if ($sysvol.state -like "Running") {
      Write-Host $DC `t Replications Test TimeOut -ForegroundColor Yellow
      stop-job $sysvol
   }
   else {
      $sysvol1 = Receive-job $sysvol
      if ($cmp::instr($sysvol1, "passed test Replications")) {
         Write-Host $DC `t Replications Test passed -ForegroundColor Green
         $result.Replications = $true
      }
      else {
         Write-Host $DC `t Replications Test Failed -ForegroundColor Red
      }
   }
   ########################################################
   ####################sysvol status##################
   add-type -AssemblyName microsoft.visualbasic 
   $cmp = "microsoft.visualbasic.strings" -as [type]
   $sysvol = start-job -scriptblock { dcdiag /test:Services /s:$($args[0]) } -ArgumentList $DC
   wait-job $sysvol -timeout $timeout
   if ($sysvol.state -like "Running") {
      Write-Host $DC `t Services Test TimeOut -ForegroundColor Yellow
      stop-job $sysvol
   }
   else {
      $sysvol1 = Receive-job $sysvol
      if ($cmp::instr($sysvol1, "passed test Services")) {
         Write-Host $DC `t Services Test passed -ForegroundColor Green
         $result.sysvol = $true
      }
      else {
         Write-Host $DC `t Services Test Failed -ForegroundColor Red
      }
   }
   ########################################################
   ####################Advertising status##################
   add-type -AssemblyName microsoft.visualbasic 
   $cmp = "microsoft.visualbasic.strings" -as [type]
   $sysvol = start-job -scriptblock { dcdiag /test:Advertising /s:$($args[0]) } -ArgumentList $DC
   wait-job $sysvol -timeout $timeout
   if ($sysvol.state -like "Running") {
      Write-Host $DC `t Advertising Test TimeOut -ForegroundColor Yellow
      stop-job $sysvol
   }
   else {
      $sysvol1 = Receive-job $sysvol
      if ($cmp::instr($sysvol1, "passed test Advertising")) {
         Write-Host $DC `t Advertising Test passed -ForegroundColor Green
         $result.Advertising = $true
      }
      else {
         Write-Host $DC `t Advertising Test Failed -ForegroundColor Red
      }
   }
   ########################################################
   ####################FSMOCheck status##################
   add-type -AssemblyName microsoft.visualbasic 
   $cmp = "microsoft.visualbasic.strings" -as [type]
   $sysvol = start-job -scriptblock { dcdiag /test:FSMOCheck /s:$($args[0]) } -ArgumentList $DC
   wait-job $sysvol -timeout $timeout
   if ($sysvol.state -like "Running") {
      Write-Host $DC `t FSMOCheck Test TimeOut -ForegroundColor Yellow
      stop-job $sysvol
   }
   else {
      $sysvol1 = Receive-job $sysvol
      if ($cmp::instr($sysvol1, "passed test FsmoCheck")) {
         Write-Host $DC `t FSMOCheck Test passed -ForegroundColor Green
         $result.FSMOCheck = $true
      }
      else {
         Write-Host $DC `t FSMOCheck Test Failed -ForegroundColor Red
      }
   }
   ########################################################
   foreach ($key in @($result.keys)) {
      if ($result[$key] -eq $false) {
         $result.status = $false
      }
   }
   return $result
}
########################################################################################

########################################################################################

# TODO: need to check that ADHealth script working.
# ADHealth -DC "newdc" -Cred (GetSecuity -Security "tog")