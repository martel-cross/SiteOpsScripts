clear-content Compobj.csv
$fileheader = "Server Name,Dns Record,Pingable,Queried Name,Queried Model,Status,LastActive"
add-content compobj.csv $fileheader
$errorflag = 0
$body = '<table style="width:100%"style="text-align:left;vertical-align:top;padding:0" left;><caption>Issues On CBATL Objects</caption><tr><th>Name</th><th>IP Address</th><th>System Type</th></tr>'
#Pull Ad computer objects - windows only***************************************8
$computers = get-adcomputer -filter{operatingsystem -like "*windows*"} -properties pwdlastset |select-object dnshostname,samaccountname,@{n='Lastpwdset';e={[DateTime]::FromFileTime($($_.pwdlastset))}} | ?{$_.lastpwdset -lt ((get-date).adddays(-35))}
$computers | foreach{
$server = $_
$systeminfo = ""
$status = ""
$liveflag = 0
$objage = $_.lastpwdset
#pull DNS record***********************************************************
$iplookup = ((((nslookup $_.dnshostname).replace("Server:  qtmad1.atl.careerbuilder.com","")).replace("Address:  10.240.10.10","")) | select-string "address:")
$iplookup = ($iplookup | out-string).trim()
$iplookup = $iplookup.trim("Address: ")
#if DNS record - does it ping**************************************************
if($iplookup){
$islive = test-connection $iplookup -quiet -count 1 
#if ping, what is really at the ip address***************************************************
if ($islive -eq "True"){
$status = "IP Reused"
$systeminfo = get-wmiobject -class win32_computersystem -computer $iplookup
#How similar are the names********************************************************************
if ($systeminfo){
$sinamesize = [math]::Round((($systeminfo.name).length)*.75)
$SIName = (($systeminfo.name | out-string).trim()).substring(0,$sinamesize)
$SILongname = $systeminfo.name +"."+$systeminfo.domain
$shortHostname = (($_.dnshostname | out-string).trim()).substring(0,$sinamesize)
if ($silongname -eq $_.dnshostname){ $status = "Error - System is live";$liveflag =1} 
If (($siname -eq $shorthostname) -and ($liveflag -eq 0)){$status = "DNS Redirected-Reused"}
} 
}
}
#Set flags for actions*************************************************************************************
if (!$iplookup) {$iplookup = "No Record"; $islive = "No Ip on Record"; $status = "Recommend Delete Object"}
if (($islive -ne "True") -and ($islive -ne "No Ip on Record")){$status = "Recommend Delete Object & DNS Record"}
#Build file for Report************************************************************************
$addtofile = $_.dnshostname+","+ $Iplookup+","+ $islive+","+$systeminfo.name+","+$systeminfo.model+","+$status+","+$objage
#Write-host $addtofile
add-content compobj.csv $addtofile
#Build file for actions in 30 days***************************************************************************
if (($status -eq "Recommend Delete Object") -or ($status -eq "Recommend Delete Object & DNS Record") -or ($status -eq "DNS Redirected-Reused") -or ($status -eq "IP Reused")){
$actionlist = import-csv actionlist.csv

if ($actionlist.servername -notcontains $server.dnshostname){ 
$objagediff = (get-date) - $objage
$addtofile = $server.dnshostname+","+ $Iplookup+","+ $islive+","+$systeminfo.name+","+$systeminfo.model+","+$status+","+(get-date)+","+$objagediff+","+(get-date).adddays(30)
add-content actionlist.csv $addtofile
}}
if (($status -eq "Error - System is live")){
$errorflag = 1
#$addtobody = $server.dnshostname+"`t"+ $Iplookup+"`t"+$systeminfo.model
$addtobody = "<tr><td>"+($server.dnshostname).trim("atl.careerbuilder.com")+"</td><td>-"+$Iplookup+"</td><td>-"+$systeminfo.model+"</td></tr>"
$body = $body + $addtobody 
}
}
if ($errorflag -eq 1){
$body = "The following systems may have orphaned Computer Objects in CBATL.  If these systems are CBATL servers, Please Check these systems.  If they are not CBATL servers, the objects need to be deleted.


"+$body
$body =$body + "</table>"
Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD Server Object Issues" -body $body -bodyashtml
}
#Prep for actions*****************************************************

$body = '<table style="width:100%"style="text-align:left;vertical-align:top;padding:0" left;><caption>Action On CBATL Objects</caption><tr><th>Name</th><th>Age</th><th>IP Address</th><th>AD Object</th><th>DNS Record</th></tr>'

$actionlist = import-csv actionlist.csv


Clear-content actionlist.csv
add-content actionlist.csv (get-content fileheader.csv)
$actionlist | foreach{
$check = ($_.detectiondate -lt (get-date).adddays(-30))
$nosaveflag = 0
[int]$lastactive = $_.lastactive.substring(0,4)
if (($_.detectiondate -lt (get-date).adddays(-30)) -or ($lastactive -ge 90)){
$searchname = $_.servername
if (($_.status -eq "Recommend Delete Object") -or ($_.status -eq "Recommend Delete Object & DNS Record")){
if ($_.dnsrecord -eq "No Record"){$dnsrecordstat = "No Record"} else {$dnsrecordstat = "Record Deleted"}
#Write-host -foregroundcolor "cyan" "Delete It! And Its DNS Record Too!" ($_ )
#$servertodelete = get-adcomputer -filter{dnshostname -eq $_.servername}
#Remove-adcomputer $servertodelete -confirm:$false
#dnscmd atl.careerbuilder.com /recorddelete atl.careerbuilder.com $_.servername A /f
$addtobody = "<tr><td>"+($_.servername).trim("atl.careerbuilder.com")+"</td><td>-"+$_.lastactive+"</td><td>-"+$_.dnsrecord+"-</td><td>Deleted</td><td>-"+$dnsrecordstat+"</td></tr>"
$body = $body + $addtobody 
$nosaveflag = 1

}
if (($_.status -eq "DNS Redirected-Reused") -or ($_.status -eq "IP Reused")){
#Write-host -foregroundcolor "yellow" "Delete It! But Nothing Else!" ($_ )
#$servertodelete = get-adcomputer -filter{dnshostname -eq $_.servername}
#Remove-adcomputer $servertodelete -confirm:$false
$addtobody = "<tr><td>"+($_.servername).trim("atl.careerbuilder.com")+"-</td><td>"+$_.lastactive+"-</td><td>"+$_.dnsrecord+"-</td><td>Deleted</td><td>No Change</td></tr>"
$body = $body + $addtobody 
$nosaveflag = 1

}
}

if ($nosaveflag -eq 0){

$savecontent = $_.servername +","+$_.dnsrecord+","+$_.pingable+","+$_.queriedname +","+$_.queriedmodel+","+$_.status+","+$_.detectiondate+","+$_.lastactive+","+$_.actiondate

add-content actionlist.csv $savecontent}
}
$body =$body + "</table>"
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD Server Object Cleanup" -body $body -bodyashtml -attachment actionlist.csv