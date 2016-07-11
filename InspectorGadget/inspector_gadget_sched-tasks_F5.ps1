######################################################################################
#		Welcome to my Inspector Gadget script!
#		This script queries the uncommented OU's for servers and then writes 
#		each of those to a file ($ServerListFile). The main function of the 
#		script takes that list line by line and	checks a variety of things 
#		(MTU, install date, file/folder existince, etc..) and the writes it 
#		all to an html file ($InspectorGadgetFile).
#			
#		If only certain servers need to be checked, then use the 
#		following paramter from the command line: -list "custom"
#		e.g.: D:\Share\scripts\IG\inspector_gadget_sched-tasks.ps1 -list "custom"
#
#		Created by Kirk Jantzer
######################################################################################
param($list,$email = "me")
$serverlist = @()
$PingableServerList = @()
$IGDirectory = "D:\Share\scripts\IG\"
$ServerListFile = $IGDirectory + "serverlist.txt"
$ServerListFile_Custom = $IGDirectory + "serverlist_testcount.txt"
$script:servers_offline = ""

if ($list -ne "custom")
{
	[array]$ouArray = $null
	$FileExists = Test-Path $ServerListFile
	if ($FileExists -eq $True) {Clear-Content $ServerListFile}

	##### Utility OUs
	#$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=Utility,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	##### Web/MT OUs
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		
	$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DEVTEST,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	##### DB OUs
	#$ouArray += $([ADSI]"LDAP://OU=DEV,OU=Win2008R2,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=DR,OU=Win2008R2,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=EU,OU=Win2008R2,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=HK,OU=Win2008R2,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=QTM,OU=Win2008R2,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=WebTier,OU=Win2008R2,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=QTM,OU=Win2K3-2K8,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=WebTier,OU=Win2K3-2K8,OU=DB Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		
	foreach ($oupath in $ouArray)
	{
		$ou = [ADSI]"$oupath"
		foreach ($child in $ou.psbase.Children) 
		{ 
		 	if ($child.ObjectCategory -like '*computer*') { $serverlist += $child.Name }
		}
	}
	foreach ($strComputer in $serverlist) 
	{
		$serverstatus = ('select statuscode from win32_pingstatus where address="' + $strComputer + '"')
		$result = gwmi –query "$serverstatus"
		if ($result.StatusCode -ne 0) {$script:servers_offline+="<font color='red'>$strComputer</font>, "}
		else {$PingableServerList += $strComputer}
	}
	$serverlist = $PingableServerList
}
elseif ($list -eq "custom")
{ 
	$serverlist = Get-Content $ServerListFile_Custom
}

$date = (get-date).ToString('MM/dd/yyyy')
$datetime = (get-date).ToString('yyyyMMdd.HHmm')
$script:things_wrong = 0
$script:server_count = 0
$script:totalspace = 0
$script:totalsockets = 0
$script:totalcores = 0
$script:tasks_wrong,$script:F5fwd_wrong = ""
$script:tasks_wrong_count,$script:F5fwd_wrong_count = 0
$InspectorGadgetFileName = "InspectorGadget_Windows_$datetime.htm"
$tempfile = [system.io.path]::GetTempFileName()
$InspectorGadgetFile = $tempfile
$InspectorGadgetRealFile = $IGDirectory + $InspectorGadgetFileName
New-Item -ItemType file $InspectorGadgetFile -Force

