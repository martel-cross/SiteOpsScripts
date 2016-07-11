Function SET-SDT
{param 
    (
        [Parameter(Mandatory=$true)][string]$MachineName # Name of target system
     
    ) 
	# $machinename = "Bearad1"
	# $addinghours = "1"
	# $addingdays = "1"

	
	
	#Store encrypted user and pass for domain credentials
$keyfile="C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\AES.key"
$key= get-content $keyfile
$LMPass = get-content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMPass.txt" | ConvertTo-SecureString -key $key
$LMUser = Get-Content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMUser.txt" | ConvertTo-SecureString -key $key

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMUser)
$LMAPIUser = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMPass)
$LMAPIPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

	
$start = get-date 
# set ending time variables
$year = $start.year
# convert month to weirdo logicmonitor counting month
$month = ($start.month) 
$month =  [convert]::ToInt32($month, 10)
$month = $month - 1
$day = $start.day
$converthours = get-date
$converthours = $converthours.addhours(1)
$hour = $converthours.hour

$minute = $start.minute

# set Starting time variables
$syear = $start.year
$smonth = $month
$sday = $start.day
$shour = $start.hour
$sminute = $start.minute


# send request to logicmonitor
$GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/setHostSDT?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&host=$machinename&id=0&type=1&year=$sYear&month=$sMonth&day=$sDay&hour=$sHour&minute=$sMinute&endYear=$Year&endMonth=$Month&endDay=$Day&endHour=$Hour&endMinute=$Minute"
$AddHostResponse = Invoke-restmethod $GetHostURL
#$addhostresponse
}


$vcenter = "luigivctr1"
$vhosts = get-vmhost -server $vcenter 
$baselines = get-baseline -server $vcenter -baselinetype Patch
foreach($vhost in $vhosts){

write-host $vhost.name -nonewline
if ($vhost.connectionstate -eq "connected"){
$sdtname = ($vhost.name).trim("atl.careerbuilder.com")
set-sdt $sdtname
Write-host " Waiting for Completion..." 
#scan-inventory -entity $vhost
remediate-inventory -baseline $baselines -entity $vhost -hostpreremediationpoweraction DoNotChangeVMsPowerState -Clusterdisablehighavailability $True -confirm:$false 
$status = ''
while ($status -ne "connected")
{$status = (get-vmhost $vhost.name).connectionstate
start-sleep -seconds 30
}
}else {write-host " Skipping - Host Not Ready"}
}