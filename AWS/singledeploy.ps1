#deploy luigi DR

# $localcreds = get-credential -username "administrator" -message "local Creds"
# $domaincreds = get-credential -username "cbatl\jterry.site" -message "Domain Creds"
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "c:\temp\acklog2.txt"
$cbUser = "administrator"
$cbFile = "c:\temp\acklog3.txt"
$domainCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(get-content $cbatlFile | ConvertTo-SecureString)
$localCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(get-content $cbFile | ConvertTo-SecureString)

#$pools = import-csv luigideploypools.csv


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
$value = $ELBId
 New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
	}

$subnetid = (get-ec2subnet -region $region | ?{$_.availabilityzone -eq $regionaz} | ?{$_.vpcid -eq "vpc-0f588368"}).subnetid 
$ec2inst = new-ec2instance -imageid "ami-e23dfd8f" -instanceprofile_name "elb-role" -instancetype "m4.xlarge" -keyname "SiteOps-Key" -availabilityzone $regionaz -subnetid $subnetid -securitygroupid "sg-4575fc3e" -maxcount 1 -region $region -force
Start-sleep 600
$tag = New-Object Amazon.EC2.Model.Tag
$tag.Key = "Name"
$tag.Value = $deployname
New-EC2Tag -Resource $ec2inst.instances.instanceid -Tag $tag -region $region
#$currentname = (Get-WmiObject -computername $ec2inst.instances.privateipaddress -Class Win32_ComputerSystem -Property Name).Name
start-sleep 90
rename-computer -computername $ec2inst.instances.privateipaddress -newname $deployname -localcredential $localcreds -force -restart
start-sleep 300
Add-Computer -ComputerName $ec2inst.instances.privateipaddress -LocalCredential $localcreds -DomainName "atl.careerbuilder.com" -Credential $domaincreds -OU "OU=MT,OU=DRAWS,OU=Servers,DC=atl,DC=careerbuilder,DC=com" -Restart -Force
start-sleep 900
$destination = "\\"+$ec2inst.instances.privateipaddress+"\c$\GitHub"
xcopy \\qtmvcmdr1\C$\GitHub $destination  /E /I
start-sleep 300
$Instanceid = (get-ec2instance -region us-east-1 | ?{$_.instances.tags.value -eq $deployname}).instances.instanceid
Invoke-Command -ScriptBlock $keyset -ComputerName $deployname -Credential $domaincreds -argumentlist $instanceid
Invoke-Command -ScriptBlock $ELkeyset -ComputerName $deployname -Credential $domaincreds -argumentlist $Role
invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\newKaseyaInstall.ps1" -argumentlist "luigi", $role
start-sleep 300
# invoke-command -computername $ec2inst.instances.privateipaddress -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\newlmscript.ps1" -argumentlist $deployname, "luigi", "add", $role
# start-sleep 60
invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\McafeeSmartInstall.ps1"
start-sleep 300
invoke-command -computername $deployname -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\alertlogicinstall.ps1" -argumentlist "luigi", $deployname
start-sleep 300
# invoke-command -computername $ec2inst.instances.privateipaddress -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\alertlogic_policy_assignment.ps1" -argumentlist "luigi", $deployname
# start-sleep 60
invoke-command -computername $deployname -scriptblock{dism /online /Enable-Feature /FeatureName:TelnetClient}
start-sleep 300
rmdir $destination /s /q
}
#-and ($deployname -ne "drawsasync06")
$deployname = "drawsblast01"
$role = "cbasync"
$regionaz = "us-east-1c"
$region = "us-east-1"



start-job -name $deployname -scriptblock $maketheserver -argumentlist $deployname,$role,$regionaz,$region,$localcreds,$domaincreds
# foreach($pool in $pools){
# $srvcnt = 0
# while($srvcnt -lt 6){
# $deployname = $pool.servername +$srvcnt
# $role = $pool.pool
# if ($pool.servername -notlike "*mail*"){$deployname = $deployname.replace("00","06")}
# if (($srvcnt -eq 0) -or ($srvcnt -eq 1)){$regionaz = "us-east-1a"}
# if (($srvcnt -eq 2) -or ($srvcnt -eq 3)){$regionaz = "us-east-1b"}
# if (($srvcnt -eq 4) -or ($srvcnt -eq 5)){$regionaz = "us-east-1c"}
# if (($deployname -ne "drawsasync01") -and ($deployname -ne "drawsasync02")-and ($deployname -ne "drawsasync06")){
# start-job -name $deployname -scriptblock $maketheserver -argumentlist $deployname,$role,$regionaz,$region,$localcreds,$domaincreds
# while((get-job -state "Running").count -gt 2){start-sleep 10}}
# $srvcnt = $srvcnt + 1
# }
# }