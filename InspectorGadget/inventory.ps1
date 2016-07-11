$script:server_count++
		
Add-Content $InspectorGadgetFile "<table width='100%'><tbody>"
Add-Content $InspectorGadgetFile "<tr bgcolor='#CCCCCC'>"
Add-Content $InspectorGadgetFile "<td width='100%' align='center' colSpan=6><font face='tahoma' color='#003399' size='2'><strong><a name='$server'>$server</a></strong></font><font face='tahoma' color='#003399' size='1'>&nbsp;&nbsp;&nbsp;&nbsp;<a href='#top'>[Top of page]</a></font></td>"
Add-Content $InspectorGadgetFile "</tr>"

#############
# system info
$os,$activation,$TotalRAM = ""
writeSystemTableHeader $InspectorGadgetFile
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
writeSystemInfo $InspectorGadgetFile $hw1.model $hw2.SerialNumber $os $Activation $TotalRAM $proxycfg

###########
# cpu info
$cpu,$sockets,$cores,$arch = "","","",""
writeCPUTableHeader $InspectorGadgetFile
[array]$wmiinfo = Get-WmiObject Win32_Processor -computer $server
$cpu = ($wmiinfo[0].name) -replace ' +', ' '
$cores = $wmiinfo[0].NumberOfCores
$sockets = ( $wmiinfo | Select SocketDesignation -unique | Measure-Object ).count
Switch ($wmiinfo[0].architecture) {
    0 { $arch = "x86" }
    1 { $arch = "MIPS" }
    2 { $arch = "Alpha" }
    3 { $arch = "PowerPC" }
    6 { $arch = "Itanium" }
    9 { $arch = "x64" }
}
writeCPUInfo $InspectorGadgetFile $cpu $sockets $cores $arch

###########
# disk info
writeDiskTableHeader $InspectorGadgetFile
$dp = Get-WmiObject win32_logicaldisk -ComputerName $server | Where-Object {$_.drivetype -eq 3}
foreach ($item in $dp)
{
	writeDiskInfo $InspectorGadgetFile $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size
}

##############
# network info
$IP,$DNS,$dnschk,$ipv6,$MTU,$MTU_value,$MTU_result,$NetBIOS,$dynamic_ports = "","","","","","","","",""
writeNetworkTableHeader $InspectorGadgetFile
#$nw = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*
$ip_wmi = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -Filter IPEnabled=True | Select-Object -Property IPAddress,DefaultIPGateway,IPSubnet
foreach ($objItem in $ip_wmi)
{
	if ([string]$objItem.IPAddress -eq "0.0.0.0") {$IP += ""}
	else {$IP += "IP: " + [string]$objItem.IPAddress + ", GW: " + $objItem.DefaultIPGateway + ", SM: " + $objItem.IPSubnet + "`n"}
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
[array]$MTUarray = $null
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
writeNetworkInfo $InspectorGadgetFile $IP $DNS $MTU $NetBIOS $ipv6 $dynamic_ports

###########
# Misc info
writeMiscTableHeader $InspectorGadgetFile
$XPBY,$ISAPI,$UAC,$httperr,$Members,$remotemgmt = "","","","","",""
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
$InstallDate,$LastBootUpTime,$TimeZone,$Batch,$IIS,$tz_wmi = "","","","","",""
writeTimeDirTableHeader $InspectorGadgetFile
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
{	
	$BatchDirSize = (Get-ChildItem \\$server\c$\batch -recurse | Measure-Object -property length -sum)			
	$BatchDirCount = (Get-ChildItem \\$server\c$\batch -recurse).count
	if (!$BatchDirCount) {$Batch = "Batch directory empty!"} else {$Batch = "Batch dir: $BatchDirCount files totaling {0:N2}" -f ($BatchDirSize.sum / 1MB) + " MB"}
}
else {$Batch = "IIS directory doesn't exist"}
$IISDirExists = Test-Path "\\$server\d$\iislogs"
if ($IISDirExists -eq $True)
{	
	$IISDirItems = (Get-ChildItem \\$server\d$\iislogs -recurse | Measure-Object -property length -sum)
	$IISDirCount = (Get-ChildItem \\$server\d$\iislogs -recurse).count
	if (!$IISDirCount) {$IIS  = "IIS directory empty!"} else {$IIS = "IIS Dir: $IISDirCount files totaling {0:N2}" -f ($IISDirItems.sum / 1GB) + " GB"}
}
else {$IIS = "IIS directory doesn't exist"} 

writeTimeDirInfo $InspectorGadgetFile $LocalDateTime $InstallDate $LastBootUpTime $TimeZone $Batch $IIS
	
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

Write-Host "$server done being checked"

Add-Content $InspectorGadgetFile "<tr><td colSpan=6><br/><br/></td></tr>"
Add-Content $InspectorGadgetFile "</table>"