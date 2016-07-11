
Function SetRole
{Param($LMAPIUSER,$LMAPIPass,$userid,$accounttoupdate,$roleid,$emailaddress)

$roleurl = "https://careerbuilder.logicmonitor.com/santaba/rpc/updateAccount?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&id=$userId&username=$accountToUpdate&roles=$roleid&status=active&contactMethod=email&email=$emailaddress&viewPermission=%7B%22Dashboards%22%3Atrue%2C%22Hosts%22%3Atrue%2C%22Services%22%3Atrue%2C%22Alerts%22%3Atrue%2C%22Reports%22%3Atrue%2C%22Settings%22%3Atrue%7D"
$setrole = Invoke-RestMethod $roleurl
$userid
$setrole
}

#Store encrypted user and pass for domain credentials
$keyfile="C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\AES.key"
$key= get-content $keyfile
$LMPass = get-content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMPass.txt" | ConvertTo-SecureString -key $key
$LMUser = Get-Content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMUser.txt" | ConvertTo-SecureString -key $key

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMUser)
$LMAPIUser = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMPass)
$LMAPIPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)




$GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getAccounts?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&createdby=SAML&role=readonly"
$GetHostStatus= Invoke-RestMethod $GetHostURL
$users =$gethoststatus.data
foreach($user in $users){
$roleid = ""
$emailaddress = $user.username
$accounttoupdate = $user.username
$roles = $user.roles
$userid =$user.id
foreach($role in $roles){

if ($role.name -like "*readonly*"){

$aduser = get-aduser -filter{mail -eq $emailaddress} -properties memberof
$adgroups = $aduser.memberof
foreach($adgroup in $adgroups){
if ($adgroup -like "*Teamcorpapps*"){$roleid = "26"}
if ($adgroup -like "*siteSearch*"){$roleid = "22"}
if ($adgroup -like "*SitePlatformIntegrity*"){$roleid = "21"}
if ($adgroup -like "*SitePlatformSoftware*"){$roleid = "13"}
if ($adgroup -like "*TeamBigData*"){$roleid = "25"}
if ($adgroup -like "*SiteDB*"){$roleid = "20"}
if ($adgroup -like "*siteJobDistribution*"){$roleid = "17"}
}
}

}
if ($roleid -ne ""){setrole $LMAPIUSER $LMAPIPass $userid $accounttoupdate $roleid $emailaddress}
}