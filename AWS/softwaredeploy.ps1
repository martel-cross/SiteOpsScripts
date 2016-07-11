$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "C:\cbatlpci\acklog2.txt"
$cbUser = "administrator"
$cbFile = "C:\cbatlpci\acklog3.txt"
$domainCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(get-content $cbatlFile | ConvertTo-SecureString)
$localCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(get-content $cbFile | ConvertTo-SecureString)


$region = "us-east-1"
#Start-sleep 30
$maketheserver ={
param($deployname,$role,$regionaz,$region,$localcreds,$domaincreds)
$keyset = {
param($instanceid)
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$Name = "AWSInstanceId"
$value = $InstanceId
 New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
	}
$ELkeyset = {
param($ELBid)
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$Name = "AWSELBId"
$serial = 0
While($serial -lt 7){
$add="10"+$serial
$ELbid = $elbid.replace($add,"")
$add="30"+$serial
$ELbid = $elbid.replace($add,"")
$add="1"+$serial
$ELbid = $elbid.replace($add,"")
$add="0"+$serial
$ELbid = $elbid.replace($add,"")
$serial = $serial +1
}
$value = $ELBId
 New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
	}
$destination = "\\"+$deployname+"\c$\GitHub"
xcopy \\qtmvcmdr1\C$\GitHub $destination  /E /I
$Instanceid = (get-ec2instance -region us-east-1 | ?{$_.instances.tags.value -eq $deployname}).instances.instanceid
Invoke-Command -ScriptBlock $keyset -ComputerName $deployname -Credential $domaincreds -argumentlist $instanceid
Invoke-Command -ScriptBlock $ELkeyset -ComputerName $deployname -Credential $domaincreds -argumentlist $deployname
start-sleep 300
invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\newKaseyaInstall.ps1" -credential $domaincreds -argumentlist "luigi",$role 
start-sleep 300
#invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\newlmscript.ps1" -credential $domaincreds -argumentlist $deployname,"luigi","add",$role 
#start-sleep 60
invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\McafeeSmartInstall.ps1" -credential $domaincreds
start-sleep 300
invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\alertlogicinstall.ps1" -credential $domaincreds -argumentlist "luigi",$deployname 
start-sleep 300
# invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\alertlogic_policy_assignment.ps1" -credential $domaincreds -argumentlist "luigi",$deployname 
# start-sleep 60
invoke-command -computername $deployname -scriptblock{dism /online /Enable-Feature /FeatureName:TelnetClient} -credential $domaincreds
start-sleep 300
rmdir $destination /s /q
}
$servers = (get-content agent23.csv).name
foreach($server in $servers){
$deployname = $server
start-job -name $deployname -scriptblock $maketheserver -argumentlist $deployname,$role,$regionaz,$region,$localcreds,$domaincreds
}
