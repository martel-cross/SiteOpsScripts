$i =0
while ($i -eq 0)
{$lockout = get-aduser -filter{samaccountname -eq "ayost.site"} | ?{$_.Lockedout -eq "True"}
if ($lockout){
Send-MailMessage -to joel.terry@careerbuilder.com -from logicmonitor@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Account Lockout" -body "LogicMonitor Locked out"
}
Write-host "." -nonewline
start-sleep -seconds 600
}