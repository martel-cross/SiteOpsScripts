$computers = get-adcomputer -filter{enabled -eq "True"} 
foreach($computer in $computers){
$compname = "\\"+$computer.name
schtasks /query /s $compname /tn "GrimReaper"

}