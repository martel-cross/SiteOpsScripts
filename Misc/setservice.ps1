$computers = get-vm |?{$_.name -like "*lm*"}
$computers | foreach{
$_.name
$computername = $_.name
$services = get-service -computername $_.name | select * | ?{$_.displayname -like "*logic*"}

foreach ($service in $services){
$service.name
sc.exe "\\$computername" failure $service.servicename reset= 0 actions= restart/0
}
}