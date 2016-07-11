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
#		e.g.: D:\Share\scripts\IG\inspector_gadget.ps1 -list "custom"
#
#		Created by Kirk Jantzer
######################################################################################
param($list)
$serverlist = @()
$IGDirectory = "D:\Share\scripts\IG\"
$ServerListFile = $IGDirectory + "serverlist.txt"
$ServerListFile_Custom = $IGDirectory + "serverlist_Custom.txt"
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
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
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
		else {Add-Content $ServerListFile -value $strComputer}
	}
	$serverlist = $ServerListFile
}
elseif ($list -eq "custom")
{ 
	$serverlist = $ServerListFile_Custom
}

$date = (get-date).ToString('MM/dd/yyyy')
$datetime = (get-date).ToString('yyyyMMdd.HHmm')
$script:things_wrong = 0
$script:server_count = 0
$script:totalspace = 0
$script:totalsockets = 0
$script:totalcores = 0
$script:os_wrong,$script:activation_wrong,$script:proxy_wrong,$script:diskname_wrong,$script:diskcrit_wrong,$script:ip_wrong,$script:dns_wrong,$script:mtu_wrong,$script:netbios_wrong, `
$script:ipv6_wrong,$script:dynports_wrong,$script:httperr_wrong,$script:rmtmgmt_wrong,$script:uac_wrong,$script:xpby_wrong,$script:isapi_wrong,$script:installdate_wrong, `
$script:lastboot_wrong,$script:timezone_wrong,$script:dirs_wrong,$script:tasks_wrong = ""
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

#Function writeHtmlHeader
#{
	#param($InspectorGadgetFile)
	#Add-Content $InspectorGadgetFile 
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
#}
Function writeSystemTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td width='17%' align='center'><strong>Model</strong></td>
	<td width='17%' align='center'><strong>Asset Tag</strong></td>
	<td width='17%' align='center'><strong>OS Version</strong></td>
	<td width='17%' align='center'><strong>Activation</strong></td>
	<td width='17%' align='center'><strong>Total RAM</strong></td>
	<td width='17%' align='center'><strong>WinHTTP Proxy</strong></td>
	</tr>"
}
Function writeCPUTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td align='center' colspan='2'><strong>CPU Model</strong></td>
	<td align='center'><strong># of Sockets</strong></td>
	<td align='center'><strong>Cores / Socket</strong></td>
	<td align='center'><strong>CPU Architecture</strong></td>
	<td align='center'></td>
	</tr>"
}
Function writeDiskTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td align='center'><strong>Drive</strong></td>
	<td align='center'><strong>Drive Label</strong></td>
	<td align='center'><strong>Total Capacity (GB)</strong></td>
	<td align='center'><strong>Free Space (GB)</strong></td>
	<td align='center'><strong>Free Space (%)</strong></td>
	<td align='center'></td>
	</tr>"
}
Function writeNetworkTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td align='center'><strong>IP Addresses</strong></td>
	<td align='center'><strong>DNS Servers</strong></td>
	<td align='center'><strong>MTU</strong></td>
	<td align='center'><strong>NetBIOS</strong></td>
	<td align='center'><strong>IPv6</strong></td>
	<td align='center'><strong>Dynamic Ports</strong></td>
	</tr>"
}
Function writeMiscTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td align='center'><strong>Local Admins</strong></td>
	<td align='center'><strong>HTTPERR Directory</strong></td>
	<td align='center'><strong>Remote Management</strong></td>
	<td align='center'><strong>User Account Control</strong></td>
	<td align='center'><strong>XPBY</strong></td>
	<td align='center'><strong>ISAPI Filters</strong></td>
	</tr>"
}
Function writeTimeDirTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td align='center'><strong>Local Date/Time</strong></td>
	<td align='center'><strong>Install Date</strong></td>
	<td align='center'><strong>Last BootUp</strong></td>
	<td align='center'><strong>Time Zone</strong></td>
	<td colspan='2' align='center'><strong>Directories</strong></td>
	</tr>"
}
Function writeTaskTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
	<td colspan='6' align='center'><strong>Scheduled Tasks</strong></td>
	</tr>"
}
Function writeHtmlFooter
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "</body></html>"
}

