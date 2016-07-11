$cbatlUser = "jterry.site"
$cbatlFile = "C:\SiteOpsScripts\cbatlpci\acklog2.txt"
$cbUser = "cb\jterry"
$cbFile = "C:\SiteOpsScripts\cbatlpci\acklog.txt"
$jirauser = "sitesrvc"
$jirafile = "C:\SiteOpsScripts\jiraauto\jira.txt"
$jiraCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $jiraUser,(Get-Content $jiraFile | ConvertTo-SecureString)
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
$cbCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(Get-Content $cbFile | ConvertTo-SecureString)
#Set-JiraConfigServer -server "http://siteopssupport.careerbuilder.com" -ConfigFile "C:\SiteOpsScripts\jiraauto\jiraconfig.xml"

#$issues =  Get-JiraIssue -query  'project = "IRQ" and status = "To Do"' -credential $jiracreds 
#GET ISSUES ************************************************************************************************************
$user = $jiracreds.username
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($jiracreds.Password)
$Pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
#Collect Headers for send
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization', $basicAuthValue)
$headers.Add('accept','application/json')

$issues = Invoke-RestMethod -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project=IRQ+AND+status='To Do'" -Headers $headers | select -ExpandProperty issues

$jiraflag = ''

$issues | foreach{
$logincount = 0
$issue = $_

#New Hire Ticket Processing**************************************************
if (($_.fields.Summary -like "*new hire*")){ clear-content description.txt;$ticket = $_.fields.description.tostring() ; add-content description.txt $ticket ; $ticketsubstr = get-content description.txt | select-string "Manager" ; 
#$ticketsubstr | foreach{
$mgrstr = $ticketsubstr.tostring().trim("Manager").trim()

#Write-host -foregroundcolor "yellow" $mgrstr
$mgruser = get-aduser -filter{displayname -eq $mgrstr} -properties displayname,memberof,mail -server cb.careerbuilder.com -credential $cbcreds
If (!$mgruser){ 
$mgrstrsearch = "*"+$mgrstr + "*"
$mgruser = get-aduser -filter{displayname -like $mgrstrsearch} -properties displayname,memberof,mail -server cb.careerbuilder.com -credential $cbcreds}
write-host $issue.key $mgrstr $mgruser
}}