function Get-Reg 
{
	# Function Connects to a remote computer Registry using the Parameters it recievs
	# command to run to query function registry
	# $tz = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Value "TimeZoneKeyName " -RemoteComputer $_
	param($Hive,$Key,$Value,$RemoteComputer)
    # Connect to Remote Computer Registry
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $RemoteComputer)
    # Open Remote Sub Key
    $regKey= $reg.OpenSubKey($Key)
    if($regKey.ValueCount -gt 0) # check if there are Values 
    {$regKey.GetValue($Value)} # Return Value
}

 
$writeHtmlHeader = "<html>
	<head>
	<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
	<title>SiteServers Inspector Gadget Report - $date</title>
	<STYLE TYPE='text/css'>
	<!--
	td {font-family: Tahoma; font-size: 11px; border-top: 1px solid #999999; border-right: 1px solid #999999; border-bottom: 1px solid #999999; border-left: 1px solid #999999;padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px;}
	body {margin-left: 5px; margin-top: 5px; margin-right: 0px; margin-bottom: 10px;}
	table {border: thin solid #000000;}
	-->
	</style>
	</head>
	<body>
	<table width='100%'>
	<tr bgcolor='#CCCCCC'>
	<td colspan='6' height='25' align='center'>
	<font face='tahoma' color='#003399' size='4'><strong><a name='top'></a>SiteServers Inspector Gadget Report - $date</strong></font>
	</td>
	</tr>
	</table>"

Function writeTaskTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td colspan='6' align='center'><strong>Scheduled Tasks</strong></td>
	</tr>"
}

Function writeMiscTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td align='center'><strong>F5fwd</strong></td>
	</tr>"
}

Function writeHtmlFooter
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "</body></html>"
}

Function writeTaskInfo
{
	param($InspectorGadgetFile,$schedtasks)
	$its_wrong = ""
	Add-Content $InspectorGadgetFile "<tr>"
	if (!$schedtasks) {$its_wrong = "1"}
	if (($schedtasks -notmatch "Cycle") -or ($schedtasks -notmatch "Grimreaper") -or ($schedtasks -notmatch "IIS_Backup") -or ($schedtasks -eq "") -or ($schedtasks -notmatch "LastTaskResult=0")) {$its_wrong = "1"}
	if (($schedtasks -match "LastTaskResult=1") -or ($schedtasks -match "LastTaskResult=2") -or ($schedtasks -match "LastTaskResult=267009") -or ($schedtasks -match "LastTaskResult=-2147216609")) {$its_wrong = "1"}
	if (($server -match "BAT") -and ($schedtasks -match "Name=Cycle; Enabled=True;")) {$its_wrong = "1"}
	if ($its_wrong -eq "1") {Add-Content $InspectorGadgetFile "<td colspan='6' bgcolor='#FF0000' align=center>$schedtasks</td>";$script:things_wrong++;$script:tasks_wrong+="<a href='#$server'>$server</a>, ";$script:F5fwd_wrong_count++}
	else {Add-Content $InspectorGadgetFile "<td colspan='6'>$schedtasks</td>"}
	Add-Content $InspectorGadgetFile "</tr>"
}

