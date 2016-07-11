[array]$ouArray = $null

	##### DB
	$ouArray += $([ADSI]"LDAP://OU=Clusters,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DEV,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DR,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=EU,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=HK,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=ODS,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=QTM,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=WebTier,OU=Nodes,OU=DB SERVERS,DC=ATL,DC=CAREERBUILDER,DC=COM").path

	##### BOSS
	$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	##### CHI
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Linux,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=VMWARE,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	###### DEVTEST
	$ouArray += $([ADSI]"LDAP://OU=Linux,OU=DEVTEST,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DEVTEST,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path

	###### DR
	$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Linux,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=VMWARE,OU=DR,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path

	###### EU
	$ouArray += $([ADSI]"LDAP://OU=Linux,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=VMWARE,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path

	###### QTM
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Linux,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=VMWARE,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path

	###### QTW
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Linux,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=VMWARE,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path


	###### Spare
	$ouArray += $([ADSI]"LDAP://OU=Spare,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		
foreach ($oupath in $ouArray)
	{
		$ou = [ADSI]"$oupath"
		foreach ($child in $ou.psbase.Children) 
		{ 
		 	if (($child.ObjectCategory -like '*computer*') -and ($child.userAccountControl -eq '4096')) 
			{ $serverlist += $child.Name }
		}
	}
Function verify($name)
	{
	 try{Invoke-Expression "racadm -r $check -u $oname -p $npass1 getractime"}
		catch [System.Management.Automation.ActionPreferenceStopException]{try {throw $_.exception}
			catch [System.Net.NetworkInformation.PingException] {"Can't log in - $server has incorrect password"}}
	}

Function chkIP($name)
	{
	 try{Test-Connection -ComputerName "$name.idrac.careerbuilder.com" -Count 1 -ErrorAction stop | select -ExpandProperty address}            
        catch [System.Management.Automation.ActionPreferenceStopException]{try {throw $_.exception}
			catch [System.Net.NetworkInformation.PingException] {"Catched PingException - $server doesn't exist."}}
	}

$result = @{}
$oname = Read-Host 'Enter the current iDRAC Username'
$opass = Read-Host 'Enter the current iDRAC Password'
echo "Please wait..."
sleep 2
$npass1 = Read-Host 'Enter your new desired iDRAC Password'
$npassv= Read-Host 'Enter your password once more to confirm'
If ($npass1 -match $npassv)
	{$npass = $npass1}
	
echo "Okay, starting to change..."

sleep 2

foreach ($server in $serverlist)
	{					
		try
    	{	
		$ErrorActionPreference = "Stop"
		Invoke-expression "racadm -r $server.idrac.careerbuilder.com -u $oname -p $opass config -g cfgUserAdmin -o cfgUserAdminPassword -i 2 $npass"
    	} # end try
    		catch [System.Management.Automation.RemoteException]
    		{
        	Write-Host "System.RemoteException caught."
    		} # end catch
    			catch
    			{
        		Write-Host "$server encountered an error." >> C:\results.txt
    			} # end catch
    				finally
    				{
       				 Write-Host "Done with $server.`n" >> c:\results.txt
    				}# end finally

	}