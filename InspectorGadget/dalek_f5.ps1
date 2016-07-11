######################################################################################
#		Welcome to my script!
#		This script queries the uncommented OU's for servers and then writes 
#		each of those to a file ($ServerListFile). The main function of the 
#		script takes that list line by line and	checks for the F5module DLL 
#		and the writes it all to an html file ($DalekFile).
#
#		If only certain servers need to be checked, then use the 
#		following paramter from the command line: -list "custom"
#		e.g.: D:\Share\scripts\IG\inspector_gadget.ps1 -list "custom"
#
#		Created by Cody Rucks w/ "borrowed" code by Kirk Jantzer
#		Last Change: Created Script
######################################################################################
param($list,$email)
$serverlist = @()
$PingableServerList = @()
$IGDirectory = "D:\Share\scripts\IG\"
$ServerListFile = $IGDirectory + "serverlist.txt"
$ServerListFile_Custom = $IGDirectory + "serverlist_custom4.txt"
$script:servers_offline = ""


###EXCLUSIONS###
$f5_exclude = "REBELLS|REBELWEBTEST02|REBELWS1|QTWSPARE2|REBELBLAST1|BEARDRWEB1|BEARDRDOC1|BEARSRCHBAT1|BEARSRCHBAT2|LUIGIBOASYNC1|LUIGIBOBATCH1|LUIGIBOBLAST|LUIGIBOWS1|LUIGIMAILBOSM1|LUIGIMX1|LUIGIMXWS1|LUIGIDPIBATCH1| `
LUIGIDPIBLAST1|LUIGIDPIFEED1|LUIGIDPIMAIL1|LUIGIDPISVC1|LUIGIDPISVC2|LUIGIMAP1|LUIGIMAP2|LUIGIMAP3|LUIGIMAP4|LUIGIBLAST|LUIGISPARE1|DRAGONBLAST1|AMSTELBLAST1|CBASYNC204|CBASYNC221|CBBLAST100|CBLS|DWTEST1|ORKINWEB2|REBELDW1| `
REBELDW2|REBELDW3|BOBATCH100|BOBATCH101|BOBLAST100|MAILBOSM1|MAILBOSM2|REBELBOASYNC1|REBELBOASYNC2|REBELBOWS1|REBELBOWS2|REBELMX100|REBELMX101|REBELMX102|REBELMXWS100|REBELMXWS101|REBELNXS1|REBELNXS2|BEARDPIBATCH1|BEARDPIBATCH2| `
BEARDPISVC1|BEARDPISVC2|BEARDPIWEB1|BEARDPIWEB2|DPIBATCH1Q|DPIBATCH2Q|DPIBLAST1Q|DPIFEED1Q|DPIFEED2Q|DPIMAIL1Q|DPIMAIL2Q|DPISVC1Q|DPISVC2Q|DPISVC3Q|DPISVC4Q|REBELDPIBATCH1|REBELDPIBATCH2|REBELDPISVC1|REBELDPISVC2|REBELDPIWEB1| `
REBELDPIWEB2|QTMMAP1|QTMMAP10|QTMMAP2|QTMMAP3|QTMMAP4|QTMMAP5|QTMMAP6|QTMMAP7|QTMMAP8|QTMMAP9|DEVDFS1|DEVVMCTR|GHQBLAST|GHQBLAST01|GHQDEPLOYTEST1|GHQDEPLOYTEST2|GHQDEPLOYTEST3|GHQFLASH|GHQHADOOPUTIL|GHQJSTEST|GHQLS|GHQTEST0| `
GHQTEST1|GHQTEST10|GHQTEST11|GHQTEST12|GHQTEST13|GHQTEST14|GHQTEST15|GHQTEST16|GHQTEST17|GHQTEST18|GHQTEST19|GHQTEST2|GHQTEST20|GHQTEST21|GHQTEST3|GHQTEST4|GHQTEST5|GHQTEST6|GHQTEST7|GHQTEST8|GHQTEST9|PIREPORT1|SPARETESTER1"

$datetime = (get-date).ToString('yyyyMMdd.HHmm')
$DalekFileName = "InspectorGadget_Windows_$datetime.htm"
$tempfile = [system.io.path]::GetTempFileName()
$DalekFile = $tempfile
$DalekRealFile = $IGDirectory + $DalekFileName
New-Item -ItemType file $DalekFile -Force


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
$script:Models = @()
$script:F5Filex64,$script:F5Filex86 = ""
$script:F5Filex64_wrong,$script:F5Filex86_wrong = ""

#########################################################
# Write Html Header
$writeHtmlHeader = "<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
<title>SiteServers Dalek F5 Report - $date</title>
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
<font face='tahoma' color='#003399' size='4'><strong><a name='top'></a>SiteServers Dalek F5 Report - $date</strong></font>
</td>
</tr>
</table>"


