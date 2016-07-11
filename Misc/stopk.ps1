import-csv knames.csv |foreach{
 get-service -computername $_.servername | ?{$_.displayname -like "*kaseya*"} | set-service -status stopped
 #get-service -computername $_.servername | ?{$_.displayname -like "*kaseya*"}
 }