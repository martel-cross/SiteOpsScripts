import-csv dnsrecords.csv | foreach{
DNSCMD qtxad2 /Recordadd cb.local $_.name A $_.ipaddr
DNSCMD qtxad2 /Recorddelete atl.careerbuilder.com $_.name A $_.ipaddr /f

}