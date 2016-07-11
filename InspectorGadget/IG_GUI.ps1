# defrag_analysis.ps1
#
# Displays Defrag Analysis Info for a remote server.
#
# Author: tojo2000@tojo2000.com
cls

Set-PSDebug -Strict`

trap [Exception] {
  continue
}
$server = get-content env:computername

function GenerateForm {
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

$form1 = New-Object System.Windows.Forms.Form
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$button1 = New-Object System.Windows.Forms.Button

$handler_button1_Click = {
  	$richTextBox1.Text = ''

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

	#############
	# system info
	$os,$activation,$TotalRAM = ""
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
	$proxy = invoke-command -computername $server -scriptblock {netsh winhttp show proxy}
	if ($proxy -match "no proxy server") {$proxycfg = "Set Correct: No proxy"}
	else {$proxycfg = "Set Wrong: " + $proxy}
	
	###########
	# disk info
	$disks = ""
	$dp = Get-WmiObject win32_logicaldisk -ComputerName $server | Where-Object {$_.drivetype -eq 3}
	foreach ($item in $dp)
	{
		$disks += "$item.DeviceID :: $item.VolumeName :: $item.FreeSpace :: $item.Size"
	}
	
	##############
	# network info
	$IP,$DNS,$dnschk,$ipv6,$MTU,$NetBIOS,$dynamic_ports = ""
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
	
	###########
	# Misc info
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
	$apphostcfgfile = "\\$server\C$\Windows\System32\inetsrv\config\applicationHost.config"
	$XPBYExists = Test-Path "\\$server\d$\iislogs"
	if ($XPBYExists -eq $True)
	{$XPBY = (Select-String $apphostcfgfile -pattern "X-PBY" | Select -ExpandProperty Line) -replace '<','' -replace '>','' -replace '/','' -replace '                ',''}
	$ISAPIExists = Test-Path "\\$server\d$\iislogs"
	if ($ISAPIExists -eq $True)
	{$ISAPI = (Select-String $apphostcfgfile -pattern "rllog.dll" | Select -ExpandProperty Line) -replace '<','' -replace '>','' -replace '/','' -replace '            ',''}
	
	###########
	# Time and directory info
	$InstallDate,$LastBootUpTime,$TimeZone,$Batch,$IIS = ""
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
		
	############
	# Scheduled tasks
	$schedtasks = ""
	$schedule = new-object -com("Schedule.Service")
	$schedule.connect($server)
	$tasks = $schedule.getfolder("\").gettasks(0)
	$tasks = $tasks | select Name, Enabled, LastRunTime, NextRunTime
	foreach ($task in $tasks) {$schedtasks += "$task<br/>"}

	Write-TextBox "Model: $hw1.model"
	Write-TextBox "Serial Number: $hw2.SerialNumber"
	Write-TextBox "OS Version: $os"
	Write-TextBox "Activation Status: $Activation"
	Write-TextBox $disks
	Write-TextBox "RAM: $TotalRAM"
	Write-TextBox "IPs: $IP"
	Write-TextBox "DNS Servers: $DNS"
	Write-TextBox "MTU: $MTU"
	Write-TextBox "NetBIOS: $NetBIOS"
	Write-TextBox "IPv6: $ipv6"
	Write-TextBox "DynamicTCPports: $dynamic_ports"
	Write-TextBox "Local admins: $Members"
	Write-TextBox "HTTPERR: $httperr"
	Write-TextBox "Remote mgmt: $remotemgmt"
	Write-TextBox "UAC Seeting: $UAC"
	Write-TextBox "X-PBY setting: $XPBY" 
	Write-TextBox "ISAPI Filter: $ISAPI"  
	Write-TextBox "Current time: $LocalDateTime"
	Write-TextBox "Install date: $InstallDate"
	Write-TextBox "Last bootup time: $LastBootUpTime"
	Write-TextBox "Time Zone: $TimeZone"
	Write-TextBox "Batch Directory: $Batch" 
	Write-TextBox "IIS Directory: $IIS"
	Write-TextBox "Scheduled Tasks: $schedtasks"
 	Write-TextBox "----------------------------"
}

#$handler_form1_Load = {
# $textBox1.Select()
#}

$form1.Name = 'form1'
$form1.Text = 'Inspector Gadget Self Checker'
$form1.BackColor = [System.Drawing.Color]::FromArgb(255,227,227,227)
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 800
$System_Drawing_Size.Height = 700
$form1.ClientSize = $System_Drawing_Size

$richTextBox1.Text = ''
$richTextBox1.TabIndex = 2
$richTextBox1.Name = 'richTextBox1'
$richTextBox1.Font = New-Object System.Drawing.Font("Courier New",10,0,3,0)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 750
$System_Drawing_Size.Height = 550
$richTextBox1.Size = $System_Drawing_Size
$richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 25
$System_Drawing_Point.Y = 75
$richTextBox1.Location = $System_Drawing_Point

$form1.Controls.Add($richTextBox1)

$button1.UseVisualStyleBackColor = $True
$button1.Text = 'Analyze'
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.TabIndex = 0
$button1.Name = 'button1'
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 100
$System_Drawing_Size.Height = 40
$button1.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 165
$System_Drawing_Point.Y = 10
$button1.Location = $System_Drawing_Point
$button1.add_Click($handler_button1_Click)

$form1.Controls.Add($button1)

$form1.ShowDialog()| Out-Null

}

function Write-TextBox {
  param([string]$text)
  $richTextBox1.Text += "$text`n"
}

# Launch the form
GenerateForm