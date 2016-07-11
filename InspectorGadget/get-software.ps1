Add-Content $VisualFile "Server,Name,Installation Date,Vendor,Version"
$VisualFile = "c:\users\kjantzer\desktop\VisualOutput.csv"
foreach ($strComputer in get-content "c:\users\kjantzer\desktop\servers.txt") 
{
	$colItems = get-wmiobject -class "Win32_Product" -namespace "root\CIMV2" `
	-computername $strComputer  | Where { $_.name -match 'Visual'}
	
	if ($colItems -eq "")
	{Add-Content $VisualFile "$strComputer,NoneInstalled,NoneInstalled,NoneInstalled,NoneInstalled"}
	else
	{
		foreach ($objItem in $colItems) 
		{
			$Name = $objItem.Name
			$InstallationDate = $objItem.InstallDate
			$Vendor = $objItem.Vendor
			$Version = $objItem.Version
			Add-Content $VisualFile "$strComputer,$Name,$InstallationDate,$Vendor,$Version"
		}
	}
}