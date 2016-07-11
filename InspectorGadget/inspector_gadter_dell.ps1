param($list)
$serverlist = @()
$IGDirectory = "D:\Share\scripts\IG\"
$ServerListFile = $IGDirectory + "serverlist_dell.txt"
$script:servers_offline = ""

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
	#$ouArray += $([ADSI]"LDAP://OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=WEB,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=MT,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=WEB,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	#$ouArray += $([ADSI]"LDAP://OU=MT,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
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
		$serverstatus = ('select statuscode from win32_pingstatus where address="' + $strComputer + '"')
		$result = gwmi –query "$serverstatus"
		if ($result.StatusCode -ne 0) {$script:servers_offline+="$strComputer, "}
		else {Add-Content $ServerListFile -value $strComputer}
	}
}

$serverlist = $ServerListFile

$date = (get-date).ToString('MM/dd/yyyy')
$datetime = (get-date).ToString('MMddyyyy.HHmm')
$script:things_wrong = 0
$script:server_count = 0
$InspectorGadgetDellFileName = "InspectorGadget_Dell_$datetime.htm"
$tempfile = [system.io.path]::GetTempFileName()
$InspectorGadgetDellFile = $tempfile
$InspectorGadgetDellRealFile = $IGDellDirectory + $InspectorGadgetDellFileName
New-Item -ItemType file $InspectorGadgetDellFile -Force

############################################################
# Sends the emails
Function sendEmail
{ 
	param($from,$to,$subject,$InspectorGadgetDellFileName)
	$body = "This report: http://orca.atl.careerbuilder.com/monitoring/IG/$InspectorGadgetDellFileName"
	$body += "<br /><br />"
	$body += "Previous reports: http://orca.atl.careerbuilder.com/monitoring/IG/"
	$smtp = New-Object System.Net.Mail.SmtpClient "relay.careerbuilder.com"
	$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
	$msg.isBodyhtml = $true
	$smtp.send($msg)
}
function Get-DellWarranty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [alias("serialnumber")]
        [string[]]$ServiceTag
    )

    PROCESS {
    
        # If nothing was passed, retrieve the local system service tag
        if ($ServiceTag -eq $null) {
            write-verbose "No Service Tags provided. Using Local Computer's Service Tag"
            write-verbose "START Obtaining Serial number via WMI for localhost"
            $ServiceTag = (get-wmiobject win32_bios).SerialNumber
            write-verbose "SUCCESS Obtaining Serial number via WMI for localhost - $ServiceTag"
        }
        
        # Detect if an array of service tags were passed via parameter and unwind them.
        foreach ($strServicetag in $servicetag) {
                write-verbose "START Querying Dell for Service Tag $_"
                Get-DellWarrantyWorker $strServicetag
                write-verbose "SUCCESS Querying Dell for Service Tag $_"
        }
    }

}