Function writeMiscInfo
{
	param($InspectorGadgetFile,$F5fwd)
	Add-Content $InspectorGadgetFile "<tr>"
	if ((!$F5fwd) -or ($F5fwd -notmatch "F5ForwardedFor32")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$F5fwd</td>";$script:things_wrong++;$script:F5fwd_wrong+="<a href='#$server'>$server</a>, ";$script:F5fwd_wrong_count++} 
	else {Add-Content $InspectorGadgetFile "<td>$F5fwd</td>"}
	Add-Content $InspectorGadgetFile "</tr>"
}



############################################################
# Sends the emails
Function sendEmail
{ 
	param($from,$to,$subject,$InspectorGadgetFileName)
	$body = "This report: <a href='http://orca.atl.careerbuilder.com/monitoring/IG/$InspectorGadgetFileName'>http://orca.atl.careerbuilder.com/monitoring/IG/$InspectorGadgetFileName</a>"
	$body += "<br /><br />"
	$body += "Previous reports: <a href='http://orca.atl.careerbuilder.com/monitoring/IG/'>http://orca.atl.careerbuilder.com/monitoring/IG/</a>"
	$smtp = New-Object System.Net.Mail.SmtpClient "relay.careerbuilder.com"
	$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
	$msg.isBodyhtml = $true
	$smtp.send($msg)
}

############################################################
# Gathers the data for the body of the table for each server
foreach ($server in $serverlist)
{
	if ($server -notmatch  "QTWWEBVM1|QTWLS|BEARLS|DRAGONLS|AMSTELLS|QTMSTATSLS")
	{
		$script:server_count++
		
		Add-Content $InspectorGadgetFile "<table width='100%'><tbody>"
		Add-Content $InspectorGadgetFile "<tr bgcolor='#CCCCCC'>"
		Add-Content $InspectorGadgetFile "<td width='100%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong><a name='$server'>$server</a></strong></font><font face='tahoma' color='#003399' size='1'>&nbsp;&nbsp;&nbsp;&nbsp;<a href='#top'>[Top of page]</a></font></td>"
		Add-Content $InspectorGadgetFile "</tr>"
	
		############
		# Scheduled tasks
		writeTaskTableHeader $InspectorGadgetFile
		$schedtasks = ""
		$schedule = new-object -com("Schedule.Service")
		$schedule.connect($server)
		$tasks = $schedule.getfolder("\").gettasks(0)
		$tasks = $tasks | select Name, Enabled, LastRunTime, NextRunTime, LastTaskResult
		foreach ($task in $tasks) {$schedtasks += "$task<br/>"}
		writeTaskInfo $InspectorGadgetFile $schedtasks
		
		###########
		# Misc info
		writeMiscTableHeader $InspectorGadgetFile
		$F5fwd = ""
		$F5fwd = (Select-String \\$server\C$\Windows\System32\inetsrv\config\applicationHost.config -pattern "F5XFFHttpModule.dll" | Select -ExpandProperty Line) -replace '<','' -replace '>','' -replace '/','' -replace '            ',''
		writeMiscInfo $InspectorGadgetFile $F5fwd
		

		Write-Host "$server done being checked"
		
		Add-Content $InspectorGadgetFile "<tr><td colSpan=6><br/><br/></td></tr>"
		Add-Content $InspectorGadgetFile "</table>"
	}

}
writeHtmlFooter $InspectorGadgetFile

function Insert-Content ($InspectorGadgetFile) 
{
	BEGIN {$content = Get-Content $InspectorGadgetFile}
	PROCESS {$_ | Set-Content $InspectorGadgetFile}
	END {$content | Add-Content $InspectorGadgetFile}
}

$prereport = "<div align='center'><img src='inspector_gadget.jpg' /></div><br/>Welcome to the Inspector Gadget report for $date. There were $server_count servers scanned, and Inspector Gadget found $things_wrong things wrong.<br /><br />"
if (($mtu_wrong) -or ($os_wrong) -or ($activation_wrong) -or ($proxy_wrong) -or ($diskname_wrong) -or ($diskcrit_wrong) -or ($ip_wrong) -or ($dns_wrong) -or `
($mtu_wrong) -or ($netbios_wrong) -or ($ipv6_wrong) -or ($dynports_wrong) -or ($httperr_wrong) -or ($rmtmgmt_wrong) -or  `
($uac_wrong) -or ($xpby_wrong) -or ($isapi_wrong) -or ($installdate_wrong) -or ($lastboot_wrong) -or  `
($timezone_wrong) -or ($dirs_wrong) -or ($tasks_wrong) -or ($servers_offline))
{
	$prereport += "Here is a brief list of things that need to be addressed on which servers. If any servers are listed here, please click any of the server names to navigate to that servers information table.<br /><br />"
	if($tasks_wrong){$prereport += "<b>$tasks_wrong_count Servers missing one or more of the important scheduled tasks:</b><br />$tasks_wrong <br /><br />"}
	if($F5fwd_wrong){$prereport += "<b>$F5fwd_wrong_count Servers with incorrect F5fwd module:</b><br />$F5fwd_wrong <br /><br />$F5fwd_wrong<br /><br />"}
	}

$header = $writeHtmlHeader + $prereport

$InspectorGadgetFile = $header | Insert-Content $InspectorGadgetFile

Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$InspectorGadgetFileName"
if ($email -eq "me")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <cody.rucks@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}
else {sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <cody.rucks@careerbuilder.com>" "Inspector Gadget: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}