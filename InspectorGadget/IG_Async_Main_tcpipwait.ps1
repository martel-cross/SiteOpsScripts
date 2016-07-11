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
#		Last Change: Add Line 386 | 387-391 changed to elseif
######################################################################################
param($list,$email)
$serverlist = @()
$PingableServerList = @()
$IGDirectory = "\\cbatl\share\scripts\ig\"
$ServerListFile = $IGDirectory + "serverlist.txt"
$ServerListFile_Custom = $IGDirectory + "serverlist_custom_async.txt"
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
$script:os_wrong,$script:activation_wrong,$script:proxy_wrong,$script:diskname_wrong,$script:diskcrit_wrong,$script:ip_wrong,$script:dns_wrong,$script:mtu_wrong,$script:timedwait_wrong,$script:netbios_wrong, `
$script:ipv6_wrong,$script:dynports_wrong,$script:httperr_wrong,$script:rmtmgmt_wrong,$script:uac_wrong,$script:xpby_wrong,$script:isapi_wrong,$script:installdate_wrong, `
$script:lastboot_wrong,$script:timezone_wrong,$script:dirs_wrong,$script:tasks_wrong,$script:bios_wrong,$script:firmware_wrong,$script:idracinfo_wrong,$script:hostsfile_wrong,$script:F5fwd_wrong = ""

$script:os_wrong_count,$script:activation_wrong_count,$script:proxy_wrong_count,$script:diskname_wrong_count,$script:diskcrit_wrong_count,$script:ip_wrong_count,$script:dns_wrong_count,$script:mtu_wrong_count,$script:timedwait_wrong_count,$script:netbios_wrong, `
$script:ipv6_wrong_count,$script:dynports_wrong_count,$script:httperr_wrong_count,$script:rmtmgmt_wrong_count,$script:uac_wrong_count,$script:xpby_wrong_count,$script:isapi_wrong_count,$script:installdate_wrong, `
$script:lastboot_wrong_count,$script:timezone_wrong_count,$script:dirs_wrong_count,$script:tasks_wrong_count,$script:bios_wrong_count,$script:firmware_wrong_count,$script:idracinfo_wrong_count,$script:hostsfile_wrong_count,$script:F5fwd_wrong_count = 0

###EXCLUSIONS###
$f5_exclude = "REBELLS|REBELWEBTEST02|REBELWS1|QTWSPARE2|REBELBLAST1|BEARDRWEB1|BEARDRDOC1|BEARSRCHBAT1|BEARSRCHBAT2|LUIGIBOASYNC1|LUIGIBOBATCH1|LUIGIBOBLAST|LUIGIBOWS1|LUIGIMAILBOSM1|LUIGIMX1|LUIGIMXWS1|LUIGIDPIBATCH1| `
LUIGIDPIBLAST1|LUIGIDPIFEED1|LUIGIDPIMAIL1|LUIGIDPISVC1|LUIGIDPISVC2|LUIGIMAP1|LUIGIMAP2|LUIGIMAP3|LUIGIMAP4|LUIGIBLAST|LUIGISPARE1|DRAGONBLAST1|AMSTELBLAST1|CBASYNC204|CBASYNC221|CBBLAST100|CBLS|DWTEST1|ORKINWEB2|REBELDW1| `
REBELDW2|REBELDW3|BOBATCH100|BOBATCH101|BOBLAST100|MAILBOSM1|MAILBOSM2|REBELBOASYNC1|REBELBOASYNC2|REBELBOWS1|REBELBOWS2|REBELMX100|REBELMX101|REBELMX102|REBELMXWS100|REBELMXWS101|REBELNXS1|REBELNXS2|BEARDPIBATCH1|BEARDPIBATCH2| `
BEARDPISVC1|BEARDPISVC2|BEARDPIWEB1|BEARDPIWEB2|DPIBATCH1Q|DPIBATCH2Q|DPIBLAST1Q|DPIFEED1Q|DPIFEED2Q|DPIMAIL1Q|DPIMAIL2Q|DPISVC1Q|DPISVC2Q|DPISVC3Q|DPISVC4Q|REBELDPIBATCH1|REBELDPIBATCH2|REBELDPISVC1|REBELDPISVC2|REBELDPIWEB1| `
REBELDPIWEB2|QTMMAP1|QTMMAP10|QTMMAP2|QTMMAP3|QTMMAP4|QTMMAP5|QTMMAP6|QTMMAP7|QTMMAP8|QTMMAP9|DEVDFS1|DEVVMCTR|GHQBLAST|GHQBLAST01|GHQDEPLOYTEST1|GHQDEPLOYTEST2|GHQDEPLOYTEST3|GHQFLASH|GHQHADOOPUTIL|GHQJSTEST|GHQLS|GHQTEST0| `
GHQTEST1|GHQTEST10|GHQTEST11|GHQTEST12|GHQTEST13|GHQTEST14|GHQTEST15|GHQTEST16|GHQTEST17|GHQTEST18|GHQTEST19|GHQTEST2|GHQTEST20|GHQTEST21|GHQTEST3|GHQTEST4|GHQTEST5|GHQTEST6|GHQTEST7|GHQTEST8|GHQTEST9|PIREPORT1|SPARETESTER1"
$task_exclude = "DEVDFS1|DEVVMCTR|LUIGILOGIC1A|LUIGILOGIC1B|DEVLOGIC1A|DEVLOGIC1B|DEVLOGIC2A|DEVLOGIC2B|DRAGONLOGIC1A|DRAGONLOGIC1B|GHQBLAST01|GHQBLAST01B|SPARETESTER1|PIREPORT1|GHQPRODBLAST| ` GHQJSTEST|GHQHADOOPUTIL|CBDFS1|REBELDFS1| REBELWDS|BEARDFS1|GHQBUILD1|GHQBUILD2"
$directory_exclude = "DEVDFS1|DEVVMCTR|SPARETESTER1"
$XPBY_exclude = "DEVDFS1|DEVVMCTR|LUIGILOGIC1A|LUIGILOGIC1B|DEVLOGIC1A|DEVLOGIC1B|DEVLOGIC2A|DEVLOGIC2B|DRAGONLOGIC1A|DRAGONLOGIC1B|GHQBLAST01|GHQBLAST01B|"
$director_exclude = "DEVDFS1|DEVVMCTR|LUIGILOGIC1A|LUIGILOGIC1B|DEVLOGIC1A|DEVLOGIC1B|DEVLOGIC2A|DEVLOGIC2B|DRAGONLOGIC1A|DRAGONLOGIC1B|GHQBLAST01|GHQBLAST01B|"
$host_exclude = "DEVDFS1|DEVVMCTR|LUIGILOGIC1A|LUIGILOGIC1B|DEVLOGIC1A|DEVLOGIC1B|DEVLOGIC2A|DEVLOGIC2B|DRAGONLOGIC1A|DRAGONLOGIC1B|GHQBLAST01|GHQBLAST01B|"


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

