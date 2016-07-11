$SecureString = Read-Host -AsSecureString
$EncryptedPW = ConvertFrom-SecureString -SecureString $SecureString
Set-Content -Path "\\qtmmgmt1\C$\cbatlpci\acklog2.txt" -Value $EncryptedPW