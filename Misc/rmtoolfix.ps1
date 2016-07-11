 
 
 $servers = (Get-vm *dpi*).name
foreach($server in $servers){
$server
$error.clear
#get current value
#$x = (get-wmiobject -Namespace root -class __providerhostquotaconfiguration -computername $server)
#Write-Host "`r`nCurrent WMI Handles Per Host Value: $($x.HandlesPerHost)`r`n"
#set the new value
#$y = "8192"
#if($y -eq ""){$y="8192"}
#$x.handlesperhost = $y
#$x.put()
#Showing that all is OK
#$x = (get-wmiobject -Namespace root -class __providerhostquotaconfiguration -computername $server)
#Write-Host "Current WMI Handles Per Host Value: $($x.HandlesPerHost)`r`n"
#restarting the WMI service
write-host "Restarting Services...."
get-service winmgmt -computername $server | restart-service -force
start-sleep 10
While((get-service winmgmt -computername $server).status -ne "running"){start-sleep 5} 
get-service winrm -computername $server | restart-service -force
start-sleep 10
While((get-service winrm -computername $server).status -ne "running"){start-sleep 5}
write-host "Registering Powershell with WINRM & Restarting Services...."
 winrs /r:$server powershell -noprofile -command {register-pssessionconfiguration microsoft.powershell -NoServiceRestart -Force}
 winrs /r:$server powershell -noprofile -command {register-pssessionconfiguration microsoft.powershell32 -NoServiceRestart -Force}
 get-service winrm -computername $server | restart-service -force
 if ($error){add-content badservers.csv $server}
 }