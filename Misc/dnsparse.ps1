$newsubnet = @()
$zone =(get-content subnettest.txt) 
$subnets = get-adreplicationsubnet -filter * | select name
$zone = $zone.replace('1200','')
$zone = $zone.replace('86400','')
$zone = $zone -replace '\s+', ','
$zone | foreach{
$zonerecord1,$zonerecord2,$zonerecord3 = $_.split(",",3)
$filter = "\b\d{1,3}\.d{1,3}\.d{1,3}\.\d{1,3}\b"
$zonerecord3 = $zonerecord3.trim()
if ($zonerecord3 -match "\d{1,3}(\.\d{1,3}){3}"){
$octet1,$octet2,$octet3,$octet4 = $zonerecord3.split(".",4)
$ipaddr= $octet1+"."+$octet2
}
$matchflag = 0
foreach($subnet in $subnets){
[string]$subnetstr = $subnet.name
$subnetstrlen=$subnetstr.length
$startstr = $subnetstrlen - 3
$subnetmask = $subnetstr.substring($startstr,3)
$subnetstr = $subnetstr.replace($subnetmask,"")
$octet1,$octet2,$octet3,$octet4 = $subnetstr.split('.',4)
$subnetip= $octet1+"."+$octet2

if ($subnetip -eq $ipaddr){$matchflag = 1}
}
if($matchflag -eq 0){$newsubnet=$newsubnet+ $ipaddr}
}
$newsubnet | get-unique