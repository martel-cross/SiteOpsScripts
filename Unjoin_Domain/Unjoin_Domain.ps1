#Setup Envirnonement
$DNSServer = "QTMAD1" 
$DNSZone = "atl.careerbuilder.com" 
$servers = Get-Content "OldServers.txt" 

ForEach ($server in $servers) {

    Remove-ADComputer -Confirm:$false -Identity $server

    Remove-DnsServerResourceRecord -ZoneName "atl.careerbuilder.com" -ComputerName $DNSServer -RRType "A" -Name $server -Force

    Remove-Computer -ComputerName $server -LocalCredential "akira" -UnJoinDomainCredential "akira" -WorkgroupName WorkGroup -Force -Restart 
}
