$cbatlcreds = get-credential
$cbcreds= Get-Credential
$cbatlaccounts = get-aduser -filter{(description -notlike "*service*") -and (enabled -eq "True")} -properties mail,title,department,manager,employeeid,officephone,office
$cbatlaccounts | foreach{
$chgflag = 0
$cbatluser = $_
$cbsamaccountname = ($_.samaccountname).trim(".site")
$cbuser = get-aduser -filter{samaccountname -eq $cbsamaccountname} -properties mail,title,department,manager,employeeid,officephone,office -server cb.careerbuilder.com -credential $cbcreds
if ($cbuser){
if(($cbatluser.employeeid -ne $cbuser.employeeid) -and ($cbuser.employeeid -notlike "")){$cbatluser.employeeid = $cbuser.employeeid;$chgflag = 1}
if(($cbatluser.mail -ne $cbuser.mail) -and ($cbuser.mail -notlike "")){$cbatluser.mail = $cbuser.mail;$chgflag = 1}
if(($cbatluser.officephone -ne $cbuser.officephone) -and ($cbuser.officephone -notlike "")){$cbatluser.officephone = $cbuser.officephone;$chgflag = 1}
if(($cbatluser.office -ne $cbuser.office) -and ($cbuser.office -notlike "")){$cbatluser.office = $cbuser.office;$chgflag = 1}
if(($cbatluser.title -ne $cbuser.title) -and ($cbuser.title -notlike "")){$cbatluser.title = $cbuser.title;$chgflag = 1}
if(($cbatluser.department -ne $cbuser.department) -and ($cbuser.department -notlike "")){$cbatluser.department = $cbuser.department;$chgflag = 1}
if(($cbatluser.manager -ne $cbuser.manager) -and ($cbuser.manager -notlike "")){

$cbusermgr = get-aduser -filter{distinguishedname -eq $cbuser.manager} -server cb.careerbuilder.com -credential $cbcreds
$cbatlusermgr = ($cbusermgr.samaccountname)+".site"
$cbatlusermgrdn = get-aduser -filter{samaccountname -eq $cbatlusermgr} -server atl.careerbuilder.com -credential $cbatlcreds | select distinguishedname
$cbatluser.manager = $cbatlusermgrdn.distinguishedname
$chgflag = 1
}
if(($cbatluser.employeeid -ne $cbuser.employeeid) -and ($cbuser.employeeid -notlike "")){$cbatluser.employeeid = $cbuser.employeeid;$chgflag = 1}

}
if ($chgflag = 1){ set-aduser -instance $cbatluser}
}