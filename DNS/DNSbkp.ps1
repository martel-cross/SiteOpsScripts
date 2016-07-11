dnscmd qtxad2.atl.careerbuilder.com /enumzones  | out-file dnszones.txt
$filedate = get-date -f MMddyyyy
$filetermdate = (get-date).adddays(-30)
$a = get-content dnszones.txt | select-string ".com"
$a | foreach {
$zonename = $_ | out-string
$zonename = $zonename.trim()
$zonename = (((($zonename.replace("Primary","")).replace("AD-Domain","")).replace("Update","")).replace("Secure","")).replace("AD-Forest","")
$zonename = $zonename.trim()
$filename2 = $zonename +$filedate+".dnsbkp.txt"

dnscmd qtxad2.atl.careerbuilder.com /zoneexport $zonename $filename2
}
move \\qtxad2\c$\Windows\System32\dns\*.dnsbkp.txt c:\siteopsscripts\dns\repo
$repofiles = Get-childitem c:\siteopsscripts\dns\repo
$repofiles | foreach{
if($_.lastwritetime -lt $filetermdate){
$filename = "c:\siteopsscripts\dns\repo\"+$_.name
remove-item $filename}
}
# if ((get-scheduledtaskinfo "DNS Zone Backup" |select *).lasttaskresult -eq 0){
# Send-MailMessage -to sitebackendalerts@careerbuilder.com -from DNSBKP@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL DNS Zone Export" -body "Zone Export Successful"}
#else{Send-MailMessage -to sitebackendalerts@careerbuilder.com -from DNSBKP@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL DNS Zone Export Failure" -body "Zone Export Failed"}