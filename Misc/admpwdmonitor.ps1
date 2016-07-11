$i =0

While($i -lt 1){
$list= get-content admpwdmonitor.txt
$chk = get-adcomputer -filter{ms-Mcs-AdmPwd -like "*"} -properties ms-Mcs-AdmPwd | select name
$chk | Foreach{
if ($list -notcontains $_.name){
send-mailmessage -from "joel.terry@careerbuilder.com" -to "joel.terry@careerbuilder.com" -Subject "New Server Being Maanged" -body $_.name -smtpserver relay.careerbuilder.com
#Write-host "sending lots of mail"
get-adcomputer -filter{ms-Mcs-AdmPwd -like "*"} -properties ms-Mcs-AdmPwd | select name | out-file admpwdmonitor.txt
}
}

start-sleep -seconds 7200
}