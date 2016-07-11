$SPNS = (get-aduser -filter{samaccountname -like "*sqlsrvc*"} -properties serviceprincipalname | select serviceprincipalname).serviceprincipalname
foreach($spn in $spns){
$result = get-adobject -filter {serviceprincipalname -like $spn}

write-host "The SPN:"$spn "Where its Duplicate:"$result.name
}