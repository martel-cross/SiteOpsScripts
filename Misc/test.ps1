$ErrorActionPreference = "silentlycontinue"
$error.clear()

#Credentials
$cbatlUser = "cbatl\sitesrvc"
$cbatlFile = "C:\cbatlpci\acklog2.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)


#$creds = Get-Credential	

connect-viserver qtmvctr1 -credential $cbatlCreds