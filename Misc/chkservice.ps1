$computers = get-vm |?{$_.name -like "*lm*"} |?{$_.name -notlike "*-*"}
$computers | foreach{
$_.name
$computername = $_.name
$services = get-service -computername $_.name | select * | ?{$_.displayname -like "*logic*"}

foreach ($service in $services){

if ($service.status -eq "Running"){ Write-host "test"}
if ($service.status -ne "Running"){
get-service -computername $computername  $service.name | start-service 
$recheck = get-service -computername $computername  $service.name
if ($recheck.status -ne "Running"){
$body = $body +"
" + $Computername+"    "+$service.name

}

}

}
}
if ($body){
Send-MailMessage -to lm-down-server@cbsiteops.pagerduty.com -from alerter@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "LogicMonitor Collector Issues" -body $body}