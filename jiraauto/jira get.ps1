
$cbatlUser = "jterry.site"
$cbatlFile = "C:\SiteOpsScripts\cbatlpci\acklog2.txt"
$cbUser = "cb\jterry"
$cbFile = "C:\SiteOpsScripts\cbatlpci\acklog.txt"
$jirauser = "sitesrvc"
$jirafile = "C:\SiteOpsScripts\jiraauto\jira.txt"
$jiraCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $jiraUser,(Get-Content $jiraFile | ConvertTo-SecureString)
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
$cbCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(Get-Content $cbFile | ConvertTo-SecureString)
$issue = "IRQ-1377"
$creds = $jiracreds
$issues =  Get-JiraIssue -query  'project = "IRQ" and status = "To Do"' -credential $jiracreds 
#*************************************************************************************************************************************
#Form Authentication header
$user = $creds.username
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds.Password)
$Pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
#Collect Headers for send
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization', $basicAuthValue)
$headers.Add('accept','application/json')
$issues | foreach{
$issue = $_


$body = '{ "name": "'+$assignee+'" }'

$uri = "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$issue.key+"/assignee"

$body
$uri
#$webResponse = Invoke-RestMethod -method put -Uri $uri -Headers $headers -contenttype "application/json" -body $body 
}