
$down = {D:\deploymentv3\DeploymentLoadbalancer\DeploymentLoadBalancer.exe -m out;net stop WAS /Y}
$up = {net start w3svc;D:\deploymentv3\DeploymentLoadbalancer\DeploymentLoadBalancer.exe -mw in}
$keyset = {
param($instanceid)
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$Name = "AWSInstanceId"
$value = $InstanceId

# $registryPath1 = "HKLM:\SYSTEM\CurrentControlSet\Services\TCPIP\Parameters"
# $Name1 = "TcpWindowSize"
# $value1 = "64240"
# $registrypath2 = "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters";$name2="MaxUserPort"; $value2=51024
# $registrypath3="HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters";$name3="TcpTimedWaitDelay"; $value3=30




# remove-itemproperty -path $registrypath1 -Name $name1
# netsh interface tcp set global autotuning=disabled
# netsh interface tcp set heuristics disabled

# IF(!(Test-Path $registryPath2))

  # {

    # New-Item -Path $registryPath2 -Force | Out-Null

    # New-ItemProperty -Path $registryPath2 -Name $name2 -Value $value2 -PropertyType DWORD -Force | Out-Null}

 # ELSE {
 New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
   # New-ItemProperty -Path $registryPath2 -Name $name2 -Value $value2 -PropertyType DWORD -Force | Out-Null
	#}


    #New-ItemProperty -Path $registryPath3 -Name $name3 -Value $value3 -PropertyType DWORD -Force | Out-Null
	
	}
	$cred = (get-credential)
	#$svrnames = (get-vm cbasync*).name
	$svrnames =(get-ec2instance -region us-east-1 | ?{$_.instances.tags.value -like "draws*"}).instances.tags.value
	foreach($svrname in $svrnames){
	
	#$svrname = "GHQREBELWEB01"
	#if (($svrname -notlike "*GHQ*") -and ($svrname -notlike "*rebel*") -and ( ($svrname -match '[5-6][0-9]') )){
	#$svrname2 = $svrname.replace("bear","rebel")
	$svrname
	$Instanceid = (get-ec2instance -region us-east-1 | ?{$_.instances.tags.value -eq $svrname}).instances.instanceid
	#$svrname2
	Invoke-Command -ScriptBlock $keyset -ComputerName $svrname -Credential $cred -argumentlist $instanceid
	#Invoke-Command -ScriptBlock $keyset -ComputerName $svrname2 -Credential $cred
	# Invoke-Command -ScriptBlock $down -ComputerName $svrname -Credential $cred
	# Invoke-Command -ScriptBlock $down -ComputerName $svrname2 -Credential $cred
	 #update-tools -vm $svrname
	 # update-tools -vm $svrname2
	  #Start-sleep -seconds 150
	 #restart-vm -vm $svrname -confirm:$False 
	 # restart-vm -vm $svrname2 -confirm:$False
	  #Start-sleep -seconds 90
	  #restart-vm -vm $svrname -confirm:$False 
	 # restart-vm -vm $svrname2 -confirm:$False
	  #Start-sleep -seconds 360
	#Invoke-Command -ScriptBlock $up -ComputerName $svrname -Credential $cred
	 # Invoke-Command -ScriptBlock $up -ComputerName $svrname2 -Credential $cred
	#}
}


