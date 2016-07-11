#This script removes the dns records for a given server.  This includes the A and PT records as well as 
#the A and PTR records for the idrac card if it exists.

#Powershell starts in the home directory of user.
#Chagne the current directory to the script directory
Set-Location C:\SiteOpsScripts\Misc

#Includes
. c:\SiteOpsScripts\writeLog.ps1


#array of servers to remove dns entries
$serversArr = @('rebeljob1', 'rebeljob2', 'rebeljob3', 'rebeljob4', 'rebeljob5', 'rebeljob6', 'rebeljob7', 'rebeljob8', `
				'rebeljob9', 'rebeljob10', 'rebeljob11', 'rebeljob12', 'rebeljob13', 'rebeljob14', 'rebeljob15', `
				'rebeljob16', 'rebeljobm1', 'rebeljobm2')
				
writeLog "Removing DNS entries for the following servers" removeDnsRecords
writeLog $serversArr removeDnsRecords


#Create two arrays one for atl.careerbuilder.com and the other for idrac.careerbuilder.com
$atlArr = $serversArr.Clone()
$idracArr = $serversArr.Clone()

#Append .atl.careerbuilder.com to $atlArr
for ($i = 0; $i -lt $atlArr.count; $i++)
{
	$atlArr[$i] += '.atl.careerbuilder.com'
}

#Append .idrac.careerbuilder.com to $idracArr
for ($i = 0; $i -lt $idracArr.count; $i++)
{
	$idracArr[$i] += '.idrac.careerbuilder.com'
}

#Remove 'A' records for atl.careerbuilder.com
foreach ($record in $atlArr)
{
	#Create filter to pass to GWMI
	$filter = "OwnerName = '" + $record + "'"

	Try
	{
		#Get the object
		$wmiObj = Get-WmiObject -ComputerName DEVAD1 -Namespace 'root\MicrosoftDNS' -Class MicrosoftDNS_AType `
		-Filter $filter
		
		#Make sure object exists before attempting removal
		if ($wmiObj -eq $null)
		{
			writeLog "$record does not have an 'A' record" removeDnsRecords
		}
		else
		{
			writeLog "Removing the 'A' record for $record" removeDnsRecords
			writeLog $wmiObj removeDnsRecords
			
			#We do a foreach here just in case the wmi query returned more than one result
			foreach ($obj in $wmiObj)
			{
				$obj | Remove-WmiObject
			}
		}
	}
	Catch
	{
		writeLog "Error(s) detected while trying to remove the 'A' record for $record" removeDnsRecords
		writeLog $Error removeDnsRecords
	}
}

#Remove 'PTR' records for atl.careerbuilder.com
foreach ($record in $atlArr)
{
	#Create filter to pass to GWMI (pay attention to the last . for the FQDN for PTR records)
	$filter = "RecordData = '" + $record + ".'"
	
	Try
	{
		#Get the object
		$wmiObj = Get-WmiObject -ComputerName DEVAD1 -Namespace 'root\MicrosoftDNS' -Class MicrosoftDNS_PTRType `
		-Filter $filter
		
		#Make sure object exists before attempting removal
		if ($wmiObj -eq $null)
		{
			writeLog "$record does not have a 'PTR' record" removeDnsRecords
		}
		else
		{
			writeLog "Removing the 'PTR' record for $record" removeDnsRecords
			writeLog $wmiObj removeDnsRecords
			
			#We do a foreach here just in case the wmi query returned more than one result
			foreach ($obj in $wmiObj)
			{
				$obj | Remove-WmiObject
			}
		}
	}
	Catch
	{
		writeLog "Error(s) deteced while trying to remove the 'PTR' record for $record" removeDnsRecords
		writeLog $Error removeDnsRecords
	}
}

#Remove 'A' records for idrac.careerbuilder.com
foreach ($record in $idracArr)
{
	#Create filter to pass to GWMI
	$filter = "OwnerName = '" + $record + "'"

	Try
	{
		#Get the object
		$wmiObj = Get-WmiObject -ComputerName DEVAD1 -Namespace 'root\MicrosoftDNS' -Class MicrosoftDNS_AType `
		-Filter $filter
		
		#Make sure object exists before attempting removal
		if ($wmiObj -eq $null)
		{
			writeLog "$record does not have an 'A' record" removeDnsRecords
		}
		else
		{
			writeLog "Removing the 'A' record for $record" removeDnsRecords
			writeLog $wmiObj removeDnsRecords
			
			#We do a foreach here just in case the wmi query returned more than one result
			foreach ($obj in $wmiObj)
			{
				$obj | Remove-WmiObject
			}
		}
	}
	Catch
	{
		writeLog "Error(s) detected while trying to remove the 'A' record for $record" removeDnsRecords
		writeLog $Error removeDnsRecords
	}
}

#Remove 'PTR' records for idrac.careerbuilder.com
foreach ($record in $idracArr)
{
	#Create filter to pass to GWMI (pay attention to the last . for the FQDN for PTR records)
	$filter = "RecordData = '" + $record + ".'"
	
	Try
	{
		#Get the object
		$wmiObj = Get-WmiObject -ComputerName DEVAD1 -Namespace 'root\MicrosoftDNS' -Class MicrosoftDNS_PTRType `
		-Filter $filter
		
		#Make sure object exists before attempting removal
		if ($wmiObj -eq $null)
		{
			writeLog "$record does not have a 'PTR' record" removeDnsRecords
		}
		else
		{
			writeLog "Removing the 'PTR' record for $record" removeDnsRecords
			writeLog $wmiObj removeDnsRecords
			
			#We do a foreach here just in case the wmi query returned more than one result
			foreach ($obj in $wmiObj)
			{
				$obj | Remove-WmiObject
			}
		}
	}
	Catch
	{
		writeLog "Error(s) deteced while trying to remove the 'PTR' record for $record" removeDnsRecords
		writeLog $Error removeDnsRecords
	}
}

writeLog "Script has finished" removeDnsRecords