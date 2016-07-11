C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c '. \"C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1\" $true'

#Credentials
$cbatlUser = "cbatl\sitesrvc"
$cbatlFile = "C:\cbatlpci\acklog2.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)




#$creds = Get-Credential	
# connect-viserver devvctr1 -credential $cbatlCreds
# connect-viserver chivctr1 -credential $cbatlCreds
# connect-viserver qtwvctr1 -credential $cbatlCreds
# connect-viserver qtmvctr1 -credential $cbatlCreds
# connect-viserver qtxvctr1 -credential $cbatlCreds


get-view -ViewType virtualmachine | select name,@{N='ToolsUpgradePolicy';E={$_.Config.Tools.ToolsUpgradePolicy } }




#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noe -c ". \" " $true"