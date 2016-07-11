clear-content grimreaperreport.htm
$trheader = "<table style='width:100%'><tr><th align='Left'>System</th><th align='Left'>Size at Start</th><th align='Left'>Size at End</th></tr>"
add-content grimreaperreport.htm $trheader
$filedate = get-date -f MM.dd.yyyy.hh.mm
$filename = "reportarchive"+$filedate+".csv"
$trheadercsv= "state,server,size"
add-content $filename $trheadercsv
#Deletion Job Spinoff by File******************************************************
$DeleteTheFiles = {
Param($files,$archivedaysold,$recflag)

foreach ($file in $files)
{
    if(((get-date) - $file.CreationTime).Days -gt $archiveDaysOld)
    {
             $fullpath = $file.fullname  
			 			 
			 if ($recflag -eq "True"){
 Start-job {Remove-Item $fullpath -recurse -force} -argumentlist $fullpath
 #write-host $fullpath
}else{
 Start-job {Remove-Item $fullpath -force} -argumentlist $fullpath }
		
    }
	if ((get-job -state "running").count -ge 10){start-sleep 10}
	#while((((Get-Counter '\Memory\Available MBytes').countersamples.cookedvalue)/1000) -le .5){start-sleep 10}
	}
}

#filesources*************************************************8
$servers = "rebelstapi13","rebelstapi14","QTXBOBLAST01"
$farmservers = "qtmmgmt1","qtmmgmt2","qtmvcmdr1"
$num = 0
$filelocations = import-csv grimreaper.cfg
foreach($server in $servers){
$server
$filelocations | foreach{
$serverpath = "\\"+$server+"\"+($_.path).replace(":","$")
$deletiontime = $_.days
$recflag = $_.recursive
 if ($recflag -eq "True"){
 $files = get-childitem $serverpath -recurse
}else{ $files = get-childitem $serverpath}

foreach($filesize in $files){$startsize = $startsize + $filesize.length}
#Spin off Deletion Jobs*******************************************8
if ($files){
Start-job $Deletethefiles -argumentlist $files,$deletiontime,$recflag
#Invoke-command $Deletethefiles -argumentlist $files,$deletiontime,$recflag -computername $farmservers[$num] -asjob
if ($num -lt 2){$num = $num + 1} else {$num = 0}
}
#Main Throttle***********************************************************
while((((Get-Counter '\Memory\Available MBytes').countersamples.cookedvalue)/1000) -le 1.5){start-sleep 10}
}
while((((Get-Counter '\Memory\Available MBytes').countersamples.cookedvalue)/1000) -le 1.75){start-sleep 10}
#*********************************************************************
#File Folder Recursive Deletion**********************************************************
$serverpath = "\\"+$server+"\D$\matrixservices\*"
start-job {get-item $serverpath | ?{$_.Name -Match "v[0-9]+.[0-9]*"} | ?{ $_.PSIsContainer } | ?{ $_.LastWriteTime -lt (Get-Date).adddays(-14) }| remove-item -recurse -force}
while((((Get-Counter '\Memory\Available MBytes').countersamples.cookedvalue)/1000) -le 1.5){start-sleep 10}
$serverpath = "\\"+$server+"\D$\logs\2*"
start-job {get-item $serverpath | ?{ $_.PSIsContainer } | ?{ $_.LastWriteTime -lt (Get-Date).adddays(-7) } | remove-item -recurse -force}
#******************************************************************************************

$addtoreportcsv ="Start,"+$server+","+$startsize
add-content $filename $addtoreportcsv
}
#Waiting to finish so reporting can start******************************************
 while(get-job -state "running")
 {start-sleep 10}
#Reporting**************************************************************************
foreach($server in $servers){
$filelocations | foreach{
$serverpath = "\\"+$server+"\"+($_.path).replace(":","$")
$files = get-childitem $serverpath
foreach($filesize in $files){$endsize = $endsize + $filesize.length}
}

$addtoreportcsv ="end,"+$server+","+$endsize
add-content $filename $addtoreportcsv
}
$reportinfo = import-csv $filename
foreach($server in $servers){
$reportsubset = $reportinfo | ?{$_.server -eq $server}
$reportsubsetstart = $Reportsubset | ?{$_.state -eq "Start"}
$reportsubsetend = $Reportsubset | ?{$_.state -eq "end"}
$reportsubsetstart.size = $reportsubsetstart.size /1000000
$reportsubsetend.size = $reportsubsetend.size /1000000
$addtoreport = "<tr align='Left'><td>"+$reportsubsetstart.server+"</td><td>"+$reportsubsetstart.size+" MB</td><td>"+$reportsubsetend.size+" MB</td></tr>"
add-content grimreaperreport.htm $addtoreport
}
add-content grimreaperreport.htm "</table>"
$report = (get-content grimreaperreport.htm) | out-string
#Send-MailMessage -to platformsoftware@careerbuilder.com,SiteBackEndAlerts@careerbuilder.com,Platformintegrity2@careerbuilder.com -from taskmonitor@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject 'GrimReaper Report' -bodyashtml -body $report
Send-MailMessage -to sitebackendalerts@careerbuilder.com -from taskmonitor@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject 'GrimReaper Report' -bodyashtml -body $report











