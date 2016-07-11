
#Store encrypted user and pass for domain credentials
$keyfile="C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\AES.key"
$key= get-content $keyfile
$LMPass = get-content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMPass.txt" | ConvertTo-SecureString -key $key
$LMUser = Get-Content "C:\GitHub\SiteOps-Powershell\Vcommander Scripts\Scripts\LMUser.txt" | ConvertTo-SecureString -key $key

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMUser)
$LMAPIUser = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LMPass)
$LMAPIPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
#Credentials
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "C:\SiteOpsScripts\cbatlpci\acklog2.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)




#$creds = Get-Credential	
connect-viserver devvctr1 -credential $cbatlCreds
connect-viserver chivctr1 -credential $cbatlCreds
connect-viserver qtwvctr1 -credential $cbatlCreds
connect-viserver qtmvctr1 -credential $cbatlCreds
connect-viserver qtxvctr1 -credential $cbatlCreds

#$GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName="

$GetHostURL ="https://careerbuilder.logicmonitor.com/santaba/rpc/getHostGroups?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass"


$GetHostStatus= Invoke-RestMethod $GetHostURL

$groups = $gethoststatus.data
foreach($group in $groups){
$groupid = ($group.id).tostring()
$GetHostURL ="https://careerbuilder.logicmonitor.com/santaba/rpc/getHosts?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&hostGroupId=$groupid"
$Getsystems= Invoke-RestMethod $GetHostURL
$systems = $getsystems.data.hosts
foreach($system in $systems){

(get-vm $system.name).name}
}


#$machines =Get-adcomputer -filter{enabled -eq "True"}
#$machines = get-vm | select *
# $machines = import-csv lmvmlog.csv
# foreach($machine in $Machines){


# $machinename = $machine.name
# $GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$MachineName"
# $GetHostStatus= Invoke-RestMethod $GetHostURL
# $Report = $gethoststatus.errmsg
# if ($report -notlike "*ok*"){
# $machinename = $machinename +".atl.careerbuilder.com"
# $GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$MachineName"
# $GetHostStatus= Invoke-RestMethod $GetHostURL
# $Report = $gethoststatus.errmsg
# }
# $test = test-connection $machine.name -count 1 -quiet
# if ($report -notlike "*ok*"){
# write-host $machinename $report}
# if ((!$test) -and ($gethoststatus.errmsg -eq "OK")){
# $addtofile = $machinename +",Exists - Dead Ping"
# add-content LMvmlog.csv $addtofile
# }
# if (($test) -and ($gethoststatus.errmsg -ne "OK")){
# $addtofile = $machinename +","+$result
# add-content LMVMlog.csv $addtofile
# }
#}