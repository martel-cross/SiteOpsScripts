# Clear-content regkeys.csv
# $fileheader = "server,tcpwindowsize,tcptimedwaitdelay,maxuserport"
# add-content regkeys.csv $fileheader
$jobresult= @()
$servers = (Get-vm *dpi*).name
foreach($server in $servers){
invoke-command  -computername $server -scriptblock{get-itemproperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\"  } -asjob
invoke-command  -computername $server -scriptblock{get-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\"  } -asjob
# $job = get-job | ?{$_.location -eq $server} |?{$_.hasmoredata -eq "TRUE"}
# $jobresult = (receive-job $job)
# $addtofile = $server+","+$jobresult.tcpwindowsize+","+$jobresult.tcptimedwaitdelay+","+$jobresult.maxuserport
# add-content regkeys.csv $addtofile
}
while((get-job -state "running")){start-sleep 10}
$jobresults  = get-job | receive-job | select *
foreach($jobresult in $Jobresults){
# $addtofile = $jobresult.pscomputername+","+$jobresult.tcpwindowsize+","+$jobresult.tcptimedwaitdelay+","+$jobresult.maxuserport
# add-content regkeys.csv $addtofile
write-host $jobresult.pscomputername $jobresult.noclose
}

