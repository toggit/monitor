#############################################################################
#       Description: AD Health Status
#       Satus: Ping,Netlogon,NTDS,DNS,DCdiag Test(Replication,sysvol,Services)
#############################################################################

function ADHealth {
   
   $timeout = "60"
   $result = @{ 
      isDC         = $false
      NetLogon     = $false
      NTDS         = $false
      DNS          = $false
      DCdiag       = $false
      Replications = $false
      sysvol       = $false
      Advertising  = $false
      FSMOCheck    = $false
   }
   #####################################Get ALL DC Servers#################################
   $getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
   $DCServers = $getForest.domains | ForEach-Object { $_.DomainControllers } | ForEach-Object { $_.Name } 
   if ($DC -in $DCServers) {
      $result.isDC = $true
   }

   ################Ping Test######

   # foreach ($DC in $DCServers) {
   # $Identity = $DC
   # if ( Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue ) {
   #    Write-Host $DC `t $DC `t Ping Success -ForegroundColor Green

   ##############Netlogon Service Status################
   $serviceStatus = start-job -scriptblock { get-service -ComputerName $($args[0]) -Name "Netlogon" -ErrorAction SilentlyContinue } -ArgumentList $DC
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.status -eq "Running") {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         $svcName = $serviceStatus1.name 
         $svcState = $serviceStatus1.status   
         $result.Netlogon = $true       
      }
      else { 
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         $svcName = $serviceStatus1.name 
         $svcState = $serviceStatus1.status          
      } 
   }
   ######################################################
   ##############NTDS Service Status################
   $serviceStatus = start-job -scriptblock { get-service -ComputerName $($args[0]) -Name "NTDS" -ErrorAction SilentlyContinue } -ArgumentList $DC
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t NTDS Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.status -eq "Running") {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         $svcName = $serviceStatus1.name 
         $svcState = $serviceStatus1.status    
         $result.NTDS = $true         
      }
      else { 
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         $svcName = $serviceStatus1.name 
         $svcState = $serviceStatus1.status          
      } 
   }
   ######################################################
   ##############DNS Service Status################
   $serviceStatus = start-job -scriptblock { get-service -ComputerName $($args[0]) -Name "DNS" -ErrorAction SilentlyContinue } -ArgumentList $DC
   wait-job $serviceStatus -timeout $timeout
   if ($serviceStatus.state -like "Running") {
      Write-Host $DC `t DNS Server Service TimeOut -ForegroundColor Yellow
      stop-job $serviceStatus
   }
   else {
      $serviceStatus1 = Receive-job $serviceStatus
      if ($serviceStatus1.status -eq "Running") {
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         $svcName = $serviceStatus1.name 
         $svcState = $serviceStatus1.status   
         $result.DNS = $true
      }
      else { 
         Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         $svcName = $serviceStatus1.name 
         $svcState = $serviceStatus1.status          
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
         $result.sysvol = $true
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
      }
      else {
         Write-Host $DC `t FSMOCheck Test Failed -ForegroundColor Red
      }
   }
   ########################################################
                
} 
# else {
#    Write-Host $DC `t $DC `t Ping Fail -ForegroundColor Red
# }         
       

########################################################################################

########################################################################################
 
         	
		