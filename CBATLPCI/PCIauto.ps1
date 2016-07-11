Function Get-LocalGroupMembers
{

#Guy that posted this function on the internet
# AUTHOR:     Piotr Lewandowski 
# VERSION:    1.0  
# DATE:       29/04/2013  

param(
[Parameter(ValuefromPipeline=$true)][array]$server = $env:computername,
$GroupName = $null
)


PROCESS {
    $finalresult = @()
    $computer = [ADSI]"WinNT://$server"

    if (!($groupName))
    {
    $Groups = $computer.psbase.Children | Where {$_.psbase.schemaClassName -eq "group"} | select -expand name
    }
    else
    {
    $groups = $groupName
    }
    $CurrentDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetDirectoryEntry() | select name,objectsid
    $domain = $currentdomain.name
    $SID=$CurrentDomain.objectsid
    $DomainSID = (New-Object System.Security.Principal.SecurityIdentifier($sid[0], 0)).value


    foreach ($group in $groups)
    {
    $gmembers = $null
    $LocalGroup = [ADSI]("WinNT://$server/$group,group")


    $GMembers = $LocalGroup.psbase.invoke("Members") | sort
    $GMemberProps = @{Server="$server";"Local Group"=$group;Name="";Type="";ADSPath="";Domain="";SID=""}
    $MemberResult = @()


        if ($gmembers)
        {
        foreach ($gmember in $gmembers)
            {
            $membertable = new-object psobject -Property $GMemberProps
            $name = $gmember.GetType().InvokeMember("Name",'GetProperty', $null, $gmember, $null)
            $sid = $gmember.GetType().InvokeMember("objectsid",'GetProperty', $null, $gmember, $null)
            $UserSid = New-Object System.Security.Principal.SecurityIdentifier($sid, 0)
            $class = $gmember.GetType().InvokeMember("Class",'GetProperty', $null, $gmember, $null)
            $ads = $gmember.GetType().InvokeMember("adspath",'GetProperty', $null, $gmember, $null)
            $MemberTable.name= "$name"
            $MemberTable.type= "$class"
            $MemberTable.adspath="$ads"
            $membertable.sid=$usersid.value


            if ($userSID -like "$domainsid*")
                {
                $MemberTable.domain = "$domain"
                }

            $MemberResult += $MemberTable
            }

         }
         $finalresult += $MemberResult 
    }
    $finalresult | select server,"local group",name,type,domain,sid
    }
}

Function enumgroup
{param($servername,$groupname,$filename)

#write-host "Enumerating "$groupname
$egrights = get-localgroupmembers -server $servername -group $groupname | sort name
$egrights | foreach{

if ($_.type -like "*group*"){enumgroup $_.server $_.name} else{
$addtofile = $_.name+","+$_."local group"+","+ $_.server+","+$_.type+","+$_.domain+","+$_.sid
add-content $filename $addtofile}
} 
}

Function enumdomaingrp
{param($groupname,$aservername,$filename,$domain,$creds)
if (!$domain){$domain = "atl.careerbuilder.com"; $creds = $cbatlCreds}
#write-host "Enumerating domain "$groupname
$egrights = get-adgroupmember $groupname | sort name
$egrights |foreach{
if ($_.objectclass -like "*group*"){enumdomaingrp $_.name $aservername $filename $domain $creds} else{
$addtofile = $_.name+","+ $groupname+","+$aservername+","+$_.objectclass+",atl (CBATL),"+$_.sid
add-content $filename $addtofile
if (($groupname -like "SQLDWReadOnly") -or ($groupname -like "TeamBIDWDev")){add-content $BIDWrights $addtofile}
}
}
}

function cleanstring
{param($dirtystring)

$chk = "> > "," >"," > ",">>","> "
$chk | foreach{
$dirtystring = $dirtystring.tostring()
if (($_ -like ">>") -or ($_ -like "> > ")){$dirtystring = $dirtystring.replace($_,">")} else {$dirtystring = $dirtystring.replace($_,"")}
#write-host "." -nonewline
}
$dirtystring
}

function sectionparse
{param($gporeport,$sectionname,$directoryname)

$sectionfilename = $directoryname +"Screen Shots GPO and Password Policy Settings\"+$sectionname.replace("/"," ") +".htm"
Clear-content $sectionfilename
add-content $sectionfilename (Get-content testheader.htm)
$search = 1
While ($i -eq 0){
#Write-host "." -nonewline
$parseloop = $gporeport | select-string $sectionname -context 0,$search
#$parseloop = $parseloop.tostring()
if ($parseloop -like "*</table>*"){ $i = 1; add-content $sectionfilename $parseloop}
$search = $search + 1
}
$stringtoclean =  (get-content $sectionfilename) | out-string
$cleaned = cleanstring $stringtoclean
set-content $sectionfilename $cleaned
}

function sendmail
{

param($subject,$body)
$attachments = get-childitem("c:\cbatlpci\attachment\")
$smtpServer = "relay.careerbuilder.com"
$msg = new-object Net.Mail.MailMessage
$msg.from ="siteADreport@careerbuilder.com"
$msg.to.add("siteopssupport@careerbuilder.com")
$msg.body = $body
$msg.subject =$subject
$attachments | foreach{
$attach = $_.fullname
$att = new-object Net.Mail.Attachment($_.fullname)
$msg.Attachments.Add($att)
}

$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($msg)
}

Function Jirareporting
{param($summary,$description,$assignee,$creds,$iheaders)
#Set-JiraConfigServer -server "http://siteopssupport.careerbuilder.com" -ConfigFile "c:\cbatlpci\jiraconfig.xml"
#New-JiraSession -Credential $creds
#$summary = $summary + "TEST AUTOMATION - IGNORE"
#$assignee ="jterry.site"
#New-jiraissue -project "IRQ" -issuetype "Task" -Priority 3 -Summary $summary -Description $description  -labels "" 
$body = '{
    "fields": {
       "project":
       { 
          "key": "IRQ"
       },
       "summary": "'+$summary+'",
       "description": "'+$description+'",
       "issuetype": {
          "name": "Task"
       }
   }
}'

Invoke-restmethod -method post -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/" -Headers $iheaders -body $body -timeoutsec 60

$issues = Invoke-restmethod -Uri "http://siteopssupport.careerbuilder.com/rest/api/latest/search?jql=project='IRQ'+AND+status='To Do'+or+status='In Progress'" -Headers $iheaders -timeoutsec 60 | select -ExpandProperty issues

$issues | foreach{
$ticket=$_
 if (($_.fields.Summary -like $summary) -and (!$_.fields.resolutiondate)){ 
$body = '{ "name": "'+$assignee+'" }'
$juri = "http://siteopssupport.careerbuilder.com/rest/api/latest/issue/"+$ticket.key+"/assignee"
$webResponse = Invoke-restmethod -method put -Uri $juri -Headers $iheaders -body $body -timeoutsec 60
 #get-jiraissue $ticket.key | set-jiraissue -assignee $assignee 
sendmail $ticket.key "Report Attachments" 
 }
}

  }
  
Function Combinereports
{param($directy,$fpath)
get-childitem("c:\cbatlpci\attachment\") | remove-item
$dirpath = $directy + $fpath
$filelist = get-childitem ($dirpath)
$filelist | foreach{
copy-item -path $_.fullname -destination c:\cbatlpci\attachment\
}
}

#Credentials
$cbatlUser = "cbatl\jterry.site"
$cbatlFile = "c:\siteopsscripts\cbatlpci\acklog2.txt"
$cbUser = "cb\jterry"
$cbFile = "c:\siteopsscripts\cbatlpci\acklog.txt"
#$cbatlCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbatlUser,(Get-Content $cbatlFile | ConvertTo-SecureString)
#$cbCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $cbUser,(Get-Content $cbFile | ConvertTo-SecureString)
Write-host "CBATl Creds"
$cbatlcreds = Get-credential
#Write-host "CB Creds"
#$cbcreds = get-credential
$jirauser = "sitesrvc"
$jirafile = "C:\SiteOpsScripts\jiraauto\jira.txt"
$jiraCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $jiraUser,(Get-Content $jiraFile | ConvertTo-SecureString)
#Collect Headers for send
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization', $basicAuthValue)
$headers.Add('accept','application/json')

#Create Directories for zip
$date = "$(Get-date -f yyyy)$("{0:00}" -f "Q" + [Math]::ceiling((Get-date -f MM)/3) )"
$directoryname = "c:\cbatlpci\"+$date+"\"
Copy-Item c:\cbatlpci\template\ $directoryname -recurse
$destination = "c:\cbatlpci\"+$date+".zip"

#file setup
$SQLDBpermissions = $directoryname + "SQLDBpermissions.csv"
$axiompermissions= $directoryname + "Local Membership by Computer Axiom DB\axiompermissions.csv"
$BIDWrights= $directoryname + "Review Members of BIDWTeam CB CorpApplications\BIDWrights.csv"
$cbcorpapps= $directoryname + "Review Members of BIDWTeam CB CorpApplications\cbcorpapps.csv"
$allCBATLaccounts = $directoryname +"AllCBATLMembers\allCBATLaccounts.csv"
$CBATLPNEaccounts = $directoryname +"Full Details for ServiceBuiltin AD Accounts NonExpiring\CBATLPNEaccounts.csv"
$ServiceSharedUsers = $directoryname +"Full Details for ServiceBuiltin AD Accounts NonExpiring\ServiceSharedUsers.csv"
$CBATLDAmembers = $directoryname+"Review Members of CBATL Admin Groups\CBATLDAmembers.csv"
$CBATLEAmembers = $directoryname+"Review Members of CBATL Admin Groups\CBATLEAmembers.csv"
$CBATLAOGmembers = $directoryname+"Review Members of CBATL Admin Groups\CBATLAOGmembers.csv"
$CBATLDLoginmembers = $directoryname+"Screen Shots GPO and Password Policy Settings\Local Policies User Rights Assignmentdenyloginmembers.csv"
$nonfsmoservers = $directoryname+"nonfsmoservers.csv"
$i90reportname = $directoryname + "AccountsToBeDisabled\90daydisabled.csv"
$i180reportname = $directoryname + "AccountsToBeDeleted\180daydelete.csv"
clear-content $SQLDBpermissions
clear-content $axiompermissions
Clear-content $BIDWrights
clear-content $cbcorpapps
$fileheaderaxiom = "name,localgroup,server,type,domain,sid"
$fileheadersqlperm = "User,Emunerated Group,Parent Group,Type,Domain,SID"
$fileheaderBIDW = "User,Emunerated Group,Parent Group,Type,Domain,SID"
$fileheadercapps = "User,Emunerated Group,Parent Group,Type,Domain,SID"
add-content $axiompermissions $fileheaderaxiom
add-content $SQLDBpermissions $fileheadersqlperm
add-content $BIDWrights $fileheaderBIDW
add-content $cbcorpapps $fileheadercapps

#GPO Reporting ******************************************************************************************
get-gporeport -name "default domain Policy" -reporttype html -path c:\cbatlpci\gpobase.htm
$i = 0
clear-content gpoheader.htm
$gpo = get-content gpobase.htm 
$gpoheader = get-content c:\cbatlpci\gpobase.htm | select-string -simplematch 'Computer Configuration (Enabled)' -context 1344,0 
$gpoheader = ($gpoheader.tostring()).replace('<div class="he0_expanded"><span class="sectionTitle" tabindex="0">Computer Configuration (Enabled)</span><a class="expando" href="#"></a></div>','')
add-content gpoheader.htm $gpoheader
$sectionheaders = "Account Policies/Password Policy","Control Panel/Personalization","Account Policies/Account Lockout Policy","Local Policies/User Rights Assignment"
$sectionheaders | foreach{
$insertsection = sectionparse $gpo $_ $directoryname
}

#GPO Reporting End*******************************************************************************************

#CBATL AD Reporting************************************************************************************************
#CBATL ACCOUNTS******************************
get-aduser -filter * -properties Name,mail,samaccountname,description,distinguishedname,enabled,LastLogonDate,LastLogonTimeStamp,whencreated,passwordneverexpires,accountexpirationdate -credential $cbatlcreds | select Name,mail,samaccountname,description,distinguishedname,enabled,LastLogonDate,LastLogonTimeStamp,whencreated,passwordneverexpires,accountexpirationdate | sort name | export-csv $allCBATLaccounts
get-aduser -filter{passwordneverexpires -eq "True"} -properties Name,mail,samaccountname,description,distinguishedname,enabled -credential $cbatlcreds | select Name,mail,samaccountname,description,distinguishedname,enabled,SID | sort name | export-csv $CBATLPNEaccounts
get-aduser -filter{description -like "*service account*"} -properties description,displayname,distinguishedname -credential $cbatlcreds | select description,displayname,distinguishedname,samaccountname | export-csv $ServiceSharedUsers
#Pull enabled users with LastLogonDate and LastLogonTimeStamp (Interactive Logons) and convert lastlogontimestamp to a usable date and time
$users=get-aduser -filter {Enabled -eq $true} -properties info,LastLogonDate,LastLogonTimeStamp,whencreated,mail,passwordneverexpires,accountexpirationdate -server atl.careerbuilder.com -credential $cbatlcreds | where-object {$_.samaccountname -like "*.site*"} 
$usersTimeStamp=$users | select-object mail,info,samaccountname,DistinguishedName,Name,whencreated,LastLogondate,@{n='LastLogonTimeStamp';e={[DateTime]::FromFileTime($($_.LastLogonTimeStamp))}}
$Over90SinceLastLogin=$usersTimeStamp | ?{$_.lastlogondate -le (get-date).adddays(-90) -or $_.LastLogonTimeStamp -le (get-date).adddays(-90) -and $_.LastLogonTimeStamp -notlike "*12/31/1600*"} 
$Over180SinceLastLogin=$usersTimeStamp | ?{$_.lastlogondate -le (get-date).adddays(-180) -or $_.LastLogonTimeStamp -le (get-date).adddays(-180) -and $_.LastLogonTimeStamp -notlike "*12/31/1600*"}
$Over180SinceLastLogin | select-object samaccountname,DistinguishedName,Name,whencreated,LastLogondate,lastlogontimestamp,passwordneverexpires,accountexpirationdate | Export-CSV $i180reportname -notype
$Over90SinceLastLogin | select-object samaccountname,DistinguishedName,Name,whencreated,LastLogondate,lastlogontimestamp,passwordneverexpires,accountexpirationdate | Export-CSV $i90reportname -notype

#CBATL Privileged Groups**************************
Get-adgroupmember "Domain Admins" -credential $cbatlcreds | select name,samaccountname,distinguishedname,objectclass,sid | sort name | export-csv $CBATLDAmembers
Get-adgroupmember "Enterprise Admins" -credential $cbatlcreds | select name,samaccountname,distinguishedname,objectclass,sid | sort name | export-csv $CBATLEAmembers
Get-adgroupmember "Account Operations Group" -credential $cbatlcreds | select name,samaccountname,distinguishedname,objectclass,sid | sort name | export-csv $CBATLAOGmembers
Get-adgroupmember "Denylogin" -credential $cbatlcreds | select name,samaccountname,distinguishedname,objectclass,sid | sort name | export-csv $CBATLDLoginmembers

#CBATL SERVER REPORTING**********************************************************
$addomain = get-addomain -credential $cbatlcreds
$adforest = get-adforest -credential $cbatlcreds
Get-adcomputer -filter * | ?{($_.dnshostname -ne $addomain.pdcemulator) -and ($_.dnshostname -ne $addomain.RIDmaster) -and ($_.dnshostname -ne $addomain.infrastructuremaster) -and ($_.dnshostname -ne $adforest.DomainNamingMaster) -and ($_.dnshostname -ne $adforest.SchemaMaster)} -credential $cbatlcreds | export-csv $nonfsmoservers
#End AD Reporting*************************************************

#MBSA Scans for Axiom + Rights Reports*******************************************************
$Axiomservers = get-adcomputer -filter{((name -like "*QTXBO*") -or (name -like "*QTXMXWS*") -or (name -like "*QTXBOM*") -or (name -like "*QTXMAILBO*") -or (name -like "*QTXBOASYNC*")-or (name -like "OPTIMUSA*") -or (name -like "OPTIMUSB*"))} -credential $cbatlcreds
$axiomservers | foreach{
$axiomserver = $_.name
if (($axiomserver -like "OPTIMUSA*") -or ($axiomserver -like "OPTIMUSB*")){$MBSAreports = $directoryname+"MBSA\DB"} else {$mbsareports = $directoryname+"MBSA\axiom"}
./mbsacli.exe /target $axiomserver /n os+iis+sql+password /rd $MBSAreports
$axiomrights = get-localgroupmembers -server $axiomserver -group Administrators  
$axiomrights | foreach{
$grpname = $_.name
$servername = $_.server
if (($_.type -like "*group*") -and ($_.domain -eq "atl")){enumdomaingrp $grpname $servername $axiompermissions}
if (($_.type -like "*group*") -and ($_.domain -ne "atl")){enumgroup $server $_.name $axiompermissions} else{
$addtofile =  $_.name+","+$_."local group"+","+$_.server+","+$_.type+","+$_.domain+","+$_.sid
add-content $axiompermissions $addtofile}
} 
}
#MBSA Scans for Domain Controllers************************************************************************************************
(get-adcomputer -filter{name -like "*ad*"} | ?{$_.distinguishedname -like "*controller*"}).name | foreach{
$axiomserver = $_.name
$MBSAreports = $directoryname+"MBSA\DC"
./mbsacli.exe /target $axiomserver /n os+iis+sql+password /rd $MBSAreports
}
#Security Log sample
$rnddcname =get-random ((get-adcomputer -filter{name -like "*ad*"} | ?{$_.distinguishedname -like "*controller*"}).name)
$logreport = $directoryname+"SampleSeclog.csv"
get-adcomputer $rnddcname | get-eventlog security | select -first 100 | export-csv $logreport
#CBATL SQL Security Groups***********************************************************************************************************
$sqlsecgroups = Get-adgroup -filter{name -like "*sql*"} -credential $cbatlcreds | sort name
$sqlsecgroups | foreach{
enumdomaingrp $_.name $_.name $SQLDBpermissions
}

#CB Corp Apps Security Groups*********************************************************************************************************88
$CBCAsecgroups = Get-adgroup -filter{name -like "*CB CorpApp*"} -credential $cbatlcreds | sort name
$CBCAsecgroups | foreach{
enumdomaingrp $_.name $_.name $cbcorpapps "atl.careerbuilder.com" $cbatlcreds
}

#convert csv reports to pdf**********************************************************************************************************8
$path = $directoryname
$xlFixedFormat = "Microsoft.Office.Interop.Excel.xlFixedFormatType" -as [type] 
$excelFiles = Get-ChildItem -Path $path -include *.csv -recurse 
 $objExcel = New-Object -ComObject excel.application 
$objExcel.visible = $false
foreach($wb in $excelFiles) 
{ 
 $filepath = Join-Path -Path $path -ChildPath ($wb.fullName + ".pdf") 
 $workbook = $objExcel.workbooks.open($wb.fullname, 3) 
 $workbook.ActiveSheet.Cells.Font.Size = 4
 $Workbook.ActiveSheet.PageSetup.Orientation = 2
 $Workbook.ActiveSheet.PageSetup.FitToPagesWide = 1
 $Workbook.ActiveSheet.PageSetup.FitToPagesTall = 1
 $workbook.ActiveSheet.ListObjects.add(1,$workbook.ActiveSheet.UsedRange,0,1)
 $workbook.ActiveSheet.Cells.HorizontalAlignment = -4108 
 $workbook.ActiveSheet.UsedRange.EntireColumn.AutoFit()
 $workbook.Saved = $true 
 $workbook.ExportAsFixedFormat($xlFixedFormat::xlTypePDF, ($wb.fullName + ".pdf") ) 
$objExcel.Workbooks.close() 
} 
$objExcel.Quit()

#create zip file
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($directoryname, $destination) 
get-process "excel" | stop-process
#Ticket Creation
# combinereports $directoryname 'Review Members of BIDWTeam CB CorpApplications\cbcorpapps.*'
# jirareporting "PCI $date - List of CB CorpApplications group members to Thomas Connell/Leslie Martin for review" "Please review, add comments to the ticket and reassign to siteops" "tconnell.site" $cbatlcreds $headers
# combinereports $directoryname 'Local Membership by Computer Axiom DB\*'
# jirareporting "PCI $date - Users who have administrator access privileges in Axiom systems" "Please review, add comments to the ticket and reassign to siteops" "tconnell.site" $cbatlcreds $headers
# combinereports $directoryname "Review Members of CBATL Admin Groups\*"
# jirareporting "PCI $date - Users who have administrator access privileges in AD (DA and EA to CBATL)" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'Screen Shots GPO and Password Policy Settings\Local Policies User Rights Assignment.*'
# jirareporting "PCI $date - GPO: Deny Service Account RDC Access + AD members of DenyLogin Group" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'Screen Shots GPO and Password Policy Settings\Control Panel Personalization.*'
# jirareporting "PCI $date - GPO: Windows Password Protect Screen Saver" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'Screen Shots GPO and Password Policy Settings\Account Policies Account Lockout Policy.*'
# jirareporting "PCI $date - GPO: Account Lockout Policy" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'Screen Shots GPO and Password Policy Settings\Account Policies Password Policy.*'
# jirareporting "PCI $date - GPO: Password Policy - password settings 'e.g., password length, complexity requirements, account lockout setting, idle session timeout, and audit policy' for AD" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'MBSA\DB\*'
# jirareporting "PCI $date - MBSA Reports: for Database Servers" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'MBSA\axiom\*'
# jirareporting "PCI $date - MBSA Reports: for Axiom Servers" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'nonfsmoservers.*'
# jirareporting "PCI $date - Report: List of all servers currently being managed, including server name, OS, and purpose/description" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'Full Details for ServiceBuiltin AD Accounts & NonExpiring\Service_SharedUsers.*'
# jirareporting "PCI $date - Report: List of Service/Shared/'Export to Excel' Built-in accounts with purpose/description" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'Full Details for ServiceBuiltin AD Accounts & NonExpiring\CBATL-PNEaccounts.*'
# jirareporting "PCI $date - Report: List of Accounts with Password not set to expire" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'AllCBATLMembers\allCBATLaccounts.*'
# jirareporting "PCI $date - Report: List of all AD accounts 'for CBATL domain'" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'SQLDBpermissions.*'
# jirareporting "PCI $date - Report: List SQLAdmin and ReadWrite groups members to Leon Chapman for review" "Please review, add comments to the ticket and reassign to siteops" "lchapman.site" $cbatlcreds $headers
# combinereports $directoryname 'Review Members of BIDWTeam & CB CorpApplications\BIDWrights.*'
# jirareporting "PCI $date - Report: List of BI DW Group Members to Thomas Connell for review" "Please review, add comments to the ticket and reassign to siteops" "tconnell.site" $cbatlcreds $headers
# combinereports $directoryname 'AccountsToBeDeleted\180daydelete.*'
# jirareporting "PCI $date - Report: List of AD accounts with 180 days inactive for deletion" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $directoryname 'AccountsToBeDisabled\90daydisabled.*'
# jirareporting "PCI $date - Report: List of AD accounts with 90 days inactive for disable" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers
# combinereports $destination
# jirareporting "PCI $date - Combined Report Zip File" "Please review, add comments to the ticket and reassign to siteops" "ashahzad.site" $cbatlcreds $headers








