
Function Jiranewhire
{param($issue,$mgrid,$assignee,$jflag,$issuecommts,$closewindow,$creds)
#No Action Needed Close Ticket**************************************************
$commentflag = 0

$issuecommts | foreach{
if ($_.author.displayname -like "*sitesrvc*"){$commentflag =1}
}
if ($jflag -eq "Close Ticket"){

$subject = $issue.key + " " + $issue.fields.summary + " - Closing No Account Needed"
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a new hire request.  

This Ticket has been closed by automation.  No Account is needed."
assignticket $issue $creds "sitesrvc"
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 

jiraworkflow $issue $creds "21"
}
#Action Needed, Ticket has already been processed, continuing**************************************
if (($jflag -eq "New Hire-Process") -and ($commentflag -gt 0)){
$commentcount = 0
$mgrresponseflag = 0
$closeflag = 0
 $issuecommts | foreach{
 $commentcount = $commentcount +1
 If ($_.updated -lt (get-date).adddays($closewindow)){$closeflag = $closeflag + 1} 
 if ($_.author.displayname -like $mgrid.displayname){ 
$mgrresponseflag = 1

assignticket $issue $creds "Random"

 }
 }
#Close the ticket from no response*****************************************************************
if (($closeflag -eq $commentcount) -and ($mgrresponseflag -eq 0)){
$subject = $issue.key + " " + $issue.fields.summary + " - Closing Due to No Response"
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a new hire request.  

This Ticket has been closed by automation after 5 business days of no response regarding the inquiry for this request. 
If this request needs to be reopened, please contact siteops@careerbuilder.com"
Send-MailMessage -to $mgrid.mail -cc siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 

assignticket $issue $creds "sitesrvc"
jiraworkflow $issue $creds "21"
}


 }
 #Action Needed - First processing****************************************************************************
if (($jflag -eq "New Hire-Process") -and ($issue.fields.status.name -eq "To Do")){

$subject = $issue.key + " " + $issue.fields.summary
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a new hire request.  

Please let us know if the new hire will need a CBATL site account and if so, which existing user we can copy for permissions? 

Simply reply to this email with the required information and it will be entered into the Siteops Ticket Queue. 

DO NOT REPLY IF THE ACCOUNT IS NOT NEEDED.  The system will automatically close the ticket after 5 business days. 

 Thank you."
 # Write-host $issue.key
Send-MailMessage -to $mgrid.mail -from siteopssupport@careerbuilder.com -cc siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
assignticket $issue $creds "sitesrvc"
jiraworkflow $issue $creds "11"
}
 }
 Function assignticket
 {param($jissue,$jcreds,$jassignee)
 if ($error){add-content errors.txt $error;$error.clear()}
 if ($jassignee -eq "Random"){$jassignee =("jterry.site","gnegelow.site","idiallo.site","jastone.site","jomunoz.site","mawelch.site")|get-random}
 #testing*************************************************
 
#$issue = "IRQ-1377"
#*************************************************************************************************************************************
#Form Authentication header
$user = $jcreds.username
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($jcreds.Password)
$Pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
#Collect Headers for send
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization', $basicAuthValue)
$headers.Add('accept','application/json')

$body = '{ "name": "'+$jassignee+'" }'
#$ticketnum = ($issue.key.tostring()).trim()
$juri = "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$jissue.key+"/assignee"
#While ($timeoutchk -gt -1){
$webResponse = Invoke-RestMethod -method put -Uri $juri -Headers $headers -contenttype "application/json" -body $body 
#if (($error | out-string) -notlike "*The operation has timed out*"){$timeoutchk = -1} else {$timeoutflag = $timeoutflag +1; $error.clear(); if ($timeoutflag -eq 6){$timeoutchk = -1}}
}
 #}
 Function jiraworkflow
 {param($wfissue,$wfcreds,$jiraworkflownum)
 if ($error){add-content errors.txt $error;$error.clear()}
$user = $wfcreds.username
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($wfcreds.Password)
$Pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
#Collect Headers for send
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization', $basicAuthValue)
$headers.Add('accept','application/json')
$body ='{"transition": {"id": "'+$jiraworkflownum+'"} }'
$juri ="http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$wfissue.key+"/transitions"
#While ($timeoutchk -gt -1){
Invoke-RestMethod -method post -Uri $juri -Headers $headers -contenttype "application/json" -body $body 
#if (($error | out-string) -notlike "*The operation has timed out*"){$timeoutchk = -1} else {$timeoutflag = $timeoutflag +1;  $error.clear();if ($timeoutflag -eq 6){$timeoutchk = -1}}
}
 #}

 Function ticketcomments
 {param($issue,$creds)
if ($error){add-content errors.txt $error;$error.clear()}
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
$juri ="http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$issue.key+"/comment?expand"
#While ($timeoutchk -gt -1){
$comments = Invoke-RestMethod  -Uri $juri -Headers $headers -contenttype "application/json"
#if (($error | out-string) -notlike "*The operation has timed out*"){$timeoutchk = -1} else {$timeoutflag = $timeoutflag +1; $error.clear();if ($timeoutflag -eq 6){$timeoutchk = -1}}
#}
$comments.comments
 
 }
$ErrorActionPreference = "silentlycontinue"
$error.clear()
Clear-content errors.txt
import-module activedirectory
#import-module psjira
#Add-Type -AssemblyName System.Web
 #Ticket Close window without Manager Comment response*******************************
