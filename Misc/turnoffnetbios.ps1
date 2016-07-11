
$servers = (get-vm cbasync*).name
foreach($server in $servers){
 Write-host $server
$adapters=(gwmi win32_networkadapterconfiguration -computername $server)
Foreach ($adapter in $adapters){
  Write-Host $adapter
  $adapter.settcpipnetbios(2)
}
}