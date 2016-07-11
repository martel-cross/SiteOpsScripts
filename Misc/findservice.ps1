clear-content $pathfile
$computers = get-adcomputer -filter {enabled -eq "true"} | ?{$_.dnshostname -notlike "*ad*"} 
foreach ($computer in $computers){
$computer.dnshostname
$test = test-connection $computer.dnshostname -count 1 -quiet
if ($test){
$service = get-service -computername $computer.dnshostname | ?{$_.displayname -like "*kaseya*"}
if (($service.status -ne "Running") -or (!$service)){add-content $pathfile $computer.dnshostname} 
}
}