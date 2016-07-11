
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c '. \"C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1\" $true'

#Credentials
$cbatlUser = "cbatl\sitesrvc"
$cbatlFile = "C:\cbatlpci\acklog2.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)




#$creds = Get-Credential	
connect-viserver devvctr1 -credential $cbatlCreds
connect-viserver chivctr1 -credential $cbatlCreds
connect-viserver qtwvctr1 -credential $cbatlCreds
connect-viserver qtmvctr1 -credential $cbatlCreds
connect-viserver qtxvctr1 -credential $cbatlCreds



#$upgtoggle = "UpgradeAtPowerCycle"
$upgtoggle = "Manual"
$vms = Get-VM | ?{$_.powerstate -eq "PoweredOn"}
 $vms | Foreach{
 
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.changeVersion = $_.ExtensionData.Config.ChangeVersion
$spec.tools = New-Object VMware.Vim.ToolsConfigInfo
$spec.tools.toolsUpgradePolicy = $upgtoggle
$_this = $_ | Get-View 
If(($_this.guest.toolsstatus -eq "toolsok")){

 $_this.ReconfigVM($spec)
#Start-sleep -seconds 10
}

}

#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noe -c ". \" " $true"