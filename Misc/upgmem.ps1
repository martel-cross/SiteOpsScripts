$vms = get-vm eaglepmta*
foreach($vm in $vms){
$vm.name
stop-vm $vm
get-vmresourceconfiguration $vm | Set-vmresourceconfiguration memreservationMB 2048
set-vm $vm -memoryMB 4096
start-vm $vm
start-sleep -seconds 600
}