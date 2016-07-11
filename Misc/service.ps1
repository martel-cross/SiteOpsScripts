$computers = get-adcomputer -filter * | ?{$_.distinguishedname -like "*DB servers*"} 
$computers | foreach{
if (test-connection -quiet $_.name -count 1){
$serviceget = get-service "wuauserv" -computername $_.name
Write-host $_.name $serviceget.name $serviceget.status
#$addtofile = $_.name+","+$serviceget.name+","+$serviceget.status
#add-content updateservices.csv $addtofile
}
}