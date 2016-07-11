
param 
    (
        [Parameter(Mandatory=$true)][string]$MachineName, # Name of target system
		[Parameter(Mandatory=$true)][string]$addingHours, # Hours of SDT
		[Parameter(Mandatory=$true)][string]$addingDays   # Days of SDT
        
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
$convertdays = get-date
$intdays = [convert]::ToInt32($addingdays, 10)
$convertdays = $convertdays.adddays($intdays)
$day = $convertdays.day
$inthours =[convert]::ToInt32($addinghours, 10)
$converthours = get-date
$converthours = $converthours.addhours($inthours)
$hour = $converthours.hour
$hour
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
$addhostresponse
