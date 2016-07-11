Function pulldata{
param($serverpop)
$servers = (get-vm $serverpop).name
foreach($server in $servers){
$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter "DeviceID='D:'" | Select-Object Size,FreeSpace
$addtofile = $server+","+($disk.size/1GB)+","+($disk.freespace/1GB)
add-content diskspacebyserver.csv $addtofile
}
}
clear-content diskspacebyserver.csv
$header = "Server,Size,Freespace"
add-content diskspacebyserver.csv $header
pulldata cb*
pulldata mail*


