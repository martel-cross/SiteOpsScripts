$SecureString = Read-Host -AsSecureString
$EncryptedPW = ConvertFrom-SecureString -SecureString $SecureString
Set-Content -Path "c:\temp\acklog2.txt" -Value $EncryptedPW