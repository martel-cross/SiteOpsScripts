[array]$ouArray = $null

	##### Utility OUs
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=Utility,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	##### Web/MT OUs
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTW,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=Guests,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=DR,OU=CHI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=HK,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=WEB,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=EU,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
	$ouArray += $([ADSI]"LDAP://OU=MT,OU=QTM,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
		
	$ouArray += $([ADSI]"LDAP://OU=BOSS,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DPI,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=MAPPING,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	$ouArray += $([ADSI]"LDAP://OU=DEVTEST,OU=Servers,DC=ATL,DC=CAREERBUILDER,DC=COM").path
	
		
	foreach ($oupath in $ouArray)
	{
		$ou = [ADSI]"$oupath"
		foreach ($child in $ou.psbase.Children) 
		{ 
		 	if (($child.ObjectCategory -like '*computer*') -and ($child.userAccountControl -eq '4096')) 
			{ $serverlist += $child.Name }
		}
	}


$result = @{}

foreach ($server in $serverlist)
{
	#$ipAddress = Test-Connection $server -Count 1 -ErrorAction Continue | select -ExpandProperty ipv4address
	#echo $ipAddress >> c:\ipResult.txt
	#echo "$server $ipAddress"
	try            
	{            
		$ipAddress = Test-Connection -ComputerName $server -Count 1 -ErrorAction stop | select -ExpandProperty ipv4address
		#Test-Connection -ComputerName $server -Count 1 -ErrorAction stop | select -ExpandProperty ipv4address
		Write-Host "$server $ipAddress"
	}            
            
	catch [System.Management.Automation.ActionPreferenceStopException]            
	{            
		try {            
			throw $_.exception            
			}            
            
	catch [System.Net.NetworkInformation.PingException] {            
			"Catched PingException - $server doesn't exist."           
			}            
            
	catch {            
			'General catch'            
			}            
	}
	
	}


#	try{
#		$ipAddress = Test-Connection $server -Count 1 -ErrorAction Stop | select -ExpandProperty ipv4address
#		echo $ipAddress
#		$result.Add($server, $ipAddress)
#		}
#	catch{
#		Write-Host "$server offline" -ForegroundColor Red
#		$result.Add($server,0)
#		echo $ipAddress
#		}
	#Invoke-Command -ComputerName $server -ScriptBlock
	#	{
	#		racadm 
	#	}