Function writeHtmlFooter
{
	param($InspectorGadgetFile)
	Add-Content $InspectorGadgetFile "</body></html>"
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
#
#
# Plan to make this part async.  First I need to separate the
# logic that adds content to the html file from creating the actual
# html string.  I will store the string in a variable and then add
# the content once all data has been collected.  This will allow me
# to 'detach', with the use of jobs, the data gathering code and run it in its own instance.
#
#########################################################

#Server hashtable template
$async_Server_Template = @{
	html = ''
	name = ''
	model = ''
	things_wrong = 0
	os_wrong = ''
	os_wrong_count = 0
	activation_wrong = ''
	activation_wrong_count = 0
	proxy_wrong = ''
	proxy_wrong_count = 0
	totalsockets = 0
	totalcores = 0
	diskname_wrong = ''
	diskname_wrong_count = 0
	totalspace = 0
	diskcrit_wrong = ''
	diskcrit_wrong_count = 0
	ip_wrong = ''
	ip_wrong_count = 0
	dns_wrong = ''
	dns_wrong_count = 0
	mtu_wrong = ''
	mtu_wrong_count = 0
	timedwait_wrong = ''
	timedwait_wrong_count = 0
	netbios_wrong = ''
	netbios_wrong_count = 0
	ipv6_wrong = ''
	ipv6_wrong_count = 0
	httperr_wrong = ''
	httperr_wrong_count = 0
	rmtmgmt_wrong = ''
	rmtmgmt_wrong_count = 0
	uac_wrong = ''
	uac_wrong_count = 0
	xpby_wrong = ''
	xpby_wrong_count = 0
	F5fwd_wrong = ''
	F5fwd_wrong_count = 0
	install_wrong = ''
	install_wrong_count = 0
	installdate_wrong = ''
	installdate_wrong_count = 0
	lastboot_wrong = ''
	lastboot_wrong_count = 0
	timezone_wrong = ''
	timezone_wrong_count = 0
	dirs_wrong = ''
	dirs_wrong_count = 0
	hostsfile_wrong = ''
	hostsfile_wrong_count = 0
	bios_wrong = ''
	bios_wrong_count = 0
	firmware_wrong = ''
	firmware_wrong_count = 0
	iDracInfo_wrong = ''
	iDracInfo_wrong_count = 0
	tasks_wrong = ''
	tasks_wrong_count = 0
}

#Empty array we will use for storing job identifiers
$jobs = @()

foreach ($server in $serverlist)
{
	#Copy the server object
	#
	#Note: clone only does a 'shallow copy', a 'deep copy' may be needed
	#http://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell
	$async_server = $async_Server_Template.Clone()
	$async_server.name = $server
	
	if ($async_server.name -notmatch  "QTWLS|BEARLS|DRAGONLS|AMSTELLS|QTMSTATSLS")
	{
		$script:server_count++
		
		#-InitializationScript $asyncFunctions 
		
		$jobs += Start-Job -ScriptBlock {
			
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
			
			
			Function writeNetworkTableHeader
			{
				param($InspectorGadgetFile)
				Add-Content $InspectorGadgetFile "<tr bgcolor=#CCCCCC>
				<td align='center'><strong>IP Addresses</strong></td>
				<td align='center'><strong>DNS Servers</strong></td>
				<td align='center'><strong>MTU & TCP/IP Wait</strong></td>
				<td align='center'><strong>NetBIOS</strong></td>
				<td align='center'><strong>IPv6</strong></td>
				<td align='center'><strong>Dynamic Ports</strong></td>
				</tr>"
			}
			
			Function writeNetworkInfo
			{
				param($InspectorGadgetFile,$IP,$DNS,$MTU,$timedwait,$NetBIOS,$ipv6)	
				Add-Content $InspectorGadgetFile "<tr>"
				if (!$IP) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$IP</td>";$async_server.things_wrong++;$async_server.ip_wrong+="<a href='#$server'>$server</a>, ";$async_server.ip_wrong_count++} 
				else {Add-Content $InspectorGadgetFile "<td>$IP</td>"}
				if ((!$DNS) -or ($DNS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$DNS</td>";$async_server.things_wrong++;$async_server.dns_wrong+="<a href='#$server'>$server</a>, ";$async_server.dns_wrong_count++} 
				else {Add-Content $InspectorGadgetFile "<td>$DNS</td>"}
				if ((!$MTU) -or ($MTU -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$MTU</td>";$async_server.things_wrong++;$async_server.mtu_wrong+="<a href='#$server'>$server</a>, ";$async_server.mtu_wrong_count++} 
				else {Add-Content $InspectorGadgetFile "<td>$MTU</td>"}
				#if ((!$timedwait) -or ($timedwait -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$timedwait</td>";$async_server.things_wrong++;$async_server.$timedwait_wrong+="<a href='#$server'>$server</a>, ";#$async_server.timedwait_wrong_count++}
				#else {Add-Content $InspectorGadgetFile "<td>$timedwait</td>"
				if ((!$NetBIOS) -or ($NetBIOS -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$NetBIOS</td>";$async_server.things_wrong++;$async_server.netbios_wrong+="<a href='#$server'>$server</a>, ";$async_server.netbios_wrong_count++} 
				else {Add-Content $InspectorGadgetFile "<td>$NetBIOS</td>"}
				if ((!$ipv6) -or ($ipv6 -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$ipv6</td>";$async_server.things_wrong++;$async_server.ipv6_wrong+="<a href='#$server'>$server</a>, ";$async_server.ipv6_wrong_count++} 
				else {Add-Content $InspectorGadgetFile "<td>$ipv6</td>"}
				#if ((!$dynamic_ports) -or ($dynamic_ports -match "Wrong")) {Add-Content $InspectorGadgetFile "<td bgcolor='#FF0000' align=center>$dynamic_ports</td>";$script:things_wrong++;$script:dynports_wrong+="<a href='#$server'>$server</a>, "} 
				#else {Add-Content $InspectorGadgetFile "<td>$dynamic_ports</td>"}
				Add-Content $InspectorGadgetFile "<td>$dynamic_ports</td>"
				Add-Content $InspectorGadgetFile "</tr>"
			}

			#########
			# START
			#########
			$async_server = $args[0]
			$server = $async_server.name
			
			$async_server.html += "<table width='100%'><tbody>"
			$async_server.html += "<tr bgcolor='#CCCCCC'>"
			$async_server.html += "<td width='100%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong><a name='$($async_server.name)'>$($async_server.name)</a></strong></font><font face='tahoma' color='#003399' size='1'>&nbsp;&nbsp;&nbsp;&nbsp;<a href='#top'>[Top of page]</a></font></td>"
			$async_server.html += "</tr>"
		
			#############
			# system info
			$os,$activation,$TotalRAM = ""
			
			###############################
			#
			# Since these functions that create html append to
			# a file, I need to create a temp file for each server
			# and then read that.  The HTML functions need to be rewritten.
			#
			###############################
			$async_tempFile = [System.IO.Path]::GetTempFileName()
		
		
		
			##############
			# network info
			$IP,$DNS,$dnschk,$ipv6,$MTU,$MTU_value,$MTU_result,$NetBIOS,$dynamic_ports = "","","","","","","","",""
			
			
			writeNetworkTableHeader $async_tempFile
		
		
			#$nw = gwmi Win32_NetworkAdapterConfiguration -ComputerName $async_server.name -Filter IPEnabled=True | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*
			$ip_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $async_server.name -Filter IPEnabled=True | Select-Object -Property IPAddress,DefaultIPGateway,IPSubnet
			foreach ($objItem in $ip_wmi)
			{
				#if ([string]$objItem.IPAddress -eq "0.0.0.0") {$IP += ""}
				#else {$IP += "IP: " + [string]$objItem.IPAddress + ", GW: " + $objItem.DefaultIPGateway + ", SM: " + $objItem.IPSubnet + "`n"}
				if ([string]$objItem.IPAddress -eq "0.0.0.0") {$IP += ""}
				else 
				{
					if ($objItem.IPSubnet -eq "255.255.0.0") {$IPSubnet = "/16"}
					elseif ($objItem.IPSubnet -eq "255.255.255.0") {$IPSubnet = "/24"}
					else {$IPSubnet = ""}
					if (!$objItem.DefaultIPGateway) {$Gateway = ""}
					else {$Gateway = ", GW: " + $objItem.DefaultIPGateway}
					$IP += "IP: " + [string]$objItem.IPAddress + $IPSubnet + $Gateway + "`n"
				}
			}
			$dns_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $async_server.name -Filter IPEnabled=True | Select-Object -Property DNSServerSearchOrder
			foreach ($objItem in $dns_wmi) {$dnschk += [string]$objItem.DNSServerSearchOrder}	
			#$dnschk = [string]$objItem.DNSServerSearchOrder
			$dnschk = $dnschk.Split(" ")
			if (!$dnschk[1])
			{$DNS = "Set Wrong: " + $dnschk[0]}
			else 
			{$DNS = $dnschk[0] + ", " + $dnschk[1]}
			$nb_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $async_server.name -Filter IPEnabled=True | Select-Object -Property TcpipNetbiosOptions
			foreach ($objItem in $nb_wmi)
			{
				if ($objItem.TcpipNetbiosOptions -eq "2") {$NetBIOS = "Set Correct: " + $objItem.TcpipNetbiosOptions}
				elseif ($os -like "*2003*") {$NetBIOS = "Not applicable"}
				else {$NetBIOS = "Set Wrong: " + $objItem.TcpipNetbiosOptions}
			}
			$ipv6 = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Value "DisabledComponents" -RemoteComputer $async_server.name
			if ($os -like "*2003*") {$ipv6 = "Not applicable"}
			elseif ($ipv6 -eq "-1") {$ipv6 = "Set Correct: " + $ipv6}
			else {$ipv6 = "Set Wrong: " + $ipv6}
			$dynamic_ports = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Value "MaxUserPort" -RemoteComputer $async_server.name
			if ($dynamic_ports -eq "51024") {$dynamic_ports = "Set Correct: " + $dynamic_ports}
			else {$dynamic_ports = "Set Wrong: " + $dynamic_ports}
			# MTU Reg fetcher
			[array]$MTUarray = $null
			$key = "SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces"
			$type = [Microsoft.Win32.RegistryHive]::LocalMachine
			$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $async_server.name)
			$regKey = $regKey.OpenSubKey($key)
			Foreach($sub in $regKey.GetSubKeyNames())
			{
				$NICPOOLS = "SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$sub"
				$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $async_server.name)
				$regKey = $regKey.OpenSubKey($NICPOOLS)
				Foreach($val in $regKey.GetValueNames()) 
				{
					$MTU_value = ""
					if ($val -eq "MTU") 
					{
						$MTU_IPaddr = $regKey.GetValue("IPAddress")
						$MTU_value = $regKey.GetValue("$val")
						if ($MTU_value -eq "1380") {$MTU_result = "Set Correct: " + $MTU_value + " for " + $MTU_IPaddr}
						else {$MTU_result = "Set Wrong: " + $MTU_value + " for " + $MTU_IPaddr}
						$MTUarray += [string]$MTU_result
					}
				}
			}

			foreach ($MTUobj in $MTUarray)
			{$MTU += "$MTUobj`n"}
			# TCP/IP Timed Wait
			#$timedwait = Get-Reg -Hive LocalMachine -Key "SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Value "TcpTimedWaitDelay" -RemoteComputer $async_server.name
			#if ($timedwait -eq "90") {$timedwait = "Set Correct: 90"}
			#elseif ((!$timedwait) -or ($timedwait -eq "120")) {$timedwait = "Value is not correct!"}
			
		
			writeNetworkInfo $async_tempFile $IP $DNS $MTU $NetBIOS $ipv6 $dynamic_ports 
			
		} -ArgumentList @($async_server)
	}
}

#Wait for each job to finish and once done get info, update globals,
#and write html to master file
foreach ($job in $jobs)
{
	#Wait for Job to finish
	$catchOutput = Wait-Job $job
	
	#Get results from job
	$jobResults = Receive-Job $job
	
	#Update globals
	$script:models += $jobResults.model
	$script:things_wrong += $jobResults.things_wrong
	$script:os_wrong += $jobResults.os_wrong
	$script:os_wrong_count += $jobResults.os_wrong_count
	$script:activation_wrong += $jobResults.activation_wrong
	$script:activation_wrong_count += $jobResults.activation_wrong_count
	$script:proxy_wrong += $jobResults.proxy_wrong
	$script:proxy_wrong_count += $jobResults.proxy_wrong_count
	$script:totalsockets += $jobResults.totalsockets
	$script:totalcores += $jobResults.totalcores
	$script:diskname_wrong += $jobResults.diskname_wrong
	$script:diskname_wrong_count += $jobResults.diskname_wrong_count
	$script:totalspace += $jobResults.totalspace
	$script:diskcrit_wrong += $jobResults.diskcrit_wrong
	$script:diskcrit_wrong_count += $jobResults.diskcrit_wrong_count
	$script:ip_wrong += $jobResults.ip_wrong
	$script:ip_wrong_count += $jobResults.ip_wrong_count
	$script:dns_wrong += $jobResults.dns_wrong
	$script:dns_wrong_count += $jobResults.dns_wrong_count
	$script:mtu_wrong += $jobResults.mtu_wrong
	$script:mtu_wrong_count += $jobResults.mtu_wrong_count
	$script:timedwait_wrong += $jobResults.timedwait_wrong
	$script:timedwait_wrong_count += $jobResults.timedwait_wrong_count
	$script:netbios_wrong += $jobResults.netbios_wrong
	$script:netbios_wrong_count += $jobResults.netbios_wrong_count
	$script:ipv6_wrong += $jobResults.ipv6_wrong
	$script:ipv6_wrong_count += $jobResults.ipv6_wrong_count
	$script:httperr_wrong += $jobResults.httperr_wrong
	$script:httperr_wrong_count += $jobResults.httperr_wrong_count
	$script:rmtmgmt_wrong += $jobResults.rmtmgmt_wrong
	$script:rmtmgmt_wrong_count += $jobResults.rmtmgmt_wrong_count
	$script:uac_wrong += $jobResults.uac_wrong
	$script:uac_wrong_count += $jobResults.uac_wrong_count
	$script:xpby_wrong += $jobResults.xpby_wrong
	$script:xpby_wrong_count += $jobResults.xpby_wrong_count
	$script:F5fwd_wrong += $jobResults.F5fwd_wrong
	$script:F5fwd_wrong_count += $jobResults.F5fwd_wrong_count
	$script:install_wrong += $jobResults.install_wrong
	$script:install_wrong_count += $jobResults.install_wrong_count
	$script:installdate_wrong += $jobResults.installdate_wrong
	$script:installdate_wrong_count += $jobResults.installdate_wrong_count
	$script:lastboot_wrong += $jobResults.lastboot_wrong
	$script:lastboot_wrong_count += $jobResults.lastboot_wrong_count
	$script:timezone_wrong += $jobResults.timezone_wrong
	$script:timezone_wrong_count += $jobResults.timezone_wrong_count
	$script:dirs_wrong += $jobResults.dirs_wrong
	$script:dirs_wrong_count += $jobResults.dirs_wrong_count
	$script:hostsfile_wrong += $jobResults.hostsfile_wrong
	$script:hostsfile_wrong_count += $jobResults.hostsfile_wrong_count
	$script:bios_wrong += $jobResults.bios_wrong
	$script:bios_wrong_count += $jobResults.bios_wrong_count
	$script:firmware_wrong += $jobResults.firmware_wrong
	$script:firmware_wrong_count += $jobResults.firmware_wrong_count
	$script:iDracInfo_wrong += $jobResults.iDracInfo_wrong
	$script:iDracInfo_wrong_count += $jobResults.iDracInfo_wrong_count
	$script:tasks_wrong += $jobResults.tasks_wrong
	$script:tasks_wrong_count += $jobResults.tasks_wrong_count
	
	Write-Host "$($jobResults.name) done being checked"
	
	#Write to master html file
	Add-Content $InspectorGadgetFile $jobResults.html
}
##### Write Footer
writeHtmlFooter $InspectorGadgetFile

function Insert-Content ($InspectorGadgetFile) 
{
	BEGIN {$content = Get-Content $InspectorGadgetFile}
	PROCESS {$_ | Set-Content $InspectorGadgetFile}
	END {$content | Add-Content $InspectorGadgetFile}
}

$prereport = "<div align='center'><img src='inspector_gadget.jpg' /></div><br/>Welcome to the Inspector Gadget report for $date. There were $server_count servers scanned, and Inspector Gadget found $things_wrong things wrong.<br /><br />"
$ModelCount = $Models | group | sort count -desc | select count,name
if($totalspace){$totalspace = "{0:N2}" -f $totalspace;$prereport += "<b>Total drive space of all servers:</b><br />$totalspace GB<br /><br />"}
if($totalsockets){$prereport += "<b>Total sockets of all servers:</b><br />$totalsockets<br /><br />"}
if($totalcores){$prereport += "<b>Total cores of all servers:</b><br />$totalcores<br /><br />"}
if($ModelCount)
{
	$prereport += "<b>Total count of each model server:</b><br />"
	$prereport += "<table>"
	$prereport += "<tr><td>Model</td><td>Quantity</td></tr>"
	foreach ($model in $ModelCount) {$prereport += "<tr><td>$($model.name)</td><td>$($model.count)</td></tr>"}
	$prereport += "</table>"
	$prereport += "<br /><br />"
}
	
if (($mtu_wrong) -or ($timedwait_wrong) -or ($os_wrong) -or ($activation_wrong) -or ($proxy_wrong) -or ($diskname_wrong) -or ($diskcrit_wrong) -or ($ip_wrong) -or ($dns_wrong) -or `
($mtu_wrong) -or ($timedwait_wrong) -or ($netbios_wrong) -or ($ipv6_wrong) -or ($dynports_wrong) -or ($httperr_wrong) -or ($rmtmgmt_wrong) -or  `
($uac_wrong) -or ($xpby_wrong) -or ($isapi_wrong) -or ($installdate_wrong) -or ($lastboot_wrong) -or  `
($timezone_wrong) -or ($dirs_wrong) -or ($tasks_wrong) -or ($servers_offline) -or ($bios_wrong) -or ($firmware_wrong) -or ($idracinfo_wrong) -or ($hostsfile_wrong) -or ($F5fwd_wrong))
{
	
	$prereport += "<b>Here is a brief list of things that need to be addressed on which servers. If any servers are listed here, please click any of the server names to navigate to that servers information table.</b><br /><br />"
	if($servers_offline){$prereport += "<b><font color='red'>$servers_offline_count </font> Servers were inaccesible during the scan:</b><br />$servers_offline <br /><br />"}
	if($os_wrong){$prereport += "<b><font color='red'>$os_wrong_count </font> Servers with OS older than Windows 2008:</b><br />$os_wrong <br /><br />"}
	if($activation_wrong){$prereport += "<b><font color='red'>$activation_wrong_count </font> Servers not in an Activated state:</b><br />$activation_wrong <br /><br />"}
	if($proxy_wrong){$prereport += "<b><font color='red'>$proxy_wrong_count </font> Servers with a proxy set or misconfigured:</b><br />$proxy_wrong <br /><br />"}
	if($diskname_wrong){$prereport += "<b><font color='red'>$diskname_wrong_count </font> Servers with C Drive name not set to server name:</b><br />$diskname_wrong <br /><br />"}
	if($diskcrit_wrong){$prereport += "<b><font color='red'>$diskcrit_wrong_count </font> Servers with critical disk space:</b><br />$diskcrit_wrong <br /><br />"}
	if($ip_wrong){$prereport += "<b><font color='red'>$ip_wrong_count </font>IPs incorrect:</b><br />$ip_wrong <br /><br />"}
	if($dns_wrong){$prereport += "<b><font color='red'>$dns_wrong_count </font> Servers with incorrect DNS settings:</b><br />$dns_wrong <br /><br />"}
	if($mtu_wrong){$prereport += "<b><font color='red'>$mtu_wrong_count </font> Servers with incorrect MTU setting:</b><br />$mtu_wrong <br /><br />"}
	if($timedwait_wrong){$prereport += "<b><font color='red'>$timedwait_wrong_count </font> Servers with incorrect TCP/IP Wait setting:</b><br />$timedwait <br /><br />"}
	if($netbios_wrong){$prereport += "<b><font color='red'>$netbios_wrong_count </font> Servers with incorrect NETBIOS setting:</b><br />$netbios_wrong <br /><br />"}
	if($ipv6_wrong){$prereport += "<b><font color='red'>$ipv6_wrong_count </font> Servers with IPv6 enabled:</b><br />$ipv6_wrong <br /><br />"}
	if($dynports_wrong){$prereport += "<b><font color='red'>$dynports_wrong_count </font> Servers with incorrect Dynamic TCP Ports setting:</b><br />$dynports_wrong <br /><br />"}
	if($httperr_wrong){$prereport += "<b><font color='red'>$httperr_wrong_count </font> Servers with incorrect HTTPERR Dir setting:</b><br />$httperr_wrong <br /><br />"}
	if($rmtmgmt_wrong){$prereport += "<b><font color='red'>$rmtmgmt_wrong_count </font> Servers with incorrect Remote Management setting:</b><br />$rmtmgmt_wrong <br /><br />"}
	if($uac_wrong){$prereport += "<b><font color='red'>$uac_wrong_count </font> Servers with incorrect UAC setting:</b><br />$uac_wrong <br /><br />"}
	if($xpby_wrong){$prereport += "<b><font color='red'>$xpby_wrong_count </font> Servers with incorrect XPBY setting:</b><br />$xpby_wrong <br /><br />"}
	if($isapi_wrong){$prereport += "<b><font color='red'>$isapi_wrong_count </font> Servers with incorrect ISAPI filters:</b><br />$isapi_wrong <br /><br />"}
	if($F5fwd_wrong){$prereport += "<b><font color='red'>$F5fwd_wrong_count </font> Servers with incorrect F5fwd module:</b><br />$F5fwd_wrong <br /><br />"}
	if($installdate_wrong){$prereport += "<b><font color='red'>$installdate_wrong_count </font> Servers with Install Date older than 3 years (Excluded from total count of errors):</b><br />$installdate_wrong <br /><br />"}
	if($lastboot_wrong){$prereport += "<b><font color='red'>$lastboot_wrong_count </font> Servers with Last Reboot of more than 1 year:</b><br />$lastboot_wrong <br /><br />"}
	if($timezone_wrong){$prereport += "<b><font color='red'>$timezone_wrong_count </font> Servers with incorrect Time Zone:</b><br />$timezone_wrong <br /><br />"}
	if($dirs_wrong){$prereport += "<b><font color='red'>$dirs_wrong_count </font> Servers missing important directories:</b><br />$dirs_wrong <br /><br />"}
	if($hostsfile_wrong){$prereport += "<b><font color='red'>$hostsfile_wrong_count </font> Servers that have a modified hosts file:</b><br />$hostsfile_wrong <br /><br />"}
	if($bios_wrong){$prereport += "<b><font color='red'>$bios_wrong_count </font> Servers unable to get BIOS settings from:</b><br />$bios_wrong <br /><br />"}
	if($firmware_wrong){$prereport += "<b><font color='red'>$firmware_wrong_count </font> Servers unable to get Firmware versions from:</b><br />$firmware_wrong <br /><br />"}
	if($idracinfo_wrong){$prereport += "<b><font color='red'>$idracinfo_wrong_count </font> Servers unable to get iDRAC information from:</b><br />$idracinfo_wrong <br /><br />"}
	if($tasks_wrong){$prereport += "<b><font color='red'>$tasks_wrong_count </font> Servers missing one or more of the important scheduled tasks:</b><br />$tasks_wrong <br /><br />"}
}

$header = $writeHtmlHeader + $prereport

$InspectorGadgetFile = $header | Insert-Content $InspectorGadgetFile

Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$InspectorGadgetFileName"
if ($email -eq "me")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <cody.rucks@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}
elseif ($email -eq "patrick")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "Patrick McGahee<patrick.mcgahee@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}
else {sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <siteservers@careerbuilder.com>" "Inspector Gadget: $date, $server_count servers, $things_wrong things wrong" $InspectorGadgetFileName}