$closewindow = -7
#*******************************************************
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
if ($error){add-content errors.txt $error;$error.clear()}
#While ($timeoutchk -gt -1){
$issues = Invoke-RestMethod -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project=IRQ+AND+status='To Do'+or+status='In Progress'" -Headers $headers | select -ExpandProperty issues
#if (($error | out-string) -notlike "*The operation has timed out*"){$timeoutchk = -1} else {$timeoutflag = $timeoutflag +1; $error.clear();if ($timeoutflag -eq 6){$timeoutchk = -1}}
#}
#if ($timeoutflag -lt 6){
$jiraflag = ''

$issues | foreach{
$logincount = 0
$issue = $_

#New Hire Ticket Processing**************************************************
if (($_.fields.Summary -like "*new hire*") -and (($_.fields.assignee.name -like "") -or($_.fields.assignee.name -like "*unassigned*") -or ($_.fields.assignee.name -like "*sitesrvc*"))){
clear-content description.txt;$ticket = $_.fields.description.tostring() ; add-content description.txt $ticket ; $ticketsubstr = get-content description.txt | select-string "Manager" 
#$ticketsubstr | foreach{
$mgrstr = $ticketsubstr.tostring().trim("Manager").trim()

#Write-host -foregroundcolor "yellow" $mgrstr
$mgruser = get-aduser -filter{displayname -eq $mgrstr} -properties displayname,memberof,mail -server cb.careerbuilder.com -credential $cbcreds
If (!$mgruser){ 
$mgrstrsearch = "*"+$mgrstr + "*"
$mgruser = get-aduser -filter{displayname -like $mgrstrsearch} -properties displayname,memberof,mail -server cb.careerbuilder.com -credential $cbcreds}

if (!$mgruser){

$subject = $issue.key + " " + $issue.fields.summary
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a new hire request.  

Automation was unable to resolve the Manager's name.   This ticket will require Human intervention.
 Thank you."
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
jiraworkflow $issue $jiracreds "11"
assignticket $issue $jiracreds "Random"
}else{
$mgrgrps = $mgruser.memberof | out-string

if ($mgrgrps -like "*CN=site*"){$jiraflag = "New Hire-Process"} Else {$jiraflag = "Close Ticket"}

if (($issue.key -notlike "") -or ($mgruser -notlike "") -or ($mgrstr -notlike "")){
#$comments =  get-jiraissuecomment $issue.key -credential $jiracreds
$comments = ticketcomments $issue $jiracreds
jiranewhire $issue $mgruser $assign $jiraflag $comments $closewindow $jiracreds 
}

  }
 # }
  }
 #Employee Deactivation Processing**************************************************************************
  if (($_.fields.Summary -like "*Employee Deactivation*") -and ($_.fields.status.name -eq "To Do") -and (($_.fields.assignee.name -like "") -or($_.fields.assignee.name -like "*unassigned*") -or ($_.fields.assignee.name -like "*sitesrvc*"))){ clear-content description.txt;$ticket = $_.fields.description.tostring() ; add-content description.txt $ticket ; $ticketsubstr = get-content description.txt | select-string "Login ID" ; 
#$ticketsubstr | foreach{
$mgrstr = $ticketsubstr.tostring().trim("Login ID").trim()

#Write-host -foregroundcolor "yellow" $mgrstr
$mgrstrsite = $mgrstr + ".site"
$mgrsearch = $mgrstr + "*"
$loginid = get-aduser -filter{(samaccountname -eq $mgrsearch) -or (samaccountname -eq $mgrstrsite)} -properties memberof,mail -server atl.careerbuilder.com -Credential $cbatlCreds
$login | foreach{
$logincount = $logincount +1
}

#Deactivation - Unable to resolve the username************************************************************

if (($logincount -gt 1)){
#Prevent multiple comments from sitesrvc*********************
$commentflag = 0
$comments = ticketcomments $issue $jiracreds
if ($comments -like "*"){
$comments | foreach{
if ($_.author.displayname -like "*sitesrvc*"){$commentflag =1}
}
if ($commentflag -eq 0){
$subject = $issue.key + " " + $issue.fields.summary
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a Deactivation request.  

Automation was unable to resolve the Login ID.   This ticket will require Human intervention.
 Thank you."
assignticket $issue $jiracreds "Random"
jiraworkflow $issue $jiracreds "11"
Send-MailMessage  -to siteopssupport@careerbuilder.com -cc siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
}}
}
#No Action Needed Close Ticket**************************************************
#$comments =  get-jiraissuecomment $issue.key -credential $jiracreds

if ((!$loginid) -and ($issue.fields.assignee.name -notlike "*sitesrvc*")){

$subject = $issue.key + " " + $issue.fields.summary + " - Closing No Account Needed"
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a Deactivation request.  

This Ticket has been closed by automation.  No Action is needed."

Send-MailMessage -to siteopssupport@careerbuilder.com -cc siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
assignticket $issue $jiracreds "sitesrvc"
jiraworkflow $issue $jiracreds "21"
}
if ((!$loginid) -and ($issue.fields.assignee.name -like "*sitesrvc*") -and ($issue.fields.status.name -like "*To Do*")){

jiraworkflow $issue $jiracreds "21"
}



#Disable Account********************************************************************

if($logincount -eq 1){
disable-adaccount $loginid
move-adobject $loginid -targetpath "OU=Inactive Accounts,DC=atl,DC=careerbuilder,DC=com" -confirm:$false
assignticket $issue $jiracreds "sitesrvc"
$subject = $issue.key + " " + $issue.fields.summary
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a Deactivation request.  

Automation has completed the request. "+$loginid.samaccount+" has been disabled and moved to the inactive users OU.
 Thank you."
Send-MailMessage -to siteopssupport@careerbuilder.com -cc siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
jiraworkflow $issue $jiracreds "21"
  }
  #}
  }
}
#}
#Error reporting************************************************************************
if ($error.count -gt 0){
$body = $error | out-string
Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Jira New Hire - ERRORS" -body $body}
