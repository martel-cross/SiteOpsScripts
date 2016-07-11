#This script updates the iDRAC config with the current siteops username and password
#as well as configures domain account logins.  The script reads either IP addresses or
#domain names from a file called ipaddr.txt and will configure the iDRAC on each of those
#servers.  The script uses the drac.cfg file for the configuration paramaters.  Both of these
#files need to be in the same folder as the script.  The script writes the events to a log
#iDracConfig.log

#includes
. c:\SiteOpsScripts\writeLog.ps1

#Declare Globals
$racadmCommands = @(
					
					'racadm -u root -p calvin ',`
                   			'racadm -u siteops -p L3tme1n! ',`
                   			'racadm -u siteops -p M4nag3M3 ',`
                  			'racadm -u siteops -p gat3Way! ',`
					'racadm -u siteops -p kvm4ops ',`
				   	'racadm -u siteops -p Idrac4be ',`
					'racadm -u siteops -p P0w3rful_ ',`
					'racadm -u siteops -p QWAqwaqwaqwaqwa55555 ',`
                    			'racadm -u siteops -p R3m0te1n? ',`
					'racadm -u siteops -p op$4life ',`
					'racadm -u siteops -p opS4life ',`
					'racadm -u siteops -p Idrac4$ite ',`
				   	'racadm -u siteops -p Kvmg0ne ')
					
$configFile = ".\drac.cfg"
$ipaddsFile = ".\ipaddr.txt"
$dnsServer1 = '10.210.10.9'
$dnsServer2 = '10.210.10.10'
$resultHash = @{};

function parseIPFile ($file)
{
	#Declare Vars
	$ipadds = @()

	writeLog "Reading IPs\Names from $ipaddsFile" iDracConfig
	writeLog "" iDracConfig
	$content = get-content $file
	
	foreach ($line in $content)
	{
		#Make sure first char is not a semi-colon
		if ($line[0] -ne ';')
		{
			#Skip blank lines
			if ($line.length -gt 0)
			{
				$ipadds += $line
			}
		}
	}
	
	return $ipadds
}

function configDrac ($dracIP)
{
	writeLog "" iDracConfig
	writeLog "=================================================" iDracConfig
	writeLog "Configuring iDrac for $dracIP" iDracConfig
	writeLog "=================================================" iDracConfig
	
	#Parse drac.cfg file and replace the following:
	#SERVERNAME = $dracIP
	#DNSNAME1 = 10.240.10.10
	#DNSNAME2 = 10.240.10.10
	if ((Test-Path '.\serverDrac.cfg') -eq $true)
	{
		Remove-Item '.\serverDrac.cfg'
	}
	
	$cfg = Get-Content $configFile
	for ($i = 0; $i -lt $cfg.count; $i++)
	{
		$cfg[$i] = $cfg[$i].replace('SERVERNAME', $dracIP.replace('.idrac.careerbuilder.com',''))
		$cfg[$i] = $cfg[$i].replace('DNSNAME1', $dnsServer1)
		$cfg[$i] = $cfg[$i].replace('DNSNAME2', $dnsServer2)
	}
	
	$cfg | Out-File .\serverDrac.cfg -Force -Encoding ASCII
	
	#Run through the list of commands with different passwords until one is succesfull
	foreach ($cmd in $racadmCommands)
	{
		#2>&1 is so that errors are redirected to the standard output
		$cmd += "-r $dracIP config -f .\serverDrac.cfg 2>&1"
		writeLog "" iDracConfig
		writeLog "Running command:" idracConfig
		writeLog "$cmd" idracConfig
		
		$output = Invoke-Expression $cmd | Out-String
		
		#Return success and stop processing additional commands
		if ($output.contains('success') -eq $TRUE)
		{
			writeLog $output iDracConfig
			return 'Success'
		}
		
		#Proceed to next command if error is a login failure
		elseif ($output.contains('ERROR: Login failed') -eq $TRUE)
		{
			writeLog "Login failed for supplied username and password." iDracConfig
			writeLog "Trying next username and password." iDracConfig
			
			#If the last command still results in a password error
			if ($cmd.contains($racadmCommands[$racadmCommands.count - 1]) -eq $true)
			{
				writeLog "" iDracConfig
				writeLog "All known username and passwords have been tried and failed." iDracConfig
				return 'Failure'
			}
		}
		
		#Else return failure and stop processing additional commands
		else
		{
			writeLog "Failure:" iDracConfig
			writeLog $output iDracConfig
			return 'Failure'
		}
	}
	
}

function main()
{
	#Make sure ipaddr file exists
	if ((Test-Path $ipaddsFile) -eq $false)
	{
		writeLog "Aborting Script. Cannot find $ipaddsfile." iDracConfig
		writeLog "Please make sure file exists." iDracConfig
		return 'Failed'
	}
	
	#Make sure drac config file exists
	if ((Test-Path $configFile) -eq $false)
	{
		writeLog "Aborting Script. Cannot find $configFile." iDracConfig
		writeLog "Please make sure file exists." iDracConfig
		return 'Failed'
	}
	
	#Parse the ip address text file
	$ipadds = parseIPFile $ipaddsFile
	writeLog $ipadds iDracConfig
	writeLog "" iDracConfig
	
	#Run the commands for each ip addresss
	foreach ($ipadd in $ipadds)
	{
		$result = configDrac ($ipadd + '.idrac.careerbuilder.com')
		$resultHash[$ipadd] = $result
		
		writeLog "Result for $ipadd : $result" iDracConfig
	}
}


writeLog "Started iDracConfig" iDracConfig
main
writeLog "" iDracConfig

#Write the final verdict on all addresses
foreach ($key in $resultHash.keys)
{
	$result = $resultHash[$key]
	writeLog "$key : $result" iDracConfig
}

writeLog "" iDracConfig
writeLog "iDracConfig is done." iDracConfig



