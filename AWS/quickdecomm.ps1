#deploy luigi DR

# $localcreds = get-credential -username "administrator" -message "local Creds"
# $domaincreds = get-credential -username "cbatl\jterry.site" -message "Domain Creds"
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "c:\temp\acklog2.txt"
$cbUser = "administrator"
$cbFile = "c:\temp\acklog3.txt"
$domainCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(get-content $cbatlFile | ConvertTo-SecureString)
$localCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(get-content $cbFile | ConvertTo-SecureString)

$pools = import-csv luigideploypools.csv

$region = "us-east-1"
#Start-sleep 30
$maketheserver ={
param($deployname,$role,$regionaz,$region,$localcreds,$domaincreds)

$destination = "\\"+$ec2inst.instances.privateipaddress+"\c$\GitHub"
xcopy \\qtmvcmdr1\C$\GitHub $destination  /E /I
# start-sleep 300
# invoke-command -computername $ec2inst.instances.privateipaddress -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\newKaseyaInstall.ps1" -credential $domaincreds -argumentlist "luigi",$role 
# start-sleep 300
# invoke-command -computername $ec2inst.instances.privateipaddress -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\removemcafeeEPO.ps1" -credential $domaincreds -argumentlist $deployname
# start-sleep 60
# invoke-command -computername $ec2inst.instances.privateipaddress -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\removemcafeeagent.ps1" -credential $domaincreds 
# start-sleep 300
# invoke-command -computername $ec2inst.instances.privateipaddress -file "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\removealertlogic.ps1" -credential $domaincreds -argumentlist $deployname 
# start-sleep 300
# remove-Computer -ComputerName $deployname -unjoindomainCredential $domaincreds -confirm:$false -Restart -Force
# start-sleep 300
$existing = (get-ec2instance -region us-east-1 | ?{$_.instances.tags.value -eq $deployname}).instances.instanceid
Stop-EC2Instance -Instance $existing -Terminate -Force -region $region
}
#-and ($deployname -ne "drawsasync06")
$existing ="DRAWSASYNC01","DRAWSASYNC02"
foreach($pool in $pools){
$srvcnt = 0
while($srvcnt -lt 6){
$deployname = $pool.servername +$srvcnt
$role = $pool.pool
if ($pool.servername -notlike "*mail*"){$deployname = $deployname.replace("00","06")}
if (($srvcnt -eq 0) -or ($srvcnt -eq 1)){$regionaz = "us-east-1a"}
if (($srvcnt -eq 2) -or ($srvcnt -eq 3)){$regionaz = "us-east-1b"}
if (($srvcnt -eq 4) -or ($srvcnt -eq 5)){$regionaz = "us-east-1c"}
if (($existing -notcontains $deployname)){
start-job -name $deployname -scriptblock $maketheserver -argumentlist $deployname,$role,$regionaz,$region,$localcreds,$domaincreds
#$deployname
while((get-job -state "Running").count -gt 10){start-sleep 10}}
$srvcnt = $srvcnt + 1
}
}