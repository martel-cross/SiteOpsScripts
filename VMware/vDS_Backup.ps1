<#
Script created by SiteBackend for Careerbuilder. 

This script connects to each vCenter inside the vCenter variable.

Currently maintained by: Jeff Bragdon jeff.bragdon@careerbuilder.com

Version 0.5 Alpha

#>

# Input paramters; if no input is given it will use the vCenter variable
param 
    (
        [string]$vCenter,  # Name of target vCenter
        [string]$Debug     # If set to true, adds more information about script running.
     ) 

write-host "Importing PowerCLI PSSnapin." -ForegroundColor gray
#Add-PsSnapin VMware*
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
} 
sleep(10) # Wait for modules to load.
     
# Checks to see if parameters are not blank.
if(-not($vCenter))  {Write-Host "Option -vCenter not supplied; running backup of all vCenters." -ForegroundColor Red}

$vCenterServers = @("DEVVCTR1","QTMVCTR1","QTXVCTR1","QTWVCTR1","CHIVCTR1","LUIGIVCTR1")
$date = date -Format dd-MM-yy
$time = get-date -DisplayHint Time
$log = "\\qtmbkp1\BackupSiteOps\VMware\VDSBackup\log_$date.txt"


function GetCredentialVC
{    

    $Key = @(133,53,24,19,143,78,24,28,149,10,147,131,200,88,167,114,120,115,31,25,240,39,45,19,124,18,106,116,240,110,247,158)

    $PFileLocation = '\\qtmbkp1\BackupSiteOps\PowerShell\Secure\p4vstbds.bkz'

    $decryptedpassword = get-content $PFileLocation | convertto-securestring -key $key

    $cred = New-Object System.Management.Automation.PsCredential 'temp',$decryptedpassword    # Sets false credentials to expose the plain text password

    $vCenterPass = $cred.GetNetworkCredential().password
    
    $vCenterPass
}

function Get-ViSession 
{
<#
.SYNOPSIS
Lists vCenter Sessions.

.DESCRIPTION
Lists all connected vCenter Sessions.

.EXAMPLE
PS C:\> Get-VISession

.EXAMPLE
PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 5 }
#>
    $SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
    $AllSessions = @()
    $SessionMgr.SessionList | Foreach {
    $Session = New-Object -TypeName PSObject -Property @{
        Key = $_.Key
        UserName = $_.UserName
        FullName = $_.FullName
        LoginTime = ($_.LoginTime).ToLocalTime()
        LastActiveTime = ($_.LastActiveTime).ToLocalTime()
        }

    If ($_.Key -eq $SessionMgr.CurrentSession.Key) {
        $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Current Session"
        } Else {
            $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Idle"
               }
        $Session | Add-Member -MemberType NoteProperty -Name IdleMinutes -Value ([Math]::Round(((Get-Date) - ($_.LastActiveTime).ToLocalTime()).TotalMinutes))
        $AllSessions += $Session
        }
        $AllSessions
}
 
function ConnectTo-VCenter($ThisVCenter)
{
        $password = GetCredentialVC
        $vCenterUser = "administrator@vsphere.local"
        #Import the PowerCLI module
        <#write-host "Importing PowerCLI PSSnapin." -ForegroundColor gray
        Add-PsSnapin VMware*#>
        write-host "Connecting to vCenter Server. This can take some time" -ForegroundColor Yellow
        Connect-VIServer $ThisVCenter -User $vCenterUser -Password $password  # Connects to the vCenter Server
     }

function BackupVdsISCSI($vCenterName)
{
    $ThisReturn = $Null

    Try
        {
            switch ($vCenterName) {
            "DEVVCTR1" {$location="DEV";break}
            "QTMVCTR1" {$location="QTM";break}
            "QTXVCTR1" {$location="QTX";break}
            "QTWVCTR1" {$location="QTW";break}
            "CHIVCTR1" {$location="CHI";break}
            "LUIGIVCTR1" {$location="LUIGI";break}
            }

            
            $destination = "\\qtmbkp1\BackupSiteOps\VMware\VDSBackup\$location\$vCenterName-iSCSI-$date.zip"

            #if(-not($vdsList = get-vdswitch)){Throw "Get-VDSwitch command failed to list vDS."}
            $vdsList = Get-VDSwitch

            if ($vdsList -eq $null)
            {
                Write-Output "$time : No iSCSI VDS found. Skipping $location." | Add-Content $log
                #Write-Host "No iSCSI VDS found. Skipping."

            } 
            else 
            {
                if (-not(Get-VDSwitch -Name 'vSwitchiSCSI' | Export-VDSwitch -Description "$location iSCSI VDS" -Destination $destination -Force))
                {Throw "$time : There was an error in saving the file."}
                else
                {Write-Output "$time : iSCSI VDS found for $location. Saved to $destination ." | Add-Content $log}
            }
        }
    Catch
        {
            # Do not return text, just set return bool to false.
            $ThisReturn = $False
            $ErrorMessage = "$time : An error has been encountered for $location. Please check the log file."
            Write-Output $ErrorMessage | Add-content $log
        }
    Finally
        {

        }

}

function BackupVdsPROD($vCenterName)
{
    $ThisReturn = $Null
    
    Try
        {
            switch ($vCenterName) {
            "DEVVCTR1" {$location="DEV";break}
            "QTMVCTR1" {$location="QTM";break}
            "QTXVCTR1" {$location="QTX";break}
            "QTWVCTR1" {$location="QTW";break}
            "CHIVCTR1" {$location="CHI";break}
            "LUIGIVCTR1" {$location="LUIGI";break}
            }

            $destination = "\\qtmbkp1\BackupSiteOps\VMware\VDSBackup\$location\$vCenterName-PROD-$date.zip"

            $vdsList = get-vdswitch

            if ($vdsList -eq $null)
            {
                Write-Output "$time : No Production VDS found. Skipping $location." | Add-Content $log
            } 
            else 
            {
                if (-not(Get-VDSwitch -Name 'vSwitchProduction' | Export-VDSwitch -Description "$location Production VDS" -Destination $destination -Force))
                {Throw "$time : There was an error in saving the file."}
                else
                {Write-Output "$time : Production VDS found for $location. Saved to $destination ." | Add-Content $log}
            }

            # If we get this far, connection was successful. Set return bool to true. 
            $ThisReturn = $True
        }
    Catch
        {
            # Do not return text, just set return bool to false.
            $ThisReturn = $False
            $ErrorMessage = "$time : An error has been encountered for $location. Please check the log file."
            Write-Output $ErrorMessage | Add-content $log
        }
    Finally
        {
            
        }
}

function Main($VCList)
{
    #Disconnect from any VI Servers
    Write-Host "inside Main"
    Disconnect-VIServer -Server * -Force -Confirm:$false | Out-Null

    foreach($server in $VCList)
    {
        sleep(2)
        ConnectTo-VCenter($server) -erroraction stop
        sleep(10)
        BackupVdsISCSI($server) -erroraction stop
        sleep(10)
        BackupVdsPROD($server) -erroraction stop 
        sleep(10)
    }
    
    Disconnect-VIServer -Server * -Force -Confirm:$false
}

Main($vCenterServers)
Send-MailMessage -to "SiteBackend <SiteBackend@careerbuilder.com>" -from "QTMMGMT1 <qtmmgmt1_Scheduledtask@noreply.com>" -Subject "Report for vDS Backup" -Body (Get-Content $log | Out-String) -SmtpServer "10.240.62.150"