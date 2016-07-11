#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c '. \"C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1\" $true'
add-pssnapin VMware.VimAutomation.Core
#Credentials
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "c:\siteopsscripts\cbatlpci\acklog2.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
#$creds = Get-Credential	
connect-viserver devvctr1 -credential $cbatlCreds
Get-vm | update-tools -noreboot