Function writeSystemInfo
{
	param($InspectorGadgetFile,$model,$assetTag,$OS,$activation,$TotalRAM,$proxycfg)	
	Add-Content $InspectorGadgetFile "<tr>"
	if (!$model) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$model</td>";$script:things_wrong++} 
	else {Add-Content $InspectorGadgetFile "<td>$model</td>"}
	if (!$assetTag) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$assetTag</td>";$script:things_wrong++} 
	else {Add-Content $InspectorGadgetFile "<td>$assetTag</td>"}
	if ((!$OS) -or ($OS -like "*2003*")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$OS</td>";$script:things_wrong++;$script:os_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$OS</td>"}
	if (!$activation) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$activation</td>";$script:things_wrong++}
	elseif (($activation -notlike "Licence status: Licensed") -and ($activation -notlike "Not Applicable")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$activation</td>";$script:things_wrong++;$script:activation_wrong+="<a href='#$server'>$server</a>, "}
	else {Add-Content $InspectorGadgetFile "<td>$activation</td>"}
	if (!$TotalRAM) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$TotalRAM</td>";$script:things_wrong++} 
	else {Add-Content $InspectorGadgetFile "<td>$TotalRAM</td>"}
	if ((!$proxycfg) -or ($proxycfg -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$proxycfg</td>";$script:things_wrong++;$script:proxy_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$proxycfg</td>"}
	Add-Content $InspectorGadgetFile "</tr>"
}
Function writeCPUInfo
{
	param($InspectorGadgetFile,$cpu,$sockets,$cores,$arch)
	Add-Content $InspectorGadgetFile "<tr>"
	Add-Content $InspectorGadgetFile "<td colspan='2'>$cpu</td>"
	Add-Content $InspectorGadgetFile "<td>$sockets</td>";$script:totalsockets=$script:totalsockets+$sockets
	Add-Content $InspectorGadgetFile "<td>$cores</td>";$script:totalcores=$script:totalcores+($cores * $sockets)
	Add-Content $InspectorGadgetFile "<td>$arch</td>"
	Add-Content $InspectorGadgetFile "<td></td>"
	Add-Content $InspectorGadgetFile "</tr>"
}
Function writeDiskInfo
{
	param($InspectorGadgetFile,$devId,$volName,$frSpace,$totSpace)
	$warning = 20
	$critical = 10
	$totSpace=[Math]::Round(($totSpace/1073741824),2)
	$frSpace=[Math]::Round(($frSpace/1073741824),2)
	$freePercent = ($frspace/$totSpace)*100
	$freePercent = [Math]::Round($freePercent,0)
	Add-Content $InspectorGadgetFile "<tr>"
	Add-Content $InspectorGadgetFile "<td>$devid</td>"
	if (($devId -match "C") -and ($volName -notmatch "$server")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$volName</td>";$script:things_wrong++;$script:diskname_wrong+="<a href='#$server'>$server</a>, "}
	else {Add-Content $InspectorGadgetFile "<td>$volName</td>"}
	Add-Content $InspectorGadgetFile "<td>$totSpace</td>";$script:totalspace=$script:totalspace+$totSpace
	Add-Content $InspectorGadgetFile "<td>$frSpace</td>"
	if ($freePercent -gt $warning) {Add-Content $InspectorGadgetFile "<td>$freePercent</td>"}
	elseif ($freePercent -le $critical) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$freePercent</td>";$script:things_wrong++;$script:diskcrit_wrong+="<a href='#$server'>$server</a>, "}
	else {Add-Content $InspectorGadgetFile "<td bgcolor='#FBB917' align=center>$freePercent</td>";$script:things_wrong++}
	Add-Content $InspectorGadgetFile "<td></td>"
	Add-Content $InspectorGadgetFile "</tr>"
}
Function writeNetworkInfo
{
	param($InspectorGadgetFile,$IP,$DNS,$MTU,$NetBIOS,$ipv6)	
	Add-Content $InspectorGadgetFile "<tr>"
	if (!$IP) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$IP</td>";$script:things_wrong++;$script:ip_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$IP</td>"}
	if ((!$DNS) -or ($DNS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$DNS</td>";;$script:things_wrong++;$script:dns_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$DNS</td>"}
	if ((!$MTU) -or ($MTU -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$MTU</td>";$script:things_wrong++;$script:mtu_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$MTU</td>"}
	if ((!$NetBIOS) -or ($NetBIOS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$NetBIOS</td>";$script:things_wrong++;$script:netbios_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$NetBIOS</td>"}
	if ((!$ipv6) -or ($ipv6 -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$ipv6</td>";$script:things_wrong++;$script:ipv6_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$ipv6</td>"}
	#if ((!$dynamic_ports) -or ($dynamic_ports -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$dynamic_ports</td>";$script:things_wrong++;$script:dynports_wrong+="<a href='#$server'>$server</a>, "} 
	#else {Add-Content $InspectorGadgetFile "<td>$dynamic_ports</td>"}
	Add-Content $InspectorGadgetFile "<td>$dynamic_ports</td>"
	Add-Content $InspectorGadgetFile "</tr>"
}
Function writeMiscInfo
{
	param($InspectorGadgetFile,$Members,$httperr,$remotemgmt,$UAC,$XPBY,$ISAPI)
	Add-Content $InspectorGadgetFile "<tr>"
	if (!$Members) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$Members</td>";$script:things_wrong++} 
	else {Add-Content $InspectorGadgetFile "<td>$Members</td>"}
	if ((!$httperr) -or ($httperr -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$httperr</td>";$script:things_wrong++;$script:httperr_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$httperr</td>"}
	if ((!$remotemgmt) -or ($remotemgmt -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$remotemgmt</td>";$script:things_wrong++;$script:rmtmgmt_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$remotemgmt</td>"}
	if ((!$UAC) -or ($UAC -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$UAC</td>";$script:things_wrong++;$script:uac_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$UAC</td>"}
	if ((!$XPBY) -or ($XPBY -notmatch "$server")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$XPBY</td>";$script:things_wrong++;$script:xpby_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$XPBY</td>"}
	#if (!$ISAPI) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$ISAPI</td>";$script:things_wrong++;$script:isapi_wrong+="<a href='#$server'>$server</a>, "} 
	#else {Add-Content $InspectorGadgetFile "<td>$ISAPI</td>"}
	Add-Content $InspectorGadgetFile "<td>$ISAPI</td>"
	Add-Content $InspectorGadgetFile "</tr>"
}
Function writeTimeDirInfo
{
	param($InspectorGadgetFile,$LocalDateTime,$InstallDate,$LastBootUpTime,$TimeZone)
	Add-Content $InspectorGadgetFile "<tr>"
	if (!$LocalDateTime) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$LocalDateTime</td>";$script:things_wrong++} 
	else {Add-Content $InspectorGadgetFile "<td>$LocalDateTime</td>"}
	if (!$InstallDate) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$InstallDate</td>";$script:things_wrong++;$script:install_wrong+="<a href='#$server'>$server</a>, "} 
	elseif ($InstallDate -lt (get-Date).addmonths(-36)) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$InstallDate</td>";$script:things_wrong++;$script:installdate_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$InstallDate</td>"}
	if (!$LastBootUpTime) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$LastBootUpTime</td>";$script:things_wrong++;$script:lastboot_wrong+="<a href='#$server'>$server</a>, "} 
	elseif ($LastBootUpTime -lt (get-Date).addmonths(-12)) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$LastBootUpTime</td>";$script:things_wrong++;$script:lastboot_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$LastBootUpTime</td>"}
	if ((!$TimeZone) -or ($TimeZone -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$TimeZone</td>";$script:things_wrong++;$script:timezone_wrong+="<a href='#$server'>$server</a>, "}	
	else {Add-Content $InspectorGadgetFile "<td>$TimeZone</td>"}
	if (($Batch -match "empty|exist") -or ($IIS -match "empty|exist")) {Add-Content $InspectorGadgetFile "<td colspan='2' bgcolor='#FF0000' align=center>$Batch<br/>$IIS</td>";$script:things_wrong++;$script:dirs_wrong+="<a href='#$server'>$server</a>, "}	
	else {Add-Content $InspectorGadgetFile "<td colspan='2'>$Batch<br/>$IIS</td>"}
	Add-Content $InspectorGadgetFile "</tr>"
}
Function writeTaskInfo
{
	param($InspectorGadgetFile,$schedtasks)
	Add-Content $InspectorGadgetFile "<tr>"
	if (!$schedtasks) {Add-Content $InspectorGadgetFile "<td colspan='6' bgcolor='#FF0000' align=center>$schedtasks</td>";$script:things_wrong++;$script:tasks_wrong+="<a href='#$server'>$server</a>, "} 
	elseif (($schedtasks -notmatch "Cycle") -or ($schedtasks -notmatch "Grimreaper") -or ($schedtasks -notmatch "IIS_Backup") -or ($schedtasks -eq "") -or ($schedtasks -notmatch "LastTaskResult=0")) {Add-Content $InspectorGadgetFile "<td colspan='6' bgcolor='#FF0000' align=center>$schedtasks</td>";$script:things_wrong++;$script:tasks_wrong+="<a href='#$server'>$server</a>, "} 
	elseif (($schedtasks -match "LastTaskResult=1") -or ($schedtasks -match "LastTaskResult=2") -or ($schedtasks -match "LastTaskResult=267009") -or ($schedtasks -match "LastTaskResult=-2147216609")) {Add-Content $InspectorGadgetFile "<td colspan='6' bgcolor='#FF0000' align=center>$schedtasks</td>";$script:things_wrong++;$script:tasks_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td colspan='6'>$schedtasks</td>"}
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
foreach ($server in Get-Content $serverlist)
{
	if ($server -notmatch  "QTWWEBVM1|QTWLS|BEARLS|DRAGONLS|AMSTELLS|QTMSTATSLS")
	{
		Invoke-Command -file "D:\Share\scripts\IG\inventory.ps1" -computer $server
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
	if($totalspace){$totalspace = "{0:N2}" -f $totalspace;$prereport += "<b>Total drive space of all servers:</b><br />$totalspace GB<br /><br />"}
	if($totalsockets){$prereport += "<b>Total sockets of all servers:</b><br />$totalsockets<br /><br />"}
	if($totalcores){$prereport += "<b>Total cores of all servers:</b><br />$totalcores<br /><br />"}
	$prereport += "Here is a brief list of things that need to be addressed on which servers. If any servers are listed here, please click any of the server names to navigate to that servers information table.<br /><br />"
	if($servers_offline){$prereport += "<b>The following servers were inaccesible during the scan:</b><br />$servers_offline <br /><br />"}
	if($os_wrong){$prereport += "<b>Servers with OS older than Windows 2008:</b><br />$os_wrong <br /><br />"}
	if($activation_wrong){$prereport += "<b>Servers not in an Activated state:</b><br />$activation_wrong <br /><br />"}
	if($proxy_wrong){$prereport += "<b>Servers with a proxy set or misconfigured:</b><br />$proxy_wrong <br /><br />"}
	if($diskname_wrong){$prereport += "<b>Servers with C Drive name not set to server name:</b><br />$diskname_wrong <br /><br />"}
	if($diskcrit_wrong){$prereport += "<b>Servers with critical disk space:</b><br />$diskcrit_wrong <br /><br />"}
	if($ip_wrong){$prereport += "<b>IPs:</b><br />$ip_wrong <br /><br />"}
	if($dns_wrong){$prereport += "<b>Servers with incorrect DNS settings:</b><br />$dns_wrong <br /><br />"}
	if($mtu_wrong){$prereport += "<b>Servers with incorrect MTU setting:</b><br />$mtu_wrong <br /><br />"}
	if($netbios_wrong){$prereport += "<b>Servers with incorrect NETBIOS setting:</b><br />$netbios_wrong <br /><br />"}
	if($ipv6_wrong){$prereport += "<b>Servers with IPv6 enabled:</b><br />$ipv6_wrong <br /><br />"}
	if($dynports_wrong){$prereport += "<b>Servers with incorrect Dynamic TCP Ports setting:</b><br />$dynports_wrong <br /><br />"}
	if($httperr_wrong){$prereport += "<b>Servers with incorrect HTTPERR Dir setting:</b><br />$httperr_wrong <br /><br />"}
	if($rmtmgmt_wrong){$prereport += "<b>Servers with incorrect Remote Management setting:</b><br />$rmtmgmt_wrong <br /><br />"}
	if($uac_wrong){$prereport += "<b>Servers with incorrect UAC setting:</b><br />$uac_wrong <br /><br />"}
	if($xpby_wrong){$prereport += "<b>Servers with incorrect XPBY setting:</b><br />$xpby_wrong <br /><br />"}
	if($isapi_wrong){$prereport += "<b>Servers with incorrect ISAPI filters:</b><br />$isapi_wrong <br /><br />"}
	if($installdate_wrong){$prereport += "<b>Servers with Install Date older than 3 years:</b><br />$installdate_wrong <br /><br />"}
	if($lastboot_wrong){$prereport += "<b>Servers with Last Reboot of more than 1 year:</b><br />$lastboot_wrong <br /><br />"}
	if($timezone_wrong){$prereport += "<b>Servers with incorrect Time Zone:</b><br />$timezone_wrong <br /><br />"}
	if($dirs_wrong){$prereport += "<b>Servers missing important directories:</b><br />$dirs_wrong <br /><br />"}
	if($tasks_wrong){$prereport += "<b>Servers missing one or more of the important scheduled tasks:</b><br />$tasks_wrong <br /><br />"}
}

$header = $writeHtmlHeader + $prereport

$InspectorGadgetFile = $header | Insert-Content $InspectorGadgetFile

Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$InspectorGadgetFileName"
#sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <siteservers@careerbuilder.com>" "Inspector Gadget: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName
sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <kirk.jantzer@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName
