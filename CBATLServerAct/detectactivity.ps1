$active = get-adcomputer -filter{enabled -eq "true"} -properties pwdlastset |select-object dnshostname,samaccountname,@{n='Lastpwdset';e={[DateTime]::FromFileTime($($_.pwdlastset))}} | ?{$_.lastpwdset -gt ((get-date).adddays(-30))}
$active | foreach{
$server = $_
$islive = test-connection $_.dnshostname -quiet -count 1 
if($islive -eq "True"){
$path = "\\"+$_.dnshostname + "\c$\users\"
$userprofiles = get-childitem $path
$filtered = $userprofiles | ?{$_.lastwritetime -gt ((get-date).adddays(-90))}
#write-host $_.dnshostname $filtered.count
if ($filtered.count -eq 0){
#Write-host -foregroundcolor Red "BAD GUY SERVER HERE >>>>>>>>>>>>>" $_.dnshostname "<<<<<<<<<<<<<<<<<<<<<" 
# $process = get-process -computer $_.dnshostname 
 # $process |foreach{
 
 # $worktime  = $worktime + $_.cpu}

 # $worktime
 # }
 # }
 # }

 $server.dnshostname
 $process = get-process -computername $server.dnshostname
 $process |foreach{
 
 $worktime  = $worktime + $_.cpu}

 Write-host -foregroundcolor "Green" $worktime
 # $a = systeminfo | select-string "system boot time"
 # $a = ($a | out-string).replace("System Boot Time:","")
 # $a= $a.trim()
 # $a = $a.replace(",","")
 # $uptime =(get-date) - [datetime]$a 
 
 $os = Get-WmiObject win32_operatingsystem -computername $server.dnshostname
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $worktime / $uptime.totalhours
   }
   }
   }