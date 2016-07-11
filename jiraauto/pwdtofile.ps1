$Secure = get-credential
$securestring = $secure.password
$EncryptedPW = ConvertFrom-SecureString -SecureString $SecureString
Set-Content -Path "C:\siteopsscripts\jiraauto\jira.txt" -Value $EncryptedPW