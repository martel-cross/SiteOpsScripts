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
param($list,$email)
$serverlist = @()
$PingableServerList = @()
$IGDirectory = "d:\Share\scripts\IG\"
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
		 	if (($child.ObjectCategory -like '*computer*') -and ($child.userAccountControl -eq '4096')) { $serverlist += $child.Name }
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
$script:os_wrong,$script:activation_wrong,$script:proxy_wrong,$script:diskname_wrong,$script:diskcrit_wrong,$script:ip_wrong,$script:dns_wrong,$script:mtu_wrong,$script:netbios_wrong, `
$script:ipv6_wrong,$script:dynports_wrong,$script:httperr_wrong,$script:rmtmgmt_wrong,$script:uac_wrong,$script:xpby_wrong,$script:isapi_wrong,$script:installdate_wrong, `
$script:lastboot_wrong,$script:timezone_wrong,$script:dirs_wrong,$script:tasks_wrong,$script:bios_wrong,$script:firmware_wrong,$script:idracinfo_wrong = ""
$InspectorGadgetFileName = "InspectorGadget_Windows_$datetime.htm"
$tempfile = [system.io.path]::GetTempFileName()
$InspectorGadgetFile = $tempfile
$InspectorGadgetRealFile = $IGDirectory + $InspectorGadgetFileName
New-Item -ItemType file $InspectorGadgetFile -Force

#writeHtmlHeader
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

#Function writeDellInfoHeader
#{
#	param($InspectorGadgetFile)
#	Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
#	<td colspan='2' align='center'><strong>BIOS Settings</strong></td>
#	<td colspan='2' align='center'><strong>Firmware Versions</strong></td>
#	<td colspan='2' align='center'><strong>iDRAC Info</strong></td>
#	</tr>"
#}

Function writeNetworkTableHeader
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "<table width='100%'><tr bgcolor=#CCCCCC>
	<td align='center'><strong>Server Name</strong></td>
	<td align='center'><strong>Production IP</strong></td>
	<td align='center'><strong>DB VLAN IP</strong></td>
	<td align='center'><strong>Caption</strong></td></tr>"
}

Function writeHtmlFooter
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "</body></html>"
}


#Function writeDellInfo
#{
#	param($InspectorGadgetFile,$BIOS,$Firmeware,$iDracInfo)
#	Add-Content $InspectorGadgetFile "<tr>"
#	if ((!$BIOS) -or ($BIOS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td colspan='2' bgcolor='#FF0000' align=center valign='top'>$BIOS_Settings</td>";$script:things_wrong++;$script:bios_wrong+="<a href='#$server'>$server</a>, ";$script:bios_wrong_count++} 
#	else {Add-Content $InspectorGadgetFile "<td colspan='2'>$BIOS</td>"}
#	if ((!$Firmeware) -or ($Firmeware -match "Wrong")) {Add-Content $InspectorGadgetFile "<td colspan='2' bgcolor='#FF0000' align=center valign='top'>$Firmeware</td>";$script:things_wrong++;$script:firmware_wrong+="<a href='#$server'>$server</a>, ";$script:firmware_wrong_count++} 
#	else {Add-Content $InspectorGadgetFile "<td colspan='2' valign='top'>$Firmeware</td>"}
#	if ((!$iDracInfo) -or ($iDracInfo -match "Wrong")) {Add-Content $InspectorGadgetFile "<td colspan='2' bgcolor='#FF0000' align=center valign='top'>$iDracInfo</td>";$script:things_wrong++;$script:iDracInfo_wrong+="<a href='#$server'>$server</a>, ";$script:iDracInfo_wrong_count++} 
#	else {Add-Content $InspectorGadgetFile "<td colspan='2' valign='top'>$iDracInfo</td>"}
#	Add-Content $InspectorGadgetFile "</tr>"
#}

Function writeNetworkInfo
{
	param($InspectorGadgetFile,$server,$IP,$DBIP,$thisCaption)	
	Add-Content $InspectorGadgetFile "<tr>"
	Add-Content $InspectorGadgetFile "<td>$server</td>"
	if (!$IP) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$IP</td>";$script:things_wrong++;$script:ip_wrong+="<a href='#$server'>$server</a>, "} 
	else {Add-Content $InspectorGadgetFile "<td>$IP</td>"}
	if (!$DBIP) {Add-Content $InspectorGadgetFile "<td>$DBIP</td>"} 
	else {Add-Content $InspectorGadgetFile "<td>$DBIP</td>"}
	if (!$thisCaption) {Add-Content $InspectorGadgetFile "<td>$thisCaption</td>"} 
	else {Add-Content $InspectorGadgetFile "<td>$thisCaption</td>"}
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
writeNetworkTableHeader $InspectorGadgetFile
foreach ($server in $serverlist)
{
	if ($server -notmatch  "QTWLS|BEARLS|DRAGONLS|AMSTELLS|QTMSTATSLS")
	{
		$script:server_count++
		
		###########
		# Dell info
		if ($hw1.model -match "PowerEdge")
		{
			writeDellInfoHeader $InspectorGadgetFile
			$BIOS = invoke-command -computername $server -scriptblock {omreport chassis biossetup} | Foreach-Object {$_ -replace "(?m)^", "<br />"}
			$Firmware = invoke-command -computername $server -scriptblock {omreport system version} | Foreach-Object {$_ -replace "(?m)^", "<br />"}
			$iDracInfo = invoke-command -computername $server -scriptblock {omreport chassis remoteaccess} | Foreach-Object {$_ -replace "(?m)^", "<br />"}
			$Memory = invoke-command -computername $server -scriptblock {omreport chassis memory} | Foreach-Object {$_ -replace "(?m)^", "<br />"}
			writeDellInfo $InspectorGadgetFile $BIOS $Firmware $iDracInfo
		}
		
		##############
		# network info
		$IP,$DBIP = "",""
		#$nw = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*
		$ip_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property IPAddress,DefaultIPGateway,IPSubnet,Caption
		foreach ($objItem in $ip_wmi)
		{
			$thisIP = [string]$objItem.IPAddress
			$thisCaption = [string]$objItem.Caption
			if (($thisIP.StartsWith("10.210.67")) -or ($thisIP.StartsWith("10.235.")) -or ($thisIP.StartsWith("10.235.")) -or ($thisIP.StartsWith("10.245.")) -or ($thisIP.StartsWith("10.236.")) -or ($thisIP.StartsWith("10.205.")) -or ($thisIP.StartsWith("10.227.")))
			{
				if ($objItem.IPSubnet -eq "255.255.0.0") {$IPSubnet = "/16"}
				elseif ($objItem.IPSubnet -eq "255.255.255.0") {$IPSubnet = "/24"}
				else {$IPSubnet = ""}
				if (!$objItem.DefaultIPGateway) {$Gateway = ""}
				else {$Gateway = ", GW: " + $objItem.DefaultIPGateway}
				$DBIP = $thisIP + $IPSubnet + $Gateway
			}
			elseif
			($thisIP -eq "0.0.0.0") {$IP += ""}
			else 
			{
				if ($objItem.IPSubnet -eq "255.255.0.0") {$IPSubnet = "/16"}
				elseif ($objItem.IPSubnet -eq "255.255.255.0") {$IPSubnet = "/24"}
				else {$IPSubnet = ""}
				if (!$objItem.DefaultIPGateway) {$Gateway = ""}
				else {$Gateway = ", GW: " + $objItem.DefaultIPGateway}
				$IP = $thisIP + $IPSubnet + $Gateway
			}	
			$thisIP = ""
			
		}
		writeNetworkInfo $InspectorGadgetFile $server $IP $DBIP $thisCaption
		Write-Host "$server $IP $DBIP $thisCaption done being checked"
		$thisCaption = ""
	}	
}
Add-Content $InspectorGadgetFile "<tr><td colSpan=3><br/><br/></td></tr>"
Add-Content $InspectorGadgetFile "</table>"
writeHtmlFooter $InspectorGadgetFile

function Insert-Content ($InspectorGadgetFile) 
{
	BEGIN {$content = Get-Content $InspectorGadgetFile}
	PROCESS {$_ | Set-Content $InspectorGadgetFile}
	END {$content | Add-Content $InspectorGadgetFile}
}

$prereport = "<div align='center'><img src='inspector_gadget.jpg' /></div><br/>Welcome to the Inspector Gadget report for $date. There were $server_count servers scanned, and Inspector Gadget found $things_wrong things wrong.<br /><br />"
	
if (($ip_wrong) -or ($servers_offline))
{
	
	$prereport += "<b>Here is a brief list of things that need to be addressed on which servers. If any servers are listed here, please click any of the server names to navigate to that servers information table.</b><br /><br />"
	if($ip_wrong){$prereport += "<b>IPs:</b><br />$ip_wrong <br /><br />"}
}

$header = $writeHtmlHeader + $prereport

$InspectorGadgetFile = $header | Insert-Content $InspectorGadgetFile

Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$InspectorGadgetFileName"
if ($email -eq "me")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <cody.rucks@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}
else {sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <siteservers@careerbuilder.com>" "Inspector Gadget: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}