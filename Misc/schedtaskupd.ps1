$computers = get-adcomputer -filter{enabled -eq "True"} 
foreach($computer in $computers){
if($computer.distinguishedname -notlike "*linux*"){
$live = test-connection $computer.dnshostname -count 1 -quiet
if($live){
$compname = "\\"+$computer.name
#$a=schtasks /change /s $compname /tn "GrimReaper" /ru "SYSTEM"

$a = schtasks /query /s $compname /tn "GrimReaper" /v
if ($a){
#Add-content staskschg1.txt $computer.name 
#add-content staskschg1.txt $a 
}}}

}