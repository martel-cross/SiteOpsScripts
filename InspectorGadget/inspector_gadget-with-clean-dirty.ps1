######################################################################################
#		Welcome to my Inspector Gadget script!
#		This script queries the uncommented OU's for servers and then writes 
#		each of those to a file ($ServerListFile). The main function of the 
#		script takes that list line by line and	checks a variety of things 
#		(MTU, install date, file/folder existince, etc..) and the writes it 
#		all to an html file ($InspectorGadgetFile).
#					
#		To run this script, use the following:
#			- 'Clean' mode (outputs ALL checked settings for all servers):
#				D:\Share\scripts\IG\inspector_gadget.ps1 -mode "clean"
#			- 'Dirty' mode (outputs ONLY wrong settings for all servers):
#				D:\Share\scripts\IG\inspector_gadget.ps1 -mode "dirty"
#			
#		For both modes, if only certain servers need 
#		to be checked, then use the following after you 
#		specify the mode: -list "custom"
#		e.g.: D:\Share\scripts\IG\inspector_gadget.ps1 -mode "dirty"  -list "custom"
#
#
#
#		Created by Kirk Jantzer
######################################################################################
param($mode,$list)
if (!$mode)
{Write-Host 'Please specify the parameter: -mode "clean" or -mode "dirty"'}
else 
{
	$serverlist = @()
	$IGDirectory = "D:\Share\scripts\IG\"
	$ServerListFile = $IGDirectory + "serverlist.txt"

	if ($list -ne "custom")
	{
		[array]$ouArray = $null
		$FileExists = Test-Path $ServerListFile
		if ($FileExists -eq $True) {Clear-Content $ServerListFile}

		#$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=WEB,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		#$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		#$ouArray += $([ADSI]"LDAP://OU=Utility,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=WEB,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=MT,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=WEB,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=MT,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=WEB,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=MT,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=DPI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		#$ouArray += $([ADSI]"LDAP://OU=DEVTEST,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path

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
			Add-Content $ServerListFile -value $strComputer
		}
	}

	$serverlist = $ServerListFile

	$date = (get-date).ToString('MM/dd/yyyy')
	$datetime = (get-date).ToString('%Hmm.MMddyyyy')
	$script:things_wrong = 0
	$script:server_count = 0
	$InspectorGadgetFileName = "InspectorGadget_$mode_$datetime.htm"
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

	if ($mode -eq "clean")
	{
		Function writeHtmlHeader
		{
			param($InspectorGadgetFile)
			Add-Content $InspectorGadgetFile "<html>
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
			<font face='tahoma' color='#003399' size='4'><strong>SiteServers Inspector Gadget Report - $date</strong></font>
			</td>
			</tr>
			</table>"
		}
		Function writeSystemTableHeader
		{
			param($InspectorGadgetFile)
			Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
			<td width='17%' align='center'><strong>Model</strong></td>
			<td width='17%' align='center'><strong>Asset Tag</strong></td>
			<td width='17%' align='center'><strong>OS Version</strong></td>
			<td width='17%' align='center'><strong>Activation</strong></td>
			<td width='17%' align='center'><strong>Total RAM</strong></td>
			<td width='17%' align='center'></td>
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
	}

	if ($mode -eq "clean")
	{
		Function writeSystemInfo
		{
			param($InspectorGadgetFile,$model,$assetTag,$OS,$activation,$TotalRAM,$schedtasks)	
			Add-Content $InspectorGadgetFile "<tr>"
			if (!$model) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$model</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$model</td>"}
			if (!$assetTag) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$assetTag</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$assetTag</td>"}
			if ((!$OS) -or ($OS -like "*2003*")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$OS</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$OS</td>"}
			if (!$activation) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$activation</td>";$script:things_wrong++}
			elseif (($activation -notlike "Licence status: Licensed") -and ($activation -notlike "Not Applicable")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$activation</td>";$script:things_wrong++}
			else {Add-Content $InspectorGadgetFile "<td>$activation</td>"}
			if (!$TotalRAM) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$TotalRAM</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$TotalRAM</td>"}
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
			if (($devId -match "C") -and ($volName -notmatch "$server")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$volName</td>";$script:things_wrong++}
			else {Add-Content $InspectorGadgetFile "<td>$volName</td>"}
			Add-Content $InspectorGadgetFile "<td>$totSpace</td>"
			Add-Content $InspectorGadgetFile "<td>$frSpace</td>"
			if ($freePercent -gt $warning) {Add-Content $InspectorGadgetFile "<td>$freePercent</td>"}
			elseif ($freePercent -le $critical) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$freePercent</td>";$script:things_wrong++}
			else {Add-Content $InspectorGadgetFile "<td bgcolor='#FBB917' align=center>$freePercent</td>";$script:things_wrong++}
			Add-Content $InspectorGadgetFile "<td></td>"
			Add-Content $InspectorGadgetFile "</tr>"
		}
		Function writeNetworkInfo
		{
			param($InspectorGadgetFile,$IP,$DNS,$MTU,$NetBIOS,$ipv6)	
			Add-Content $InspectorGadgetFile "<tr>"
			if (!$IP) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$IP</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$IP</td>"}
			if ((!$DNS) -or ($DNS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$DNS</td>";;$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$DNS</td>"}
			if ((!$MTU) -or ($MTU -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$MTU</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$MTU</td>"}
			if ((!$NetBIOS) -or ($NetBIOS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$NetBIOS</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$NetBIOS</td>"}
			if ((!$ipv6) -or ($ipv6 -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$ipv6</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$ipv6</td>"}
			#if ((!$dynamic_ports) -or ($dynamic_ports -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$dynamic_ports</td>";$script:things_wrong++} 
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
			if ((!$httperr) -or ($httperr -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$httperr</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$httperr</td>"}
			if ((!$remotemgmt) -or ($remotemgmt -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$remotemgmt</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$remotemgmt</td>"}
			if ((!$UAC) -or ($UAC -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$UAC</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$UAC</td>"}
			if ((!$XPBY) -or ($XPBY -notmatch "$server")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$XPBY</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$XPBY</td>"}
			#if (!$ISAPI) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$ISAPI</td>";$script:things_wrong++} 
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
			if (!$InstallDate) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$InstallDate</td>";$script:things_wrong++} 
			elseif ($InstallDate -lt (get-Date).addmonths(-36)) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$InstallDate</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$InstallDate</td>"}
			if (!$LastBootUpTime) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$LastBootUpTime</td>";$script:things_wrong++} 
			elseif ($LastBootUpTime -lt (get-Date).addmonths(-12)) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$LastBootUpTime</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td>$LastBootUpTime</td>"}
			if ((!$TimeZone) -or ($TimeZone -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$TimeZone</td>";$script:things_wrong++}	
			else {Add-Content $InspectorGadgetFile "<td>$TimeZone</td>"}
			if (($Batch -match "empty|exist") -or ($IIS -match "empty|exist")) {Add-Content $InspectorGadgetFile "<td colspan='2' bgcolor='#FF0000' align=center>$Batch<br/>$IIS</td>";$script:things_wrong++}	
			else {Add-Content $InspectorGadgetFile "<td colspan='2'>$Batch<br/>$IIS</td>"}
			Add-Content $InspectorGadgetFile "</tr>"
		}
		Function writeTaskInfo
		{
			param($InspectorGadgetFile,$schedtasks)
			Add-Content $InspectorGadgetFile "<tr>"
			if (!$schedtasks) {Add-Content $InspectorGadgetFile "<td colspan='6' bgcolor='#FF0000' align=center>$schedtasks</td>";$script:things_wrong++} 
			elseif (($schedtasks -notmatch "Cycle") -or ($schedtasks -notmatch "Grimreaper") -or ($schedtasks -notmatch "IIS_Backup") -or ($schedtasks -eq "")) {Add-Content $InspectorGadgetFile "<td colspan='6' bgcolor='#FF0000' align=center>$schedtasks</td>";$script:things_wrong++} 
			else {Add-Content $InspectorGadgetFile "<td colspan='6'>$schedtasks</td>"}
			Add-Content $InspectorGadgetFile "</tr>"
		}
	}
	##########################################
	# Only returns things wrong on each server
	elseif ($mode -eq "dirty")
	{
		Add-Content $InspectorGadgetFile "<td>"
		Function writeSystemInfo
		{
			param($InspectorGadgetFile,$model,$assetTag,$OS,$activation,$TotalRAM,$schedtasks)	
			if (!$model) {Add-Content $InspectorGadgetFile "Model not set!<br/>";$script:things_wrong++} 
			if (!$assetTag) {Add-Content $InspectorGadgetFile "AssetTag not set!<br/>";$script:things_wrong++} 
			if ((!$OS) -or ($OS -like "*2003*")) {Add-Content $InspectorGadgetFile "OS not set or is older than Server 2008<br/>";$script:things_wrong++} 
			if (!$activation) {Add-Content $InspectorGadgetFile "Not activated!<br/>";$script:things_wrong++}
			elseif (($activation -notlike "Licence status: Licensed") -and ($activation -notlike "Not Applicable")) {Add-Content $InspectorGadgetFile "Not activated!";$script:things_wrong++}
			if (!$TotalRAM) {Add-Content $InspectorGadgetFile "No RAM listed<br/>";$script:things_wrong++} 
		}
		Function writeDiskInfo
		{
			param($InspectorGadgetFile,$devId,$volName,$frSpace,$totSpace)
			$critical = 10
			$totSpace=[Math]::Round(($totSpace/1073741824),2)
			$frSpace=[Math]::Round(($frSpace/1073741824),2)
			$freePercent = ($frspace/$totSpace)*100
			$freePercent = [Math]::Round($freePercent,0)
			if (($devId -match "C") -and ($volName -notmatch "$server")) {Add-Content $InspectorGadgetFile "C Drive label does not match server name<br/>";$script:things_wrong++}
			if ($freePercent -le $critical) {Add-Content $InspectorGadgetFile "Less than 10% fress space left on $devID<br/>";$script:things_wrong++}
		}
		Function writeNetworkInfo
		{
			param($InspectorGadgetFile,$IP,$DNS,$MTU,$NetBIOS,$ipv6)	
			if (!$IP) {Add-Content $InspectorGadgetFile "IP's are set wrong!<br/>";$script:things_wrong++} 
			if ((!$DNS) -or ($DNS -match "Wrong")) {Add-Content $InspectorGadgetFile "DNS Set wrong!<br/>";;$script:things_wrong++} 
			if ((!$MTU) -or ($MTU -match "Wrong")) {Add-Content $InspectorGadgetFile "MTU set wrong!<br/>";$script:things_wrong++} 
			if ((!$NetBIOS) -or ($NetBIOS -match "Wrong")) {Add-Content $InspectorGadgetFile "NetBIOS set wrong!<br/>";$script:things_wrong++} 
			if ((!$ipv6) -or ($ipv6 -match "Wrong")) {Add-Content $InspectorGadgetFile "IPv6 set wrong!<br/>";$script:things_wrong++} 
			#if ((!$dynamic_ports) -or ($dynamic_ports -match "Wrong")) {Add-Content $InspectorGadgetFile "Dynamic ports set wrong!<br/>";$script:things_wrong++} 
		}
		Function writeMiscInfo
		{
			param($InspectorGadgetFile,$Members,$httperr,$remotemgmt,$UAC,$XPBY,$ISAPI)
			if (!$Members) {Add-Content $InspectorGadgetFile "Admins group is not set!<br/>";$script:things_wrong++} 
			if ((!$httperr) -or ($httperr -match "Wrong")) {Add-Content $InspectorGadgetFile "HTTPERR directory set wrong!<br/>";$script:things_wrong++} 
			if ((!$remotemgmt) -or ($remotemgmt -match "Wrong")) {Add-Content $InspectorGadgetFile "Remote management is set wrong!<br/>";$script:things_wrong++} 
			if ((!$UAC) -or ($UAC -match "Wrong")) {Add-Content $InspectorGadgetFile "UAC setting is set wrong!<br/>";$script:things_wrong++} 
			if ((!$XPBY) -or ($XPBY -notmatch "$server")) {Add-Content $InspectorGadgetFile "XPBY setting is set wrong!<br/>";$script:things_wrong++} 
			#if (!$ISAPI) {Add-Content $InspectorGadgetFile "ISAPI filters set wrong!<br/>";$script:things_wrong++} 
		}
		Function writeTimeDirInfo
		{
			param($InspectorGadgetFile,$LocalDateTime,$InstallDate,$LastBootUpTime,$TimeZone)
			if (!$InstallDate) {Add-Content $InspectorGadgetFile "Install date not set!";$script:things_wrong++} 
			elseif ($InstallDate -lt (get-Date).addmonths(-36)) {Add-Content $InspectorGadgetFile "Install date is more than 3 years ago!<br/>";$script:things_wrong++} 
			if (!$LastBootUpTime) {Add-Content $InspectorGadgetFile "Last boot time not set!<br/>";$script:things_wrong++} 
			elseif ($LastBootUpTime -lt (get-Date).addmonths(-12)) {Add-Content $InspectorGadgetFile "Last reboot was more than 1 year ago!<br/>";$script:things_wrong++} 
			if ((!$TimeZone) -or ($TimeZone -match "Wrong")) {Add-Content $InspectorGadgetFile "Time zone not EST!<br/>";$script:things_wrong++}	
			if ($Batch -match "empty|exist") {Add-Content $InspectorGadgetFile "The Batch dir is empty!<br/>";$script:things_wrong++}	
			if ($IIS -match "empty|exist") {Add-Content $InspectorGadgetFile "The IISLogs dir is empty!<br/>";$script:things_wrong++}	
		}
		Function writeTaskInfo
		{
			param($InspectorGadgetFile,$schedtasks)
			if (!$schedtasks) {Add-Content $InspectorGadgetFile "No scheduled tasks!<br/>";$script:things_wrong++} 
			elseif (($schedtasks -notmatch "Cycle") -or ($schedtasks -notmatch "Grimreaper") -or ($schedtasks -notmatch "IIS_Backup") -or ($schedtasks -eq "")) {Add-Content $InspectorGadgetFile "Missing one of the three scheduled tasks!<br/>";$script:things_wrong++} 
		}
		Add-Content $InspectorGadgetFile "</td>"
	}



	Function sendEmail
	{ 
		param($from,$to,$subject,$InspectorGadgetFile)
		$body = "Latest report: http://orca.atl.careerbuilder.com/monitoring/IG/$InspectorGadgetFileName"
		$smtp = New-Object System.Net.Mail.SmtpClient "relay.careerbuilder.com"
		$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
		$msg.isBodyhtml = $true
		$smtp.send($msg)
	}

	writeHtmlHeader $InspectorGadgetFile

	############################################################
	# Gathers the data for the body of the table for each server
	foreach ($server in Get-Content $serverlist)
	{
		if ($server -notmatch  "QTWLS|QTWWEBVM1|BEARLS|DRAGONLS|AMSTELLS")
		{
			$script:server_count++
			if ($mode -eq "clean") {Add-Content $InspectorGadgetFile "<table width='100%'><tbody>"}
			elseif ($mode -eq "dirty") {Add-Content $InspectorGadgetFile "<table width='50%'><tbody>"}
			Add-Content $InspectorGadgetFile "<tr bgcolor='#CCCCCC'>"
			if ($mode -eq "clean") {Add-Content $InspectorGadgetFile "<td width='100%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong> $server </strong></font></td>"}
			elseif ($mode -eq "dirty") {Add-Content $InspectorGadgetFile "<td width='50%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong> $server </strong></font></td>"}
			Add-Content $InspectorGadgetFile "</tr>"
			
			if ($mode -eq "dirty")
			{Add-Content $InspectorGadgetFile "<tr><td>"}
			
			#############
			# system info
			$os,$activation,$TotalRAM = ""
			if ($mode -eq "clean") {writeSystemTableHeader $InspectorGadgetFile}
			$os_wmi = gwmi Win32_OperatingSystem -ComputerName $server | Select-Object -Property [a-z]*
			$os = $os_wmi.Caption
			$hw1 = gwmi Win32_ComputerSystem -ComputerName $server | Select-Object -Property [a-z]*
			$hw2 = gwmi Win32_BIOS -ComputerName $server | Select-Object -Property [a-z]*
			if ($os -notlike "*2003*")
			{
				$licenseStatus=@{0="Unlicensed"; 1="Licensed"; 2="OOBGrace"; 3="OOTGrace"; 4="NonGenuineGrace"; 5="Notification"; 6="ExtendedGrace"} 
				Function Get-Registration 
				{ 
					get-wmiObject -query  "SELECT * FROM SoftwareLicensingProduct WHERE PartialProductKey <> null 
									AND ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f' 
									AND LicenseIsAddon=False" -Computername $server | 
				       foreach {"Licence status: {1}" -f $_.name , $licenseStatus[[int]$_.LicenseStatus] } 
				}
				$activation = Get-Registration
			}
			else {$activation = "Not Applicable"}
			$TotalRAM = [math]::round( ( $hw1.TotalPhysicalMemory / 1024 / 1024 / 1024 ) )
			$TotalRAM = "" + $TotalRAM + " GB"
			writeSystemInfo $InspectorGadgetFile $hw1.model $hw2.SerialNumber $os $Activation $TotalRAM

			###########
			# disk info
			if ($mode -eq "clean") {writeDiskTableHeader $InspectorGadgetFile}
			$dp = Get-WmiObject win32_logicaldisk -ComputerName $server | Where-Object {$_.drivetype -eq 3}
			foreach ($item in $dp)
			{
				writeDiskInfo $InspectorGadgetFile $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size
			}
			
			##############
			# network info
			$IP,$DNS,$dnschk,$ipv6,$MTU,$NetBIOS,$dynamic_ports = ""
			if ($mode -eq "clean") {writeNetworkTableHeader $InspectorGadgetFile}
			#$nw = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*
			$ip_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property IPAddress
			foreach ($objItem in $ip_wmi)
			{
				if ([string]$objItem.IPAddress -eq "0.0.0.0") {$IP += ""}
				else {$IP += [string]$objItem.IPAddress + ", "}
			}
			$dns_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property DNSServerSearchOrder
			foreach ($objItem in $dns_wmi) {$dnschk += [string]$objItem.DNSServerSearchOrder}	
			#$dnschk = [string]$objItem.DNSServerSearchOrder
			$dnschk = $dnschk.Split(" ")
			if (!$dnschk[1])
			{$DNS = "Set Wrong: " + $dnschk[0]}
			else 
			{$DNS = $dnschk[0] + ", " + $dnschk[1]}
			$nb_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property TcpipNetbiosOptions
			foreach ($objItem in $nb_wmi)
			{
				if ($objItem.TcpipNetbiosOptions -eq "2") {$NetBIOS = "Set Correct: " + $objItem.TcpipNetbiosOptions}
				elseif ($os -like "*2003*") {$NetBIOS = "Not applicable"}
				else {$NetBIOS = "Set Wrong: " + $objItem.TcpipNetbiosOptions}
			}
			$ipv6 = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Value "DisabledComponents" -RemoteComputer $server
			if ($os -like "*2003*") {$ipv6 = "Not applicable"}
			elseif ($ipv6 -eq "-1") {$ipv6 = "Set Correct: " + $ipv6}
			else {$ipv6 = "Set Wrong: " + $ipv6}
			$dynamic_ports = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Value "MaxUserPort" -RemoteComputer $server
			if ($dynamic_ports -eq "51024") {$dynamic_ports = "Set Correct: " + $dynamic_ports}
			else {$dynamic_ports = "Set Wrong: " + $dynamic_ports}
			# MTU Reg fetcher
			$key = "SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces"
			$type = [Microsoft.Win32.RegistryHive]::LocalMachine
			$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $server)
			$regKey = $regKey.OpenSubKey($key)
			Foreach($sub in $regKey.GetSubKeyNames())
			{
				$NICPOOLS = "SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$sub"
				$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $server)
				$regKey = $regKey.OpenSubKey($NICPOOLS)
				Foreach($val in $regKey.GetValueNames()) 
				{
					if ($val -eq "MTU") 
					{
						$MTU = $regKey.GetValue("$val")
						if ($MTU -eq "1380") {$MTU = "Set Correct: " + $MTU}
						else {$MTU = "Set Wrong: " + $MTU}
					}
				}
			}
			writeNetworkInfo $InspectorGadgetFile $IP $DNS $MTU $NetBIOS $ipv6 $dynamic_ports
			
			###########
			# Misc info
			if ($mode -eq "clean") {writeMiscTableHeader $InspectorGadgetFile}
			$XPBY,$ISAPI,$UAC,$httperr,$Members,$remotemgmt = ""
			$computer = [ADSI]("WinNT://" + $server + ",computer") 
			$Group = $computer.psbase.children.find("Administrators") 
			$Members = $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
			#$Members = [string]$Members.Split(" ")
			function Members
			{
				foreach($User in $Members)
				{$User + ","}
			}
			$Members = Members
			$httperr = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\HTTP\Parameters" -Value "ErrorLoggingDir" -RemoteComputer $server
			if ($httperr -eq "D:\iislogs") {$httperr = "Set Correct: " + $httperr}
			else {$httperr = "Set Wrong: " + $httperr}
			$remotemgmt = Get-Reg -Hive LocalMachine -Key "Software\Microsoft\WebManagement\Server" -Value "EnableRemoteManagement" -RemoteComputer $server
			if ($os -like "*2003*") {$remotemgmt = "Not applicable"}
			elseif ($remotemgmt -eq "1") {$remotemgmt = "Set Correct: " + $remotemgmt}
			else {$remotemgmt = "Set Wrong: " + $remotemgmt}
			$UAC = Get-Reg -Hive LocalMachine -Key "Software\Microsoft\Windows\CurrentVersion\Policies\System" -Value "EnableLUA" -RemoteComputer $server
			if ($os -like "*2003*") {$UAC = "Not applicable"}
			elseif ($UAC -eq "0") {$UAC = "Set Correct: " + $UAC}
			else {$UAC = "Set Wrong: " + $UAC}
			$XPBY = (Select-String \\$server\C$\Windows\System32\inetsrv\config\applicationHost.config -pattern "X-PBY" | Select -ExpandProperty Line) -replace '<','' -replace '>','' -replace '/','' -replace '                ',''
			$ISAPI = (Select-String \\$server\C$\Windows\System32\inetsrv\config\applicationHost.config -pattern "rllog.dll" | Select -ExpandProperty Line) -replace '<','' -replace '>','' -replace '/','' -replace '            ',''
			writeMiscInfo $InspectorGadgetFile $Members $httperr $remotemgmt $UAC $XPBY $ISAPI
			
			###########
			# Time and directory info
			$InstallDate,$LastBootUpTime,$TimeZone,$Batch,$IIS = ""
			if ($mode -eq "clean") {writeTimeDirTableHeader $InspectorGadgetFile}
			$LocalDateTime = [Management.ManagementDateTimeConverter]::ToDateTime($os_wmi.LocalDateTime)
			$InstallDate = [Management.ManagementDateTimeConverter]::ToDateTime($os_wmi.InstallDate)
			$LastBootUpTime = [Management.ManagementDateTimeConverter]::ToDateTime($os_wmi.LastBootUpTime)
			$tz_wmi = gwmi Win32_TimeZone -ComputerName $server | Select-Object -Property [a-z]*
			$TimeZone = $tz_wmi.Caption
			if ($TimeZone -eq "(GMT-05:00) Eastern Time (US & Canada)") {$TimeZone = "Set Correct: " + $TimeZone}
			elseif ($TimeZone -eq "(UTC-05:00) Eastern Time (US & Canada)") {$TimeZone = "Set Correct: " + $TimeZone}
			else {$TimeZone = "Set Wrong: " + $TimeZone}			
			$BatchDirExists = Test-Path "\\$server\c$\batch"
			if ($BatchDirExists -eq $True) 
			{$BatchDirSize = (Get-ChildItem \\$server\c$\batch -recurse | Measure-Object -property length -sum)			
			$BatchDirCount = (Get-ChildItem \\$server\c$\batch -recurse).count
			if (!$BatchDirCount) {$Batch = "Batch directory empty!"} else {$Batch = "Batch dir: $BatchDirCount files totaling {0:N2}" -f ($BatchDirSize.sum / 1MB) + " MB"}}
			else {$Batch = "IIS directory doesn't exist"}
			$IISDirExists = Test-Path "\\$server\d$\iislogs"
			if ($IISDirExists -eq $True)
			{$IISDirItems = (Get-ChildItem \\$server\d$\iislogs -recurse | Measure-Object -property length -sum)
			$IISDirCount = (Get-ChildItem \\$server\d$\iislogs -recurse).count
			if (!$IISDirCount) {$IIS  = "IIS directory empty!"} else {$IIS = "IIS Dir: $IISDirCount files totaling {0:N2}" -f ($IISDirItems.sum / 1GB) + " GB"}}
			else {$IIS = "IIS directory doesn't exist"} 
			
			writeTimeDirInfo $InspectorGadgetFile $LocalDateTime $InstallDate $LastBootUpTime $TimeZone $Batch $IIS
				
			############
			# Scheduled tasks
			if ($mode -eq "clean") {writeTaskTableHeader $InspectorGadgetFile}
			$schedtasks = ""
			$schedule = new-object -com("Schedule.Service")
			$schedule.connect($server)
			$tasks = $schedule.getfolder("\").gettasks(0)
			$tasks = $tasks | select Name, Enabled, LastRunTime, NextRunTime
			foreach ($task in $tasks) {$schedtasks += "$task<br/>"}
			writeTaskInfo $InspectorGadgetFile $schedtasks
			
			if ($mode -eq "dirty")
			{Add-Content $InspectorGadgetFile "</td></td>"}
			
			Add-Content $InspectorGadgetFile "<tr><td colSpan=6><br/><br/></td></tr>"
			Add-Content $InspectorGadgetFile "</table>"
		}
	}

	writeHtmlFooter $InspectorGadgetFile
	Copy-Item $InspectorGadgetFile "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$InspectorGadgetFileName"
	sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <kirk.jantzer@careerbuilder.com>" "Inspector Gadget: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFile
}