#MBSA Scans for Axiom + Rights Reports*******************************************************
$Axiomservers = get-adcomputer -filter{((name -like "*QTXBO*") -or (name -like "*QTXMXWS*") -or (name -like "*QTXBOM*") -or (name -like "*QTXMAILBO*") -or (name -like "*QTXBOASYNC*")-or (name -like "OPTIMUSA*") -or (name -like "OPTIMUSB*"))}
$axiomservers | foreach{
$axiomserver = $_.name
if (($axiomserver -like "OPTIMUSA*") -or ($axiomserver -like "OPTIMUSB*")){$MBSAreports = "c:\cbatlpci\MBSA\DB"} else {$mbsareports = "c:\cbatlpci\MBSA\axiom"}
mbsacli.exe /target $axiomserver /n os+iis+sql+password /rd $MBSAreports
}