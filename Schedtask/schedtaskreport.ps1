
Function getschedtasks
{param($compname,$taskname)

$a = schtasks /query /s $compname /TN $taskname /NH /v /fo csv
if ($a){
$a=$a.replace('"HostName","TaskName","Next Run Time","Status","Logon Mode","Last Run Time","Last Result","Author","Task To Run","Start In","Comment","Scheduled Task State","Idle Time","Power Management","Run As User","Delete Task If Not Rescheduled","Stop Task If Runs X Hours and X Mins","Schedule","Schedule Type","Start Time","Start Date","End Date","Days","Months","Repeat: Every","Repeat: Until: Time","Repeat: Until: Duration","Repeat: Stop If Still Running"','')

add-content stprocessing.csv $a
}

}


clear-content stprocessing.csv
$header = '"HostName","TaskName","Next Run Time","Status","Logon Mode","Last Run Time","Last Result","Author","Task To Run","Start In","Comment","Scheduled Task State","Idle Time","Power Management","Run As User","Delete Task If Not Rescheduled","Stop Task If Runs X Hours and X Mins","Schedule","Schedule Type","Start Time","Start Date","End Date","Days","Months","Repeat: Every","Repeat: Until: Time","Repeat: Until: Duration","Repeat: Stop If Still Running"'
$trheader = "<table style='width:100%'><tr><th>System</th><th>Job</th><th>Status Code</th><th>Start Date</th><th>Next Run</th></tr>"
add-content stprocessing.csv $header
$report =$report +$trheader
$computers = get-adcomputer -filter{enabled -eq 'True'} 
foreach($computer in $computers){
if($computer.distinguishedname -notlike '*linux*'){
$live = test-connection $computer.dnshostname -count 1 -quiet
if($live){
$compname = '\\'+$computer.name
########$a=schtasks /change /s $compname /tn 'GrimReaper' /ru 'SYSTEM'
getschedtasks $compname "Grimreaper"
getschedtasks $compname "Cycle"
}}

}

import-csv stprocessing.csv | foreach{
$task = $_
if (($task.hostname) -and ($task.status -ne 'Disabled') -and ($task.'Last Result' -ne '0')){
$task.hostname = $task.hostname.replace('\','')
$task.taskname = $task.taskname.replace('\','')

$report=$report + '<tr><td style="text-align:center">'+$task.hostname+'</td><td style="text-align:center">'+$task.taskname+'</td><td style="text-align:center">'+$task.'Last Result'+'</td><td style="text-align:center">'+$task.'Last Run Time'+'</td><td style="text-align:center">'+$task.'Next Run Time'+'</td></tr>'

}
}
$report=$report + '</table>'
Send-MailMessage -to platformsoftware@careerbuilder.com,SiteBackEndAlerts@careerbuilder.com,Platformintegrity2@careerbuilder.com -from taskmonitor@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject 'Scheduled Job Exceptions' -bodyashtml -body $report

#Send-MailMessage -to joel.terry@careerbuilder.com -from taskmonitor@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject 'Scheduled Job Exceptions' -bodyashtml -body $report