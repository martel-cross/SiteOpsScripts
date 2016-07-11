$creds = Get-Credential	
connect-viserver devvctr1 -credential $creds
connect-viserver chivctr1 -credential $creds
connect-viserver qtwvctr1 -credential $creds
connect-viserver qtmvctr1 -credential $creds
connect-viserver qtxvctr1 -credential $creds

# $vms = get-vm | ?{$_.vmhost -like "*app0*"} | ?{$_.guestid -like "*Windows*"}
# $vms | select name,numcpu,memorygb | ?{$_.NumCpu -ne 8} | export-csv vmcpustage.csv
# $vms | select name,numcpu,memorygb |?{($_.memoryGB -ne 16)} | export-csv vmmemstage.csv



# $upgtoggle = "UpgradeAtPowerCycle"
#$upgtoggle = "Manual"
# $vms = Get-VM | ?{$_.powerstate -eq "PoweredOn"}
 # $vms | Foreach{
 
# $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
# $spec.changeVersion = $_.ExtensionData.Config.ChangeVersion
# $spec.tools = New-Object VMware.Vim.ToolsConfigInfo
# $spec.tools.toolsUpgradePolicy = $upgtoggle
# $_this = $_ | Get-View 
# If(($_this.guest.toolsstatus -ne "toolsok") -and ($_this.guest.toolsstatus -ne "notoolsinstalled")){
# $_.name

# $_this
 # $_this.ReconfigVM($spec)
# Start-sleep -seconds 10
# }

# }

# $vmtools = Get-VM | Get-View | Select-Object @{N="VMName";E={$_.Name}},@{Name="VMwareTools";E={$_.Guest.ToolsStatus}}
# $vmtools | ?{$_.vmwaretools -like "*toolsNotRunning*"}