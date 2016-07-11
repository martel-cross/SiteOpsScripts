
add-pssnapin VMware.VimAutomation.Core

$ErrorActionPreference = "silentlycontinue"
$error.clear()

#Credentials
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "C:\siteopsscripts\cbatlpci\acklog2.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)


#$creds = Get-Credential	

connect-viserver qtmvctr1 -credential $cbatlCreds
$deletedate = (get-date).addhours(-47)
$servers = import-csv servers.csv
foreach($server in $servers){
$snaps = get-vm $server.name | get-snapshot | select *
foreach($snap in $snaps){
if (($snap.name -eq "Daily Snap") -and ($snap.created -le $deletedate)){
get-snapshot -id $snap.id -vm $snap.vm | remove-snapshot -confirm:$false
#Write-host "Snapshot Deleted"
}
}
get-vm $server.name | new-snapshot -name "Daily Snap"
}


$body = get-vm | get-snapshot | select name,created,vm,@{Name= 'SizeGB';Expression={[math]::Round($_.sizeGB,2)}}|?{$_.name -eq "Daily Snap"} | format-table | out-string

Send-MailMessage -to sitebackendalerts@careerbuilder.com -from SBESnapshot@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Rolling Snapshot Report" -body $body
#Send-MailMessage -to joel.terry@careerbuilder.com -from SBESnapshot@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Rolling Snapshot Report" -body $body
#Error reporting************************************************************************
if ($error.count -gt 0){
$body = $error | out-string
Send-MailMessage -to sitebackend@careerbuilder.com -from SBESnapshot@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Snapshot Errors" -body $body}


