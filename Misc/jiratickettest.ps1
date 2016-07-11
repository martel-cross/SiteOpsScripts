

$cbatlUser = "jterry.site"
$cbatlFile = "C:\SiteOpsScripts\cbatlpci\acklog2.txt"
$cbUser = "cb\jterry"
$cbFile = "C:\SiteOpsScripts\cbatlpci\acklog.txt"
$jirauser = "sitesrvc"
$jirafile = "C:\SiteOpsScripts\jiraauto\jira.txt"
$jiraCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $jiraUser,(Get-Content $jiraFile | ConvertTo-SecureString)
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
$cbCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(Get-Content $cbFile | ConvertTo-SecureString)
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
$summary = "test ticket"
$description = " this is a test"
$body = '{
    "fields": {
       "project":
       { 
          "key": "IRQ"
       },
       "summary": "'+$summary+'",
       "description": "'+$description+'",
       "issuetype": {
          "name": "Task"
       }
   }
}'

Invoke-restmethod -method post -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/" -Headers $headers -contenttype "application/json" -body $body -timeoutsec 60