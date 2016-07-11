$pathfile = "C:\SiteOpsScripts\kaseya\agent2.csv"
clear-content $pathfile
$computers = get-adcomputer -filter {enabled -eq "true"} -Properties * | ?{$_.OperatingSystem -like "*Windows*"} |Select-Object -Property Name,OperatingSystem,DNSHostName | Sort-Object -Property OperatingSystem
foreach ($computer in $computers){

$test = test-connection $computer.dnshostname -count 1 -quiet

if ($test) {
$color = "white"
    
    $service = get-service -computername $computer.dnshostname |?{$_.displayname -like "*Kaseya*"}

	if (!$service){
	$color = "red"
	add-content agent2.csv $computer.dnshostname
	}
Write-host -foregroundcolor $color $computer.dnshostname
    #if (($service.status -ne "Running") -or (!$service)){add-content $pathfile $computer.dnshostname} 
  }
}
Send-MailMessage -to siteopssupport@careerbuilder.com -from kaseyaagent@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Missing Kaseya Agent Report" -body "Report is attached" -attachment agent2.csv
#Send-MailMessage -to joel.terry@careerbuilder.com -from kaseyaagent@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Missing Kaseya Agent Report" -body "Report is attached" -attachment agent2.csv
#Error reporting************************************************************************
if ($error.count -gt 0){
$body = $error | out-string
Send-MailMessage -to sitebackend@careerbuilder.com -from kaseyaagent@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Missing Kaseya Agent Report Errors" -body $body}