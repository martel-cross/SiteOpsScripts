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