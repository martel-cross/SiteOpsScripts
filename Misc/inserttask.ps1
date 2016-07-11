Function inserttask
{Param($servername,$xmlfile,$taskname)
schtasks /Create /S $servername /XML $xmlfile /RU "SYSTEM" /TN $taskname
}

$xmlfile1 = "grimreaper.xml"
$taskname1 = "GrimReaper"
#$xmlfile2 = "IIS_Backup.xml"
#$taskname2 = "IIS_Backup"
$xmlfile3 = "cycle.xml"
$taskname3 = "cycle"
#$credentials = get-credential
Import-csv needtask.csv | foreach{
$filechk =''
$server =$_.servername
$chkpath = "\\"+$server+"\c$\batch"
$filechk = Get-item $chkpath
if (!$filechk){ xcopy \\bearrdio4\C$\batch $chkpath  /E /I}
 inserttask $server $xmlfile1 $taskname1
 #inserttask $server $xmlfile2 $credentials $taskname2
 inserttask $server $xmlfile3 $taskname3
# if(($server -notlike "*dev*") -and ($server -notlike "*GHQ*")-and ($server -notlike "*batch*")){
# inserttask $server $xmlfile3 $credentials $taskname3
# schtasks /change /enable /S $server /RU $credentials.UserName /RP $credentials.GetNetworkCredential().Password /TN $taskname3}
}