##### Write Error Table Headers
Function writeF5TableHeader
{
	param($DalekFile)
	Add-Content $DalekFile "<tr bgcolor=#CCCCCC>
	<td width='17%' align='center'><strong>F5 32-Bit DLL</strong></td>
	<td width='17%' align='center'><strong>F5 64-Bit DLL</strong></td>
	</tr>"
}



Function writeHtmlFooter
{
	param($DalekFile)
	Add-Content $DalekFile "</body></html>"
}	


#### Write F5 Table Information
Function writeF5Info
{
	param($DalekFile,$F5Filex86,$F5Filex64)
	Add-Content $DalekFile "<tr>"
	if ($F5Filex86 -match "Missing") {Add-Content $DalekFile "<td bgcolor='#FF0000' align=center>$F5Filex86</td>";$script:things_wrong++;$script:F5Filex86_wrong+="<a href='#$server'>$server</a>, ";$script:F5Filex86_wrong_count++} 
	else {Add-Content $DalekFile "<td>$F5Filex86<br/></td>"}
	if ($F5Filex64 -match "Missing") {Add-Content $DalekFile "<td bgcolor='#FF0000' align=center>$F5Filex64</td>";$script:things_wrong++;$script:F5Filex64_wrong+="<a href='#$server'>$server</a>, ";$script:F5Filex64_wrong_count++} 
	else {Add-Content $DalekFile "<td>$F5Filex64<br/></td>"}
}	



############################################################
# Sends the emails
Function sendEmail
{ 
	param($from,$to,$subject,$DalekFileName)
	$body = "This report: <a href='http://orca.atl.careerbuilder.com/monitoring/IG/$DalekFileName'>http://orca.atl.careerbuilder.com/monitoring/IG/$DalekFileName</a>"
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
	if ($server -notmatch  "QTWLS|BEARLS|DRAGONLS|AMSTELLS|QTMSTATSLS")
	{
		$script:server_count++
		
		Add-Content $DalekFile "<table width='100%'><tbody>"
		Add-Content $DalekFile "<tr bgcolor='#CCCCCC'>"
		Add-Content $DalekFile "<td width='100%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong><a name='$server'>$server</a></strong></font><font face='tahoma' color='#003399' size='1'>&nbsp;&nbsp;&nbsp;&nbsp;<a href='#top'>[Top of page]</a></font></td>"
		Add-Content $DalekFile "</tr>"


	#########################
	# F5 Info
	$F5Filex64,$F5Filex86  = ""
	writeF5TableHeader $DalekFile
	$F5Filex86 = Test-Path "\\$server\c$\batch\bin\F5XFFHttpModule.dll"
		If ($f5filex86 -eq $true)
		{$F5Filex86 = "Okay"}
		else {$F5Filex86 = "Missing"}	
	$F5Filex64 = Test-Path "\\$server\c$\batch\bin\x64\F5XFFHttpModule.dll"
		If ($f5filex64 -eq $true)
		{$F5Filex64 = "Okay"}
		else {$F5Filex64 = "Missing"}
	writeF5Info $DalekFile $F5Filex64 $F5Filex86

 }
}


	
##### Write Footer
writeHtmlFooter $DalekFile

function Insert-Content ($DalekFile) 
{
	BEGIN {$content = Get-Content $DalekFile}
	PROCESS {$_ | Set-Content $DalekFile}
	END {$content | Add-Content $DalekFile}
}

$prereport = "<div align='center'><img src='dalek.jpg' /></div><br/>Welcome to the Dalek F5 report for $date. There were $server_count servers scanned, and the Dalek found $things_wrong things wrong. EXTERMINATE THE ERRORS AT ONCE!<br /><br />"
	
if (($F5Filex86_wrong) -or ($F5Filex64_wrong))
{
	
	$prereport += "<b>Here is a brief list of things that need to be addressed. If any servers are listed here, please click any of the server names to navigate to that servers information table.</b><br /><br />"
	if($F5Filex86_wrong){$prereport += "<b><font color='red'>$F5Filex86_wrong_count </font> Servers missing F5x86 DLL:</b><br />$F5Filex86_wrong <br /><br />"}
	if($F5Filex64_wrong){$prereport += "<b><font color='red'>$F5Filex64_wrong_count </font> Servers missing F5x64 DLL:</b><br />$F5Filex64_wrong <br /><br />"}
}

$header = $writeHtmlHeader + $prereport

$DalekFile = $header | Insert-Content $DalekFile


Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$DalekFileName"
if ($email -eq "me")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <cody.rucks@careerbuilder.com>" "Dalek F5 - Windows: $date, $server_count servers, $things_wrong things wrong" $DalekFileName}
else {sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <siteservers@careerbuilder.com>" "Dalek F5: $date, $server_count servers, $things_wrong things wrong" $DalekFileName}