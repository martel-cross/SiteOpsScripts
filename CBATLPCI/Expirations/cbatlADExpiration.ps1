#This script pulls an AD report to send out to sitebackend.
function activeemployee
{param($activeuser,$datestamp)
if (($activeuser.info -like "*PCI Compliance Warning*")){

#disable user and report update*******************************
$noteupdate = "PCI Compliance Disabled " + $datestamp
$emaildate = $activeuser.info |select-string "PCI Compliance Warning"
set-aduser $activeuser -replace @{info=$noteupdate}
set-aduser $activeuser.distinguishedname -enabled $false
move-adobject $activeuser.distinguishedname -targetpath "OU=Inactive Accounts,DC=atl,DC=careerbuilder,DC=com"
$addtofileau= $activeuser.name+","+ $activeuser.samaccountname +","+ $activeuser.distinguishedname+","+  $activeuser.whencreated+","+  $activeuser.lastlogondate+","+  $activeuser.lastlogontimestamp +",Sent "+$emaildate+" - User Disabled"
$addtofileau=$addtofileau.replace("12/31/1600 19:00:00","")
} else {
$noteupdate = "PCI Compliance Warning " + $datestamp
$emailnote = ('sent email ' +($noteupdate | out-string).trim()+' - Tagged Account for Follow-up').replace(",","")
set-aduser $activeuser.distinguishedname -add @{info=$noteupdate}
if (!$activeuser.mail){$sentomail = ($activeuser.name.tostring()).replace(" ",".") + "@careerbuilder.com"} else {$sentomail =$activeuser.mail}

$warningbody = $activeuser.name+" has not logged into the CBATL domain in 60+ days.  Per CBs operating policy, at 90 days since last login; the account will be disabled.  If you wish to keep your account active, please login soon to reset your last-login date.

If you need to reset your password, please use password.careerbuilder.com

If this account, "+ $activeuser.samaccountname+", is not your account, Or you have problems with the account, Please contact us immediately. Siteopssupport@careerbuilder.com " 
$emailto = "Siteopssupport@careerbuilder.com," + $sentomail
Send-MailMessage -to $sentomail -cc sitebackend@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "Site (CBATL) Account Unused for 60+ Days" -body $warningbody 
$addtofileau= $activeuser.name+','+ $activeuser.samaccountname+',"'+ $activeuser.distinguishedname+'",'+  $activeuser.whencreated+','+  $activeuser.lastlogondate+','+  $activeuser.lastlogontimestamp +","+$emailnote
$addtofileau=$addtofileau.replace("12/31/1600 19:00:00","") 
}
add-content $actionsreportname $addtofileau

}

function getusers180
{param($180date,$cbatlcreds,$reportname,$filenamedate)

#Pull enabled users with LastLogonDate and LastLogonTimeStamp (Interactive Logons) and convert lastlogontimestamp to a usable date and time
$usersdeletionfiltered = get-aduser -filter {(Enabled -eq $false) -and (samaccountname -like "*.site*") -and ((lastlogondate -le $180date) -or (LastLogonTimeStamp -le $180date))} -properties info,LastLogonDate,LastLogonTimeStamp,whencreated -server atl.careerbuilder.com -credential $cbatlcreds | ?{$_.distinguishedname -like "*inactive accounts*"} | select-object info,samaccountname,DistinguishedName,Name,whencreated,LastLogondate,@{n='LastLogonTimeStamp';e={[DateTime]::FromFileTime($($_.LastLogonTimeStamp))}}

#initial Report filters
$Over180SinceLastLogin=$usersdeletionfiltered | ?{$_.lastlogondate -le $180date -or $_.LastLogonTimeStamp -le $180date -and $_.LastLogonTimeStamp -notlike "*12/31/1600*"} 

#initial Export to CSV files for email
($Over180SinceLastLogin | select-object samaccountname,DistinguishedName,Name,whencreated,LastLogondate,lastlogontimestamp).replace("12/31/1600 19:00:00","") | Export-CSV $i180reportname -notype

$usersdeletionfiltered
}
function getusers60
{param($60date,$cbatlcreds,$reportname,$reportnameNLI,$newuserstamp,$filenamedate)

#Pull enabled users with LastLogonDate and LastLogonTimeStamp (Interactive Logons) and convert lastlogontimestamp to a usable date and time
$users=get-aduser -filter {Enabled -eq $true} -properties info,LastLogonDate,LastLogonTimeStamp,whencreated,mail -server atl.careerbuilder.com -credential $cbatlcreds | where-object {$_.samaccountname -like "*.site*"} 
$usersTimeStamp=$users | select-object mail,info,samaccountname,DistinguishedName,Name,whencreated,LastLogondate,@{n='LastLogonTimeStamp';e={[DateTime]::FromFileTime($($_.LastLogonTimeStamp))}}
$usersdisablefiltered = $usersTimeStamp | ?{($_.lastlogondate -le $60date) -or ($_.LastLogonTimeStamp -le $60date)}

#initial Report filters
$Over90SinceLastLogin=$usersTimeStamp | ?{$_.lastlogondate -le $60date.adddays(-30) -or $_.LastLogonTimeStamp -le $60date.adddays(-30) -and $_.LastLogonTimeStamp -notlike "*12/31/1600*"} 
$Neverloggedin=$usersTimeStamp | ?{($_.LastlogonTimeStamp -like "*12/31/1600*") -and ($_.whencreated -le $newuserstamp)}

#initial Export to CSV files for email
($Over90SinceLastLogin | select-object samaccountname,DistinguishedName,Name,whencreated,LastLogondate,lastlogontimestamp).replace("12/31/1600 19:00:00","") | Export-CSV $i90reportname -notype
($Neverloggedin | select-object samaccountname,DistinguishedName,Name,whencreated,LastLogondate,lastlogontimestamp).replace("12/31/1600 19:00:00","") | Export-CSV $invrreportname -notype

$usersdisablefiltered
}

Function Reportsetup
{param($reportname,$filenamedate)

$filenamegen = $reportname+$filenamedate+".csv"
#Clear-content $filenamegen
$fileheader = "Careerbuilder "+ $reportname + " Inactive Account Report for CBATL Domain (Site) " +$filenamedate
$columnheader = "Name,Sam Account Name,Distinguished Name,When Created,Last Logon Date,Last Logon Timestamp,Action Taken"
add-content $filenamegen $fileheader
add-content $filenamegen $columnheader
$filenamegen
}
$ErrorActionPreference = "silentlycontinue"
$error.clear()
import-module activedirectory
$cbatlUser = "cbatl\besvc"
$cbatlFile = "C:\CBATLPCI\acklog3.txt"
$cbUser = "cb\jterry"
$cbFile = "C:\SiteOpsScripts\CBATLPCI\acklog.txt"
$cbatlCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
$cbCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(Get-Content $cbFile | ConvertTo-SecureString)

#Set the date and time limits and Filenames 
$date = get-date
$disabledate=$date.adddays(-60)
$deletiondate =$date.adddays(-180)
$newuserdate = $date.adddays(-30)
$subjectdate = get-date -f Y 
$reportdate = $subjectdate.replace(",","")
$reportdate = $reportdate.replace(" ","")

#Report name and file setup
$i90reportname = reportsetup "Initial90dayidle" $reportdate
$p90reportname = reportsetup "post90dayidle" $reportdate
$i180reportname = reportsetup "Initial180dayidle" $reportdate
$p180reportname = reportsetup "post180dayidle" $reportdate
$invrreportname = reportsetup "InitialNvrlogin" $reportdate
$pnvrreportname = reportsetup "PostNvrlogin" $reportdate
$actionsreportname = reportsetup "Actionsonaccounts" $reportdate

#PDF Filenames
$i90reportnamepdf = $i90reportname.replace("csv","pdf")
$p90reportnamepdf = $p90reportname.replace("csv","pdf")
$i180reportnamepdf = $i180reportname.replace("csv","pdf")
$p180reportnamepdf = $p180reportname.replace("csv","pdf")
$invrreportnamepdf = $invrreportname.replace("csv","pdf")
$pnvrreportnamepdf = $pnvrreportname.replace("csv","pdf")
$actionsreportnamepdf = $actionsreportname.replace("csv","pdf")

#Process accounts 180 days idle
$usersdeletionfiltered = getusers180 $deletiondate $cbatlcreds $p180reportname $subjectdate
$usersdeletionfiltered | foreach{
$deletionuser = $_
remove-aduser $_.distinguishedname -confirm:$false
$addtofile1= $deletionuser.name+','+$deletionuser.samaccountname+',"'+$deletionuser.distinguishedname+'",'+$deletionuser.whencreated+','+$deletionuser.lastlogondate+','+$deletionuser.lastlogontimestamp+',180 Day Inactive -Account Deleted'
$addtofile1=$addtofile1.replace("12/31/1600 19:00:00","")
add-content $actionsreportname $addtofile1
$actionbody = ''
}

#Process accounts 60-90 days idle
$usersdisablefiltered = getusers60 $disabledate $cbatlcreds $i90reportname $invrreportname $newuserdate $subjectdate
$usersdisablefiltered | foreach{
$user = $_

#Check cb.careerbuilder.com domain to determine if employee is still active
$cbsaquery = ($user.samaccountname).replace(".site","")
$cbchk = get-aduser -filter {(enabled -eq "True") -and (samaccountname -eq $cbsaquery)} -server cb.careerbuilder.com -credential $cbcreds

If (($cbchk)){
#process account to send email to employee, tag for later processing or disable if already tagged
if ($user.whencreated -le $newuserdate){activeemployee $user $reportdate}

}else { 
#Disable account if employee is not active and at 90 days or over.
if ($user.lastlogontimestamp  -le $disabledate.adddays(-30)){
set-aduser $user.distinguishedname -enabled $false
move-adobject $user.distinguishedname -targetpath "OU=Inactive Accounts,DC=atl,DC=careerbuilder,DC=com" -confirm:$false
$addtofile2= $user.name+','+  $user.samaccountname+',"'+  $user.distinguishedname+'",'+  $user.whencreated+','+  $user.lastlogondate+','+  $user.lastlogontimestamp +','+ '90 Day Inactive - Disabled Account'
$addtofile2=$addtofile2.replace("12/31/1600 19:00:00","")
#$actionbody= "<tr><td>"+$user.name+"</td><td>"+$user.samaccountname+"</td><td>"+$user.distinguishedname+"</td><td>"+$user.whencreated+"</td><td>"+ $user.lastlogondate+"</td><td>"+$user.lastlogontimestamp +"</td><td>+90 Day Inactive - Disabled Account</td></tr>"
}
add-content $actionsreportname $addtofile2
}

$actionbody = ''
}

#clear-compliance flag on AD Account info attribute
$clearflag = $userstimestamp | ?{($_.info -like "*PCI Compliance*") -and ($_.lastlogondate -gt $date -or $_.LastLogonTimeStamp -gt $date)}
$clearflag | foreach{
set-aduser $_.samaccountname -replace @{info=""}
}
#Generate Post action reports
$usersdisablefiltered = getusers60 $disabledate $cbatlcreds $p90reportname $pnvrreportname $newuserdate $subjectdate
$usersdeletionfiltered = getusers180 $deletiondate $cbatlcreds $p180reportname $subjectdate

#Create body for email.
$body=Write-Output "This is an email from the AD powershell script.  In this message you will find 3 types reports, Initial, actions taken, and post actions, attached detailing unused accounts from the CBATL AD domain."
$newbody=$body | out-string

#convert csv reports to pdf
$path = "C:\SiteOpsScripts\CBATLPCI\Expirations" 
$xlFixedFormat = "Microsoft.Office.Interop.Excel.xlFixedFormatType" -as [type] 
$excelFiles = Get-ChildItem -Path $path -include *.csv -recurse 
 $objExcel = New-Object -ComObject excel.application 
$objExcel.visible = $false
foreach($wb in $excelFiles) 
{ 
 $filepath = Join-Path -Path $path -ChildPath ($wb.BaseName + ".pdf") 
 $workbook = $objExcel.workbooks.open($wb.fullname, 3) 
 $workbook.ActiveSheet.Cells.Font.Size = 4
 $Workbook.ActiveSheet.PageSetup.Orientation = 2
 $Workbook.ActiveSheet.PageSetup.FitToPagesWide = 1
 $Workbook.ActiveSheet.PageSetup.FitToPagesTall = 1
 $workbook.ActiveSheet.ListObjects.add(1,$workbook.ActiveSheet.UsedRange,0,1)
 $workbook.ActiveSheet.Cells.HorizontalAlignment = -4108 
 $workbook.ActiveSheet.UsedRange.EntireColumn.AutoFit()
 $workbook.Saved = $true 
 $workbook.ExportAsFixedFormat($xlFixedFormat::xlTypePDF, $filepath) 
$objExcel.Workbooks.close() 
} 
$objExcel.Quit() 
get-process "excel" | stop-process
start-sleep -seconds 60
#Send mail message reports through internal relay server csv and PDF Reports
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD 90 Day Unused Accounts Report for $subjectdate - PCI Req. 8.5.5 Compliance" -body $newbody -Attachments $i90reportname,$actionsreportname,$p90reportname,$i90reportnamepdf,$actionsreportnamepdf,$p90reportnamepdf
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD 180 Day Unused Accounts Report for $subjectdate - PCI Req. 8.5.5 Compliance" -body $newbody -Attachments $i180reportname,$actionsreportname,$p180reportname,$i180reportnamepdf,$actionsreportnamepdf,$p180reportnamepdf
Send-MailMessage -to siteopssupport@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD Never Logged In Unused Accounts Report for $subjectdate - PCI Req. 8.5.5 Compliance" -body $newbody -Attachments $invrreportname,$actionsreportname,$pnvrreportname,$invrreportnamepdf,$actionsreportnamepdf,$pnvrreportnamepdf

#Send mail message reports through internal relay server csv Reports only
# Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD 90 Day Unused Accounts Report for $subjectdate - PCI Req. 8.5.5 Compliance" -body $newbody -Attachments $i90reportname,$actionsreportname,$p90reportname
# Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD 180 Day Unused Accounts Report for $subjectdate - PCI Req. 8.5.5 Compliance" -body $newbody -Attachments $i180reportname,$actionsreportname,$p180reportname
# Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD Never Logged In Unused Accounts Report for $subjectdate - PCI Req. 8.5.5 Compliance" -body $newbody -Attachments $invrreportname,$actionsreportname,$pnvrreportname

#cleanup files
remove-item *.csv -confirm:$false
remove-item *.pdf -confirm:$false

#Error reporting
if ($error.count -gt 0){
$body = $error | out-string
Send-MailMessage -to joel.terry@careerbuilder.com -from siteADreport@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "CBATL AD Unused Accounts Report for $subjectdate - ERRORS" -body $body}
