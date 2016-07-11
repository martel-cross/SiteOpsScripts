$comps = get-adcomputer -filter {enabled -eq "True"} 
$comps | foreach{
$_.dnshostname
(get-process -computername $_.dnshostname).startinfo | ?{$_.username -like "*QPM*"}
}