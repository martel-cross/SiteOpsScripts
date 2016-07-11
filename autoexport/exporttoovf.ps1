net use y: \\qtmbkp1\e$\vmexport\
$servers = import-csv exportservers.csv
foreach($server in $servers){
$clonename = $server.name +"clone"
$clonetask = new-vm -name $clonename -vm $server.name -resourcepool resources -confirm:$False -Runasync
Wait-task $clonetask
$exporttask = get-vm $clonename | export-vapp -destination "y:\" -confirm:$False -Runasync
Wait-task $exporttask
$removetask = remove-vm  $clonename -confirm:$False -Runasync

}
