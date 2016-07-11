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
$headers.add('X-Atlassian-Token','no-check')
$i = 0
While ($i -lt 10000){
$captainsmek = Invoke-restmethod -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project='IRQ'+AND+status='To Do'+or+status='In Progress'" -Headers $headers -timeoutsec 30 | select -ExpandProperty issues
$i=$i+1
write-host -foregroundcolor "Green" $i -nonewline

Start-sleep -seconds 30
}