
$cbatlUser = "jterry.site"
$cbatlFile = "acklog2.txt"
$cbUser = "cb\jterry"
$cbFile = "acklog.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
$cbCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(Get-Content $cbFile | ConvertTo-SecureString)
Set-JiraConfigServer -server "http://siteopssupport.careerbuilder.com" -ConfigFile "c:\cbatlpci\jiraconfig.xml"
New-JiraSession -Credential $cbatlcreds 
#get-jirauser -username "Siteops" 
$summary = "test automation"
$description = "test test ignore ignore"
#New-jiraissue -project "IRQ" -issuetype "Task" -Priority 3 -Summary $summary -Description $description  -labels ""
#Send-MailMessage -to siteopssupport@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $summary -body $description -Attachments "c:\cbatlpci\gpotest.htm"

$issues = (Invoke-restmethod -uri http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project=irq ).issues

$issues | foreach{
$ticket=$_
 if (($_.fields.Summary -like $summary) -and (!$_.fields.resolutiondate)){ 
 get-jiraissue $ticket.key | set-jiraissue -assignee "jterry.site"}
#invoke-webrequest -uri http://siteopssupport.careerbuilder.com/rest/api/2/issue/irq-1235/attachment -contenttype "no check" -method post -outfile "c:\cbatlpci\gpotest.htm" -credential $cbatlcreds
  }