Function Get-DellWarrantyWorker {
  Param(
    [String]$serviceTag
  )
  #Dell Warranty URL Path
  $URL = "http://support.dell.com/support/topics/global.aspx/support/my_systems_info/details?c=us&l=en&s=gen&ServiceTag=$serviceTag"
  
  trap [System.FormatException] { 
    write-error -category invalidresult "The service tag $serviceTag was not found. This is either because you entered the tag incorrectly, it is not present in Dell's database, or Dell changed the format of their website causing this search to fail." -recommendedaction "Please check that you entered the service tag correctly"
    return;
  }
  
  #Screenscrape the HTML for the warranty Table
  $HTML = (New-Object Net.WebClient).DownloadString($URL)
  If ($HTML -Match '<table[\w\s\d"=%]*contract_table">.+?</table>') {
    $htmltable = $Matches[0]
  } else {
    throw (New-Object System.FormatException)
  }
  $HtmlLines = $htmltable -Split "<tr" | Where-Object { $_ -Match '<td' }
  $Header = ($HtmlLines[0] -Split '<td') -Replace '[\w\s\d"=%:;\-]*>|</.*' | Where-Object { $_ -ne '' }
  
  #Convert the warranty table fields into a powershell object
  For ($i = 1; $i -lt $HtmlLines.Count; $i++) {
    $Output = New-Object PSObject
    $Output | Add-Member NoteProperty "Service Tag" -value $serviceTag
    $Values = ($HtmlLines[$i] -Split '<td') -Replace '[\w\s\d"=%:;\-]*>|</.*|<a.+?>'
    For ($j = 1; $j -lt $Values.Count; $j++) {
      $Output | Add-Member NoteProperty $Header[$j - 1] -Value $Values[$j]
    }
    
    #Minor formatting fix if days remaining on warranty is zero
    if ($output.'Days Left' -match '<<0') {write-host -fore darkgreen "match!";$output.'Days Left' = 0}
    
    return $Output
  }
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

foreach ($server in Get-Content $serverlist)
{
	$hw1 = gwmi Win32_ComputerSystem -ComputerName $server | Select-Object -Property model
	$BIOS = invoke-command -computername $server -scriptblock {omreport chassis biossetup}
	$Firmware = invoke-command -computername $server -scriptblock {omreport system version}
	Set-Content -Path "c:\bios.txt" -Value $BIOS
	Set-Content -Path "c:\Versions.txt" -Value $Firmware

	if ($hw1.model -match "R610")
	{
		$cstate,$NodeInter,$hypert,$virttech,$turbomode = ""
		$bios_vs,$perc_vs = ""
		## BIOS SETTINGS ##
		$cstate = get-content "c:\bios.txt" | %{if($outputnext){$_};$outputnext=($_ -match "Processor C State Control")}
		if ($cstate -notmatch "Disabled") {$cstate = "C-State $cstate (Wrong!)"} else {$cstate = "C-State $cstate"}
		$NodeInter = get-content "c:\bios.txt" | %{if($outputnext){$_};$outputnext=($_ -match "Node Interleaving")}
		if ($NodeInter -notmatch "Enabled") {$NodeInter = "Node Interleaving $NodeInter (Wrong!)"} else {$NodeInter = "Node Interleaving $NodeInter"}
		$hypert = get-content "c:\bios.txt" | %{if($outputnext){$_};$outputnext=($_ -match "Processor Logical Processor")}
		if ($hypert -notmatch "Disabled") {$hypert = "Hyperthreading $hypert (Wrong!)"} else {$hypert = "Hyperthreading $hypert"}
		$virttech = get-content "c:\bios.txt" | %{if($outputnext){$_};$outputnext=($_ -match "Processor Virtualization Technology")}
		if ($virttech -notmatch "Disabled") {$virttech = "Virtualization Technology $virttech (Wrong!)"} else {$virttech = "Virtualization Technology $virttech"}
		$turbomode = get-content "c:\bios.txt" | %{if($outputnext){$_};$outputnext=($_ -match "Processor Core Based Turbo Mode")}
		if ($turbomode -notmatch "Disabled") {$turbomode = "Turbo Mode $turbomode (Wrong!)"} else {$turbomode = "Turbo Mode $turbomode"}
		## FIRMWARE ##
		$bios_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "BIOS"))}
		if ($bios_vs -notmatch "3.0.0") {$bios_vs = "BIOS version: $bios_vs (Older!)"} else {$bios_vs = "BIOS Version $bios_vs"}		
		$perc_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "PERC"))}
		if (($perc_vs -notmatch "5.2.2-0072") -or ($perc_vs -notmatch "6.2.0-0013")) {$perc_vs = "PERC $perc_vs (Older!)"} else {$perc_vs = "PERC $perc_vs"}
		$idrac_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "iDRAC"))}
		if ($idrac_vs -notmatch "1.70") {$idrac_vs = "iDRAC $idrac_vs (Older!)"} else {$idrac_vs = "iDRAC $perc_vs"}
		$omsa_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "Dell Server Administrator"))}
		if ($omsa_vs -notmatch "6.4") {$omsa_vs = "OMSA $omsa_vs (Older!)"} else {$omsa_vs = "BMC $omsa_vs"}
		## OUTPUT ## 
		add-content $InspectorGadgetDellFile "<table width='100%' border='1'>
		<tr><td colspan='2'>$server - $hw1</td></tr>
		<tr><td width='40%'>
		$cstate<br/>
		$NodeInter<br/>
		$hypert<br/>
		$virttech<br/>
		$turbomode<br/>
		</td>
		<td width='60%'>
		$bios_vs<br />
		$perc_vs<br />
		$idrac_vs<br />
		$omsa_vs<br />
		</td></tr>
		</table>"
		
	}
	elseif ($hw1.model -match "1950") 
	{
		## BIOS SETTINGS ##
		$virttech = ""
		$bios_vs,$perc_vs = ""
		$virttech = get-content "c:\bios.txt" | %{if($outputnext){$_};$outputnext=($_ -match "CPU Virtualization Technology")}
		if ($virttech -notmatch "Disabled") {$virttech = "Virtualization Technology $virttech (Wrong!)"} else {$virttech = "Virtualization Technology $virttech"}
		## FIRMWARE ##
		$bios_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "BIOS"))}
		if ($bios_vs -notmatch "2.7.0") {$bios_vs = "BIOS $bios_vs (Older!)"} else {$bios_vs = "BIOS $bios_vs"}
		$perc_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "PERC"))}
		if ($perc_vs -notmatch "5.2.2-0072") {$perc_vs = "PERC $perc_vs (Older!)"} else {$perc_vs = "PERC $perc_vs"}
		$bmc_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "BMC"))}
		if ($bmc_vs -notmatch "2.37") {$bmc_vs = "BMC $bmc_vs (Older!)"} else {$perc_vs = "BMC $bmc_vs"}
		$omsa_vs = get-content "c:\Versions.txt" | %{if($outputnext){$_};$outputnext=(($_ -match "Name") -and ($_ -match "Dell Server Administrator"))}
		if ($omsa_vs -notmatch "6.4") {$omsa_vs = "OMSA $omsa_vs (Older!)"} else {$omsa_vs = "BMC $omsa_vs"}
		## OUTPUT ##
		add-content $InspectorGadgetDellFile "<table width='100%' border='1'>
		<tr><td colspan='2'>$server - $hw1</td></tr>
		<tr><td width='40%'>
		$virttech
		</td>
		<td width='60%'>
		$bios_vs<br />
		$perc_vs<br />
		$bmc_vs<br />
		$omsa_vs<br />
		</td></tr>
		</table>"
	}
	Get-DellWarranty
}

Copy-Item -Path $tempfile -Destination "\\orca.atl.careerbuilder.com\d$\WebSites\Monitoring\IG\$InspectorGadgetDellFileName"
sendEmail "Inspector Gadget <InspectorGadget@careerbuilder.com>" "SiteServers <kirk.jantzer@careerbuilder.com>" "Inspector Gadget Dell" $InspectorGadgetDellFileName
