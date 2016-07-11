
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "c:\temp\acklog2.txt"
$cbUser = "administrator"
$cbFile = "c:\temp\acklog3.txt"
$domainCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(get-content $cbatlFile | ConvertTo-SecureString)
$localCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(get-content $cbFile | ConvertTo-SecureString)

$ELkeyset = {
param($ELBid)
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$Name = "AWSELBId"
$value = $ELBId
 New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
	}



$pools = import-csv luigideploypools.csv
foreach($pool in $pools){
$ELBid = $pool.pool
if ($ELBid -like "mail*"){$namepattern = "^"+$pool.servername +"[0-5]{1}$"} else{
$namepattern = $pool.servername +"*"}

$servers = (get-ec2instance -region US-EAST-1 | ?{$_.instances.tags.value -match $namepattern}).instances.tags.value
foreach($server in $servers){

write-host $server $ELBid $namepattern
Invoke-Command -ScriptBlock $ELkeyset -ComputerName $server -Credential $domaincreds -argumentlist $ELBid

}
}