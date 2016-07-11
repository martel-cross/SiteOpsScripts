#Store encrypted user and pass for domain credentials
$keyfile="C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\AES.key"
$key= get-content $keyfile
$LMPass = get-content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMPass.txt" | ConvertTo-SecureString -key $key
$LMUser = Get-Content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMUser.txt" | ConvertTo-SecureString -key $key

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMUser)
$LMAPIUser = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMPass)
$LMAPIPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)




$GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getRoles?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&createdby=SAML&role=readonly"
$GetHostStatus= Invoke-RestMethod $GetHostURL
$gethoststatus.data

