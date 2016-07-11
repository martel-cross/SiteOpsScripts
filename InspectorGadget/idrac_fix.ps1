param($list,$email)
$serverlist = @()
$PingableServerList = @()
$scriptDirectory = "\\cbatl\share\scripts\ig\"
$serverListFile = $scriptDirectory + "serverlist.txt"
$serverListFile_Custom = $scriptDirectory + "idrac_custom_async.txt"
$script:servers_offline = ""

if ($list -ne "custom")
{
	[array]$ouArray = $null
	$FileExists = Test-Path $ServerListFile
	if ($FileExists -eq $True) {Clear-Content $ServerListFile}

	##### Utility OUs
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
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


$script:server_count = 0
$date = (get-date).ToString('MM/dd/yyyy')
$datetime = (get-date).ToString('yyyyMMdd.HHmm')
$script:things_wrong = 0
$script:idracinfo_wrong,$script:os_wrong
$script:idracinfo_wrong_count,$script:os_wrong_count

$iDRAC_Fix_Name = "iDRAC_Windows_$datetime.htm"
$tempfile = [system.io.path]::GetTempFileName()
$iDRACFile = $tempfile
$iDRACRealFile = $scriptDirectory + $iDRAC_Fix_Name
New-Item -ItemType file $iDRAC_Fix_name -Force

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
	param($iDRACFile)
	Add-Content $iDRACFile "</body></html>"
}


############################################################
# Sends the emails
############################################################
Function sendEmail
{ 
	param($from,$to,$subject,$iDRACFileName)
	$body = "This report: <a href='http://orca.atl.careerbuilder.com/monitoring/IG/$iDRACFileName'>http://orca.atl.careerbuilder.com/monitoring/IG/$iDRACFileName</a>"
	$body += "<br /><br />"
	$body += "Previous reports: <a href='http://orca.atl.careerbuilder.com/monitoring/IG/'>http://orca.atl.careerbuilder.com/monitoring/IG/</a>"
	$smtp = New-Object System.Net.Mail.SmtpClient "relay.careerbuilder.com"
	$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
	$msg.isBodyhtml = $true
	$smtp.send($msg)
}

############################################################
# Gathers the data for the body of the table for each server
############################################################

#Server hashtable template
$async_Server_Template = @{
	html = ''
	name = ''
	model = ''
	things_wrong = 0
	os_wrong = ''
	os_wrong_count = 0
	iDracInfo_wrong = ''
	iDracInfo_wrong_count = 0
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
			
			Function writeSystemTableHeader
			{
				param($iDRACFile)
				Add-Content $iDRACFile "<tr bgcolor=#CCCCCC>
				<td width='17%' align='center'><strong>Model</strong></td>
				<td width='17%' align='center'><strong>Asset Tag</strong></td>
				<td width='17%' align='center'><strong>OS Version</strong></td>
				</tr>"
			}
			
			Function writeSystemInfo
			{
				param($iDRACFile,$model,$assetTag,$OS)	
				Add-Content $iDRACFile "<tr>"
				if (!$model) {Add-Content $iDRACFile "<td bgcolor='#FF0000' align=center>$model</td>";$async_server.things_wrong++} 
				else {Add-Content $iDRACFile "<td>$model</td>"}
				if (!$assetTag) {Add-Content $iDRACFile "<td bgcolor='#FF0000' align=center>$assetTag</td>";$async_server.things_wrong++} 
				elseif ($model -match "PowerEdge") {Add-Content $iDRACFile "<td><a href='http://www.dell.com/support/troubleshooting/us/en/555/Servicetag/$assetTag#ui-tabs-5'>$assetTag</a></td>"}
				else {Add-Content $iDRACFile "<td>$assetTag</td>"}
				if ((!$OS) -or ($OS -like "*2003*")) {Add-Content $iDRACFile "<td bgcolor='#FF0000' align=center>$OS</td>";$async_server.things_wrong++;$async_server.os_wrong+="<a href='#$server'>$server</a>, ";$async_server.os_wrong_count++} 
				else {Add-Content $iDRACFile "<td>$OS</td>"}
				
				Add-Content $iDRACFile "</tr>"
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
			$os
			
			###############################
			#
			# Since these functions that create html append to
			# a file, I need to create a temp file for each server
			# and then read that.  The HTML functions need to be rewritten.
			#
			###############################
			$async_tempFile = [System.IO.Path]::GetTempFileName()
		
		
			writeSystemTableHeader $async_tempFile
			
			
			$os_wmi = gwmi Win32_OperatingSystem -ComputerName $async_server.name | Select-Object -Property [a-z]*
			$os = $os_wmi.Caption
			$hw1 = gwmi Win32_ComputerSystem -ComputerName $async_server.name | Select-Object -Property [a-z]*
			$hw2 = gwmi Win32_BIOS -ComputerName $async_server.name | Select-Object -Property [a-z]*
			
			$async_server.model = $hw1.model
			
			writeSystemInfo $async_tempFile $hw1.model $hw2.SerialNumber $os
			
			###########
			# iDRAC Fix
				writeDellInfoHeader $async_tempFile
				
				$iDracInfo = invoke-command -computername $async_server.name -scriptblock {omreport chassis remoteaccess} | Foreach-Object {$_ -replace "(?m)^", "<br />"}
				
				writeDellInfo $async_tempFile $iDracInfo
				
				
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
	Add-Content $iDRACFile $jobResults.html
}
##### Write Footer
writeHtmlFooter $iDRACFile

function Insert-Content ($iDRACFile) 
{
	BEGIN {$content = Get-Content $iDRACFile}
	PROCESS {$_ | Set-Content $iDRACFile}
	END {$content | Add-Content $iDRACFile}
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
	
if (($os_wrong) -or ($idracinfo_wrong))
{
	
	$prereport += "<b>Here is a brief list of things that need to be addressed on which servers. If any servers are listed here, please click any of the server names to navigate to that servers information table.</b><br /><br />"
	if($servers_offline){$prereport += "<b><font color='red'>$servers_offline_count </font> Servers were inaccesible during the scan:</b><br />$servers_offline <br /><br />"}
	if($os_wrong){$prereport += "<b><font color='red'>$os_wrong_count </font> Servers with OS older than Windows 2008:</b><br />$os_wrong <br /><br />"}
	if($idracinfo_wrong){$prereport += "<b><font color='red'>$idracinfo_wrong_count </font> Servers unable to get iDRAC information from:</b><br />$idracinfo_wrong <br /><br />"}
}

$header = $writeHtmlHeader + $prereport

$iDRACFile = $header | Insert-Content $iDRACFile

Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$iDRACFileName"
if ($email -eq "cody")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <cody.rucks@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $iDRACFileName}
elseif ($email -eq "patrick")
{sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "Patrick McGahee<patrick.mcgahee@careerbuilder.com>" "Inspector Gadget - Windows: $date, $server_count servers, $things_wrong things wrong" $iDRACFileName}
else {sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <siteservers@careerbuilder.com>" "Inspector Gadget: $date, $server_count servers, $things_wrong things wrong" $iDRACFileName}