$subnets = get-adreplicationsubnet -filter * | select name
foreach($subnet in $subnets){
[string]$subnetstr = $subnet.name
$subnetstrlen=$subnetstr.length
$startstr = $subnetstrlen - 3
$subnetmask = $subnetstr.substring($startstr,3)
$subnetstr = $subnetstr.replace($subnetmask,"")
$octet1,$octet2,$octet3,$octet4 = $subnetstr.split('.',4)
 $assembly = $octet2+ "."+$octet1+".in-addr.arpa"
 if ($octet3 -notlike "0"){$assembly = $octet3+"."+$assembly
 if ($octet4 -notlike "0"){$assembly = $octet4+"."+$assembly}}
 dnscmd qtwad2 /zoneadd $assembly /dsprimary /DP /forest
 }

