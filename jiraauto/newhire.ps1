function GET-ISSUES #************************************************************************************************************
{param($Iheader)
Invoke-restmethod -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project='IRQ'+AND+status='To Do'+or+status='In Progress'" -Headers $iheaders -timeoutsec 60 | select -ExpandProperty issues
}

Function assignticket
 {param($jissue,$jassignee,$jheaders)
 if ($jassignee -eq "Random"){$jassignee =("jterry.site","gnegelow.site","idiallo.site","jastone.site","jomunoz.site","mawelch.site")|get-random}
$body = '{ "name": "'+$jassignee+'" }'
$juri = "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$jissue.key+"/assignee"
$webResponse = Invoke-restmethod -method put -Uri $juri -Headers $jheaders -contenttype "application/json" -body $body -timeoutsec 60
}
 
 Function jiraworkflow
 {param($jwissue,$jiraworkflownum,$jwheaders)
$body ='{"transition": {"id": "'+$jiraworkflownum+'"} }'
$juri ="http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$jwissue.key+"/transitions"
Invoke-restmethod -method post -Uri $juri -Headers $jwheaders -contenttype "application/json" -body $body -timeoutsec 60
}

 Function ticketcomments
 {param($issue,$theaders)
$juri ="http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$issue.key+"/comment?expand"
$comments = Invoke-restmethod  -Uri $juri -Headers $theaders -contenttype "application/json" -timeoutsec 60
$comments.comments
 }
  Function CloseTicket
  {Param($ctissue,$ctheaders,$closereason)
$subject = $ctissue.key + " " + $ctissue.fields.summary + " - Closing"
$newbody = "This is an automated email triggered by ticket "+ $ctissue.key +" 

This Ticket has been closed by automation. "+$closereason
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody
assignticket $ctissue "sitesrvc" $ctheaders
jiraworkflow $ctissue "21" $ctheaders 
 }
  
  
$ErrorActionPreference = "silentlycontinue"
$error.clear()
import-module activedirectory
 #Ticket Close window without Manager Comment response*******************************
$closewindow = 7
#Authentications Setup*******************************************************
$cbatlUser = "sitesrvc"
$cbatlFile = "C:\cbatlpci\acklog2.txt"
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
#MAIN SCRIPT BODY***********************************************************************************
$issues = get-issues $headers
if (!$issues){exit}
$issues | foreach{
$issue = $_
#Already Processed New Hire**************************************************************************************************
if (($_.fields.Summary -like "*new hire*") -and ($_.fields.status.name -like "*In Progress*") -and ($_.fields.assignee.name -like "*sitesrvc*")){
[datetime]$issuecreatedate = $issue.fields.created
$timelapsed = (get-date) -$issuecreatedate
$timelapsed = $timelapsed.days
$issuecomments = ticketcomments $issue $headers
$issuecomments | foreach{
  
 if ($_.author.displayname -like $mgruser.displayname){ 
assignticket $issue $creds "Random"
 }Else{
 If ($timelapsed -ge $closewindow){
 
Closeticket $issue $headers "No Response From Manager."
 }}
 }
}#Already Processed New Hire End

#UnProcessed New Hire Tickets*****************************************************************************************************
if (($_.fields.Summary -like "*new hire*") -and ($_.fields.status.name -like "*To Do*") -and (($_.fields.assignee.name -like "") -or($_.fields.assignee.name -like "*unassigned*") -or ($_.fields.assignee.name -like "*sitesrvc*"))){

jiraworkflow $issue "11" $headers
#Extract Manager Name
Clear-content convert.txt
add-content Convert.txt ($_.fields.description | out-string)
$manager = get-content convert.txt | select-string "Manager"
$manager = $manager.tostring()
$manager=$manager.remove(0,8)

#Search For Manager ID in cb.careerbuilder.com
$mgruser = get-aduser -filter{displayname -eq $manager} -properties displayname,memberof,mail -server cb.careerbuilder.com -credential $cbcreds 
If (!$mgruser){ 
$mgrstrsearch = "*"+$manager+ "*"
$mgruser = get-aduser -filter{displayname -like $mgrstrsearch} -properties displayname,memberof,mail -server cb.careerbuilder.com -credential $cbcreds}

#Process Manager User ID
if (!$mgruser){
$subject = $issue.key + " " + $issue.fields.summary
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a new hire request.  

Automation was unable to resolve the Manager's name.   This ticket will require Human intervention.
 Thank you."
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
assignticket $issue "Random" $headers
}else{
#Detect if user needs CBATL account and send email to manager
$mgrgrps = $mgruser.memberof | out-string

if ($mgrgrps -like "*CN=site*"){
$subject = $issue.key + " " + $issue.fields.summary
$newbody = "This is an automated email triggered by ticket "+ $issue.key +" which is a new hire request.  

Please let us know if the new hire will need a CBATL site account and if so, which existing user we can copy for permissions? 
Also include any Unix\Linux Attributes that maybe needed.

Simply reply to this email with the required information and it will be entered into the Siteops Ticket Queue. 

DO NOT REPLY IF THE ACCOUNT IS NOT NEEDED.  The system will automatically close the ticket after 5 business days. 

 Thank you."
Send-MailMessage -to $mgruser.mail -from siteopssupport@careerbuilder.com -cc siteopssupport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject $subject -body $newbody 
assignticket $issue "sitesrvc" $headers

} Else {
Closeticket $issue $headers "No Action is needed."
}
} #Manager Section End
} #Unprocessed New Hire Section End
# <# #Employee Deactivations**************************************************************************************************************
 # if (($_.fields.Summary -like "*Employee Deactivation*") -and ($_.fields.status.name -eq "To Do") -and (($_.fields.assignee.name -like "") -or($_.fields.assignee.name -like "*unassigned*") -or ($_.fields.assignee.name -like "*sitesrvc*"))){

##Extract Login ID
# Clear-content convert.txt
# add-content Convert.txt ($_.fields.description | out-string)
# $LoginID = get-content convert.txt | select-string "Login ID"
# $LoginID = $Loginid.tostring()
# $LoginID=$LoginID.remove(0,9)
##Search For User ID in cbatl.careerbuilder.com
# $loginsam= $loginid +".site"
# $deactuser = get-aduser -filter{samaccountname -eq $loginsam} -properties displayname,memberof,mail -server atl.careerbuilder.com -credential $cbatlcreds 
# If (!$deactuser){ 
# $loginidsearch = "*"+$Loginsam+ ".site*"
# $deactuser = get-aduser -filter{samaccountname -like $loginidsearch} -properties displayname,memberof,mail -server atl.careerbuilder.com -credential $cbatlcreds
# }
##Take Action
# If (!$deactuser){ 
# Closeticket $issue $headers "No CBATL User found."
# } else{
# disable-adaccount $deactuser
# move-adobject $deactuser -targetpath "OU=Inactive Accounts,DC=atl,DC=careerbuilder,DC=com" -confirm:$false
# Closeticket $issue $headers "CBATL User Disabled and Moved."
 # }
# }#End Employee Deactivations
 } 
#Error reporting************************************************************************
if ($error.count -gt 0){
$body = $error | out-string
Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Jira New Hire - ERRORS" -body $body}











