# clear-content dnspurgepending.csv
get-content c:\siteopsscripts\dns\repo\idrac.careerbuilder.com06032016.dnsbkp.txt | foreach{
$dnsname,$dnsoptions,$dnsipsplat =$_.split(" ",3)
if (($dnsipsplat) -and ($dnsname)){
$dnsipsplat = $dnsipsplat.replace(" ","")
$dnsipsplat = $dnsipsplat.replace("A","")
$dnsipsplat = $dnsipsplat.replace("86400","")
$dnsipsplat = $dnsipsplat.replace("1200","")
$dnsipsplat = $dnsipsplat.replace("`t","")
if ($dnsipsplat -match "\b(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}\b"){

$test = test-connection $dnsname -count 1 -quiet
if (!$test){$test = test-connection $dnsipsplat -count 1 -quiet}
if (!$test){
write-host -foregroundcolor "yellow" $dnsname $dnsipsplat $test
dnscmd qtxad2 /recorddelete idrac.careerbuilder.com $dnsname A /f
# $addtofile = $dnsname+","+$dnsipsplat
# add-content dnspurgepending.csv $addtofile
}
}}}
# get-content c:\siteopsscripts\dns\repo\atl.careerbuilder.com06142016.dnsbkp.txt | foreach{
# $dnsname,$dnsoptions,$dnsipsplat =$_.split(" ",3)
# if (($dnsipsplat) -and ($dnsname)){
# $dnsipsplat = $dnsipsplat.replace(" ","")
# $dnsipsplat = $dnsipsplat.replace("A","")
# $dnsipsplat = $dnsipsplat.replace("86400","")
# $dnsipsplat = $dnsipsplat.replace("1200","")
# $dnsipsplat = $dnsipsplat.replace("`t","")
# if ($dnsipsplat -match "\b(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}\b"){

# $test = test-connection $dnsname -count 1 -quiet
# if (!$test){$test = test-connection $dnsipsplat -count 1 -quiet}
# if (!$test){
# write-host -foregroundcolor "yellow" $dnsname $dnsipsplat $test
#dnscmd /recorddelete atl.careerbuilder.com $dnsname A /f
# $addtofile = $dnsname+","+$dnsipsplat
# add-content dnspurgepending.csv $addtofile
# }
# }}}