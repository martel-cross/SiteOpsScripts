add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

Function Add-CBLMHost() {
<#
   .Synopsis
    Adds hosts to logic monitor.
   .Description
    Connects through the AlertLogic API to add a host.
   .Example
    Add-CBLMHost -HostName <HostName> 
    Adds host to logic monitor to the API group.
   .Example
    $Hostname | Add-CBLMHost
    Accepts hosts from pipeline
   .Example 
    get-content .\file.txt | Add-CBLMHost accepts input from file (Loops)
   .Parameter HostName
    Target Host
   .Inputs
    [string]
   .OutPuts
    [string]
   .Notes
    NAME:  Add-CBLMHost
    AUTHOR: Jeffrey Bragdon
    LASTEDIT: 3/12/2015
    KEYWORDS:
   .Link
     http://careerbuilder.com
 #Requires -Version 2.0
 #>


    [CmdletBinding()]
Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True,
                   Position=1)]
        [Alias('computername')] # Alias of HostName
        [ValidateLength(5,20)]  # used to ensure there are at least 5 characters, no more then 20. 
        [string[]]$hostNames

    )
BEGIN {
        Write-Debug   "Debug switch set."
        Write-Verbose "Verbose switch set."

        $Key = @(12,182,109,90,149,247,202,100,205,98,167,110,247,96,63,73,207,131,18,217,151,127,131,16,217,141,202,147,96,228,188,225)
        $PFileLocation = '\\qtmbkp1\BackupSiteOps\PowerShell\Secure\LM234AAA.ASDFF'
        $decryptedPassword = get-content $PFileLocation | convertto-securestring -key $Key
        $cred = New-Object System.Management.Automation.PsCredential 'temp',$decryptedpassword    # Sets false credentials to expose the plain text password
        $LMAPIPass = $cred.GetNetworkCredential().password # Pulls password into clear text format.
        $LMAPIUser = "srvrapi"  
        Write-Verbose "Completed generation of password."
        
        Write-Verbose "Finished startup processes. " # Only shows on -Debug flag, useful for debut / non verbose purposes. 
    }
PROCESS {
        Write-Verbose "Starting process." # This is bound to CmdletBinding(), and will write only if the command is run with -verbose

        function LMFind-Collector($GetCollectorForThisHost){ #Returns Random collector from specific collector bucket for monitoring. Returns ID only. 
    
            Write-Debug "Got $GetCollectorForThisHost"
            Write-Verbose "Finding collector for $GetCollectorForThisHost."

            # Pull List of Collectors with Names
            $GetCollectorURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getAgents?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass"

            Write-Debug "DEBUG:URL is [$GetCollectorURL]"

            $CollectorsList = (Invoke-RestMethod $GetCollectorURL).data | Select-Object -Property ID,Description
            $TotalCollectorsCount = $CollectorsList.Count  #Capture agent count for later count check. This is used to identify additional collectors being added that are not anticipated. 

            $TempCount = $CollectorsList.Count

            Write-Verbose "Found: $TempCount collectors."

            # Put each collector into a bucket by location.
            $CHI_DR_Collectors   = @()
            $CHI_BEAR_Collectors = @()
            $QTW_Collectors      = @()
            $QTM_QTX_Collectors  = @()
            $AmstelCollectors    = @()
            $DevCollectors       = @()
            $IgnoreCollectors    = @()
            $UnknownCollectors   = @{}

            foreach ($Collector in $CollectorsList)   # this is the loop that actually adds each collector to a bucket. Later, we will use tagging in the description to automate this more.
                 {
                    if     ($Collector.description -like "*LUIGILOGIC*")  {$CHI_DR_Collectors   += $Collector.Description}   # If the collector description contains part of the match string, add it to the bucket.
                    elseif ($Collector.description -like "*BEARLOGIC*")   {$CHI_BEAR_Collectors += $Collector.Description} 
                    elseif ($Collector.description -like "*CHILOGIC*")    {$CHI_BEAR_Collectors += $Collector.Description} 
                    elseif ($Collector.description -like "*REBELLOGIC*")  {$QTW_Collectors      += $Collector.Description}
                    elseif ($Collector.description -like "*CBLOGIC*")     {$QTM_QTX_Collectors  += $Collector.Description}
                    elseif ($Collector.description -like "*AMSTELLOGIC*") {$AmstelCollectors    += $Collector.Description}
                    elseif ($Collector.description -like "*Cloudlogic*")  {$DevCollectors       += $Collector.Description}
                    elseif ($Collector.description -like "*Bastion*")     {$IgnoreCollectors    += $Collector.Description}
                    elseif ($Collector.description -like "*monitorme*")   {$IgnoreCollectors    += $Collector.Description}
                    elseif ($Collector.description -like "*SiteDB*")      {$IgnoreCollectors    += $Collector.Description}
                    else {$UnknownCollectors.add($Collector.Description,$Collector.id)} # Captures unexpected collectors for debug / logging later.
                  }
         
            # Count all the collectors in each bucket. Subtract that from the total collector count. If I have anything left over - there are unexpected collectors - throw error. (Maybe this should be a warning with continue?)
            $CheckCollectorCount = $TotalCollectorsCount-$CHI_DR_Collectors.count-$CHI_BEAR_Collectors.count-$QTW_Collectors.count-$QTM_QTX_Collectors.count-$AmstelCollectors.count-$IgnoreCollectors.count-$DevCollectors.count # Used to check for unexpected collectors. 

            if ($CheckCollectorCount -ne 0) {Throw "Unexpected collector located in LMFind-Collector."} # Make sure we are catching all reported collectors from the API.


            $IPofHost = ([System.Net.Dns]::GetHostAddresses("$GetCollectorForThisHost")).IPAddressToString # Return IP of Hostname
            $IPofHost = (([ipaddress] $IPofHost).GetAddressBytes()[0..1] -join ".") # Gets the first two octets of the IP and resets IPofHost. This will allow exact matches without wildcards. 

            # Store all IP ranges used at CB in an array. This should not change much. 

            $QTM = @()
            $QTM += "10.240"
            $QTM += "10.243"
            $QTM += "10.245"
            $QTM += "10.248"

            $QTW = @()
            $QTW += "10.10"
            $QTW += "10.192"
            $QTW += "10.210"
            $QTW += "10.213"
            $QTW += "10.218"
            $QTW += "10.255"
            $QTW += "10.30"
            $QTW += "10.61"
            $QTW += "10.63"
            $QTW += "10.64"
            $QTW += "10.65"

            $DEV = @()
            $DEV += "10.198"
            $DEV += "10.199"

            $LUIGI = @()
            $LUIGI += "10.232"
            $LUIGI += "10.236"
            $LUIGI += "10.237"
            $LUIGI += "10.238"
            $LUIGI += "10.239"

            $CHI = @()
            $CHI += "10.230"
            $CHI += "10.235"
            $CHI += "10.253"

            $AMS = @()
            $AMS += "10.266"
            $AMS += "10.227"



            # Matches the IP of the $HOSTNAME to one of the bucket IP arrays just above. Matches it to the collector buckets by location. Selects the random collector from that bucket.  

            if     ($DEV   -like $IPofHost)
                {
                     if ($DEBUG){Write-host "DEBUG: DEV collector bucket selected"}
                     $SelectedCollector = get-random $DevCollectors
                 }
            elseif ($QTW   -like $IPofHost)
                {
                     if ($DEBUG){Write-host "DEBUG: QTW collector bucket selected"}
                     $SelectedCollector = get-random $QTW_Collectors
                 }
            elseif ($CHI   -like $IPofHost)
                {
                     if ($DEBUG){Write-host "DEBUG: CHI collector bucket selected"}
                     $SelectedCollector = get-random $CHI_BEAR_Collectors
                 }
            elseif ($LUIGI -like $IPofHost)
                {
                     if ($DEBUG){Write-host "DEBUG: DR collector bucket selected"}
                     $SelectedCollector = get-random $CHI_DR_Collectors
                 }
            elseif ($AMS   -like $IPofHost) 
                {
                     if ($DEBUG){Write-host "DEBUG: AMS collector bucket selected"}
                     $SelectedCollector = get-random $AmstelCollectors
                 }
            elseif ($QTM   -like $IPofHost)
                {
                     if ($DEBUG){Write-host "DEBUG: QTM collector bucket selected"}
                     $SelectedCollector = get-random $QTM_QTX_Collectors
                 }
            else {Throw "Unknown IP Range in LMFind-Collector"}  # Control method. If I cannot match the IP range - there is a new unexpected IP range that I am not handling.

            $SelectedCollectorID = ($CollectorsList.id[[array]::indexof($CollectorsList.description,$SelectedCollector)]) # This finds the index reference of the array matching the selected collector and returns its ID from the array. (My eyes crossed too). In a nut shell, give me the number of the mailbox my match is in.

            Write-Verbose "Collector Selected: $SelectedCollector, ID:$SelectedCollectorID"
            Write-Debug "Collector Selected: $SelectedCollector, ID:$SelectedCollectorID"


            Return $SelectedCollectorID
    } #End of LMFind-Collector.


        function LMAdd-Host($AddThisHost) {    #Function to add host

            # Lets Make sure the host is not already in Logic Monitor
            $GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$AddThisHost"
            Write-Verbose "DEBUG: HostURL is: $GetHostURL"

            if((Invoke-RestMethod $GetHostURL).errmsg -eq "OK") {
            Write-Verbose "Host is already present, skipping."
            break
            }

            else {  # We are adding it.
                    # Get the ID of the collector for the host.  
                    $ThisCollectorID = LMFIND-Collector $AddThisHost | out-string

                    Write-Verbose "Adding Host $AddThisHost to $ThisCollectorID. "
                    # Add the host
                    $AddHostResponse = Invoke-WebRequest "https://careerbuilder.logicmonitor.com/santaba/rpc/addHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&hostName=$AddThisHost&displayedAs=$AddThisHost&description=AddedbyAPI&alertEnable=true&agentId=$ThisCollectorID&hostGroupIds=605"
             }

            # Make sure its in logic monitor
            if((Invoke-RestMethod $GetHostURL).errmsg -eq "OK") {Write-Verbose "DEBUG: Host was added successfully."} else {Throw "Host was not confirmed added. Something went wrong in LMADD-HOST"}
         }


foreach ($hostName in $hostNames) {LMAdd-Host($hostName)}




} # End of Process
END {
Write-Verbose "All hosts added. "
} # End of End Process

} # End of CBLMAdd-Host function

Function Remove-CBLMHost() {
<#
   .Synopsis
    Remove hosts from logic monitor.
   .Description
    Connects through the AlertLogic API to delete a host.
   .Example
    Remove-CBLMHost -HostName <HostName> 
    Removes host from logic monitor.
   .Example
    $Hostname | Remove-CBLMHost
    Accepts hosts from pipeline
   .Example 
    get-content .\file.txt | Remove-CBLMHost
    accepts input from file (Loops)
   .Parameter HostName
    Target Host
   .Inputs
    [string]
   .OutPuts
    [string]
   .Notes
    NAME:  Remove-CBLMHost
    AUTHOR: Jeffrey Bragdon
    LASTEDIT: 3/12/2015
    KEYWORDS:
   .Link
     http://careerbuilder.com
 #Requires -Version 2.0
 #>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True,
                   Position=1)]
        [Alias('computername')] # Alias of HostName
        [ValidateLength(5,20)]  # used to ensure there are at least 5 characters, no more then 20. 
        [string[]]$hostNames

    )

BEGIN{
        Write-Debug   "Debug switch set."
        Write-Verbose "Verbose switch set."

        $Key = @(12,182,109,90,149,247,202,100,205,98,167,110,247,96,63,73,207,131,18,217,151,127,131,16,217,141,202,147,96,228,188,225)
        $PFileLocation = '\\qtmbkp1\BackupSiteOps\PowerShell\Secure\LM234AAA.ASDFF'
        $decryptedPassword = get-content $PFileLocation | convertto-securestring -key $Key
        $cred = New-Object System.Management.Automation.PsCredential 'temp',$decryptedpassword    # Sets false credentials to expose the plain text password
        $LMAPIPass = $cred.GetNetworkCredential().password # Pulls password into clear text format.
        $LMAPIUser = "srvrapi"  
        Write-Verbose "Completed generation of password."
        
        Write-Verbose "Finished startup processes. " # Only shows on -Debug flag, useful for debut / non verbose purposes. 
}
PROCESS{
    Function LMRemove-Host($DeleteThisHost) {
        Write-Debug "In LMDelete-host. Host:$DeleteThisHost"
        Write-Verbose "Starting process to remove: $DeleteThisHost"

        #Check if host is in Logic Monitor
        $GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$DeleteThisHost" # Prepare the URL to be used below.
        write-verbose "DEBUG: HostURL is: $GetHostURL"

        $IsHostGone = (Invoke-RestMethod $GetHostURL).errmsg
        if ($IsHostGone -ne "OK") {write-verbose "DEBUG: Host is already gone, skipping.";break}
        $DeleteHostID = (Invoke-RestMethod $GetHostURL).data.id # Returns the ID of the host we are to remove based on the displayname.

        Write-Verbose "Target Host ID: $DeleteHostID "

        $DeleteHostResponse = Invoke-RestMethod "https://careerbuilder.logicmonitor.com/santaba/rpc/deleteHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&hostId=$DeleteHostID&deleteFromSystem=true"  # Actual Delete method. 

        # Make sure the host is gone.
        $IsHostGone = (Invoke-RestMethod $GetHostURL).errmsg
        if ($IsHostGone -eq "No such host" ){Write-verbose "DEBUG: Host is confirmed removed."} else {Throw "Host was not deleted. Something went wrong in LMDELETE-HOST"} #Throw error if not gone
    }

foreach ($HostName in $hostNames) {LMRemove-Host($HostName)}
}
END{}
}

Function Move-CBLMHost() {
<#
   .Synopsis
    Move a host to a new group.
   .Description
    Connects through the AlertLogic API to move a host to a new target group
   .Example
    Move-CBLMHost -HostName TESTSERVER -Group "QTW/Management/ESXi Hosts"
    Moves the host to the new group. 
   .Parameter HostName
    Target Host
   .Parameter Group
    Target Group
   .Inputs
    [string]
   .OutPuts
    [string]
   .Notes
    NAME:  Move-CBLMHost
    AUTHOR: Jeffrey Bragdon
    LASTEDIT: 3/31/2015
    KEYWORDS:
   .Link
     http://careerbuilder.com
 #Requires -Version 2.0
 #>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   Position=1)]
        [Alias('computername')] # Alias of HostName
        [ValidateLength(5,20)]  # used to ensure there are at least 5 characters, no more then 20. 
        [string[]]$HostName,
        [Parameter(Mandatory=$True)]
        [string]$TargetGroup

    )

BEGIN{
        Write-Debug   "Debug switch set."
        Write-Verbose "Verbose switch set."

        $Key = @(12,182,109,90,149,247,202,100,205,98,167,110,247,96,63,73,207,131,18,217,151,127,131,16,217,141,202,147,96,228,188,225)
        $PFileLocation = '\\qtmbkp1\BackupSiteOps\PowerShell\Secure\LM234AAA.ASDFF'
        $decryptedPassword = get-content $PFileLocation | convertto-securestring -key $Key
        $cred = New-Object System.Management.Automation.PsCredential 'temp',$decryptedpassword    # Sets false credentials to expose the plain text password
        $LMAPIPass = $cred.GetNetworkCredential().password # Pulls password into clear text format.
        $LMAPIUser = "srvrapi"  
        Write-Verbose "Completed generation of password."
        
        Write-Verbose "Finished startup processes. " # Only shows on -Debug flag, useful for debut / non verbose purposes. 
}
PROCESS{

        #Check if host is in Logic Monitor
        $GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$HostName" # Prepare the URL to be used below.
        write-verbose "DEBUG: HostURL is: $GetHostURL"

        # Pull Information about the target host.
        $TargetHost = (Invoke-RestMethod $GetHostURL)
        if ($TargetHost.errmsg  -ne "OK") {write-verbose "DEBUG: Host is not present, skipping.";break}

        # Pulls out information about the host into variables
        $MoveHostID = $TargetHost.data.id                   # Servers ID
        $ThisCollectorName = $TargetHost.data.agentDescription  # Collector the server responds to.

        # Get Collector Information
        $GetCollectorURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getAgents?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass"
        Write-verbose "DEBUG:URL is [$GetCollectorURL]"
        $CollectorsList = (Invoke-RestMethod $GetCollectorURL).data | Select-Object -Property ID,Description

        # Does voodo to match up the entries to return the ID of the collector.
        $SelectedCollectorID = ($CollectorsList.id[[array]::indexof($CollectorsList.description,$ThisCollectorName)])

        write-verbose " ServerName: $HostName" 
        write-verbose "   ServerID: $MoveHostID"
        write-verbose "  Collector: $ThisCollectorName"
        write-verbose "CollectorID: $SelectedCollectorID" 
        
        
        # Translate the Target Group Name into TargetGroup ID

        $GethostGroupURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHostGroups?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass"
        $AllHostGroupsRaw = (Invoke-RestMethod $GethostGroupURL)
        $AllHostGroups = @()
        $AllHostGroups = $AllHostGroupsRaw.data | Select-object FullPath,id
        $TargetGroupId = ($AllHostGroups | Where-Object {$_.FullPath -like "*$TargetGroup*"}).id

        

        # Prepare the Move API Callv + move
        

        $MoveURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/updateHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&id=$MoveHostID&hostName=$HostName&displayedAs=$HostName&agentId=$SelectedCollectorID&hostGroupIds=$TargetGroupId"
        $MoveResponse = (Invoke-RestMethod $MoveURL )



}
END{}
}  # Bug - does not move the host to the new group - it adds the new group as a 2ndary. 

Function Set-CBLMSDT() {
<#
   .Synopsis
    Set Standard Down Time on a single host
   .Description
    Sets host into maintenance mode (Standard Down Time) for a specific set of time. 
   .Example
    Set-CBLMSDT -HostName TESTSERVER -Hours 3
    Sets the host for SDT for 3 hours. Cannot exceed 23 hours.  
   .Parameter HostName
    Target Host
   .Parameter Hours
    How many hours
   .Inputs
    [string]
   .OutPuts
    [string]
   .Notes
    NAME:  Set-CBLMSDT
    AUTHOR: Jeffrey Bragdon
    LASTEDIT: 4/1/2015
    KEYWORDS:
   .Link
     http://careerbuilder.com
 #Requires -Version 2.0
 #>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   Position=1)]
        [Alias('computername')] # Alias of HostName
        [ValidateLength(5,20)]  # used to ensure there are at least 5 characters, no more then 20. 
        [string[]]$HostName,
        [Parameter(Mandatory=$True)]
        [string]$Hours

    )

BEGIN{
        Write-Debug   "Debug switch set."
        Write-Verbose "Verbose switch set."

        $Key = @(12,182,109,90,149,247,202,100,205,98,167,110,247,96,63,73,207,131,18,217,151,127,131,16,217,141,202,147,96,228,188,225)
        $PFileLocation = '\\qtmbkp1\BackupSiteOps\PowerShell\Secure\LM234AAA.ASDFF'
        $decryptedPassword = get-content $PFileLocation | convertto-securestring -key $Key
        $cred = New-Object System.Management.Automation.PsCredential 'temp',$decryptedpassword    # Sets false credentials to expose the plain text password
        $LMAPIPass = $cred.GetNetworkCredential().password # Pulls password into clear text format.
        $LMAPIUser = "srvrapi"  
        Write-Verbose "Completed generation of password."
        
        Write-Verbose "Finished startup processes. " # Only shows on -Debug flag, useful for debut / non verbose purposes. 
}
PROCESS{

        #Check if host is in Logic Monitor
        $GetHostURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$HostName" # Prepare the URL to be used below.
        write-verbose "DEBUG: HostURL is: $GetHostURL"

        # Pull Information about the target host.
        $TargetHost = (Invoke-RestMethod $GetHostURL)
        if ($TargetHost.errmsg  -ne "OK") {write-verbose "Host is not present, skipping.";break}

        # Pulls out information about the host into variables
        $ThisHostID = $TargetHost.data.id                   # Servers ID
        $ThisCollectorName = $TargetHost.data.agentDescription  # Collector the server responds to.

        # Get Collector Information
        $GetCollectorURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/getAgents?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass"
        Write-verbose "DEBUG:URL is [$GetCollectorURL]"
        $CollectorsList = (Invoke-RestMethod $GetCollectorURL).data | Select-Object -Property ID,Description

        # Does vodo to match up the entries to return the ID of the collector.
        $SelectedCollectorID = ($CollectorsList.id[[array]::indexof($CollectorsList.description,$ThisCollectorName)])

        write-verbose " ServerName: $HostName" 
        write-verbose "   ServerID: $ThisHostID"
        write-verbose "  Collector: $ThisCollectorName"
        write-verbose "CollectorID: $SelectedCollectorID" 
        
        # Prepare the URL for the API call.

        # Get Current Date and Time information ready
        $TodaysDate = Get-Date
        $CurrentYear = $TodaysDate.Year
        $CurrentMonth = $TodaysDate.Month
        $DayOfWeekName = $TodaysDate.dayofweek
        $CurrentHour = $TodaysDate.Hour
        $CurrentMinute = $TodaysDate.Minute

        $DaysToNumbers = @{
        Sunday    = 1
        Monday    = 2
        Tuesday   = 3
        Wednesday = 4
        Thursday  = 5
        Friday    = 6
        Saturday  = 7
        }  # Used to transfer name of the day of the week into integer value. 
        $DayOfWeekNumber = $DaysToNumbers."$DayOfWeekName"



        $EndHour = $CurrentHour + $Hours  # Combines current hour with the number of hours of SDT to return the new end hour.  Also, must roll the day. Also, must watch for Month, and Year roll. 

        if ($EndHour -ge 24){
        $EndHour = $EndHour-24
        $TodaysDate = $TodaysDate.AddDays(1)
        $CurrentYear = $TodaysDate.Year
        $CurrentMonth = $TodaysDate.Month
        $DayOfWeekName = $TodaysDate.dayofweek
        $CurrentHour = $TodaysDate.Hour
        $CurrentMinute = $TodaysDate.Minute
        
        $DayOfWeekNumber = $DaysToNumbers."$DayOfWeekName"

        }  # if we reach higher then or equal to 24, rotate to 0.

        
        $SDTURL = "https://careerbuilder.logicmonitor.com/santaba/rpc/setHostSDT?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&hostId=$ThisHostID&type=1&year=$CurrentYear&month=$CurrentMonth&day=$DayOfWeekNumber&hour=$CurrentHour&minute=$CurrentMinute&endYear=$CurrentYear&endMonth=$CurrentMonth&endDay=$DayOfWeekNumber&endHour=$EndHour&endMinute=$CurrentMinute"
        
        $SDTResponse = (Invoke-RestMethod $SDTURL)

        write-verbose $SDTResponse
}
END{}
}

Function Get-HostsInGroup() {
<#
   .Synopsis
    Adds hosts to logic monitor.
   .Description
    Connects through the AlertLogic API to add a host.
   .Example
    Add-CBLMHost -HostName <HostName> 
    Adds host to logic monitor to the API group.
   .Example
    $Hostname | Add-CBLMHost
    Accepts hosts from pipeline
   .Example 
    get-content .\file.txt | Add-CBLMHost accepts input from file (Loops)
   .Parameter HostName
    Target Host
   .Inputs
    [string]
   .OutPuts
    [string]
   .Notes
    NAME:  Add-CBLMHost
    AUTHOR: Jeffrey Bragdon
    LASTEDIT: 3/12/2015
    KEYWORDS:
   .Link
     http://careerbuilder.com
 #Requires -Version 2.0
 #>


    [CmdletBinding()]
Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelinebyPropertyName=$True,
                   Position=1)]
        [int[]]$hostGroup

    )
BEGIN {
        Write-Debug   "Debug switch set."
        Write-Verbose "Verbose switch set."

        $Key = @(12,182,109,90,149,247,202,100,205,98,167,110,247,96,63,73,207,131,18,217,151,127,131,16,217,141,202,147,96,228,188,225)
        $PFileLocation = '\\qtmbkp1\BackupSiteOps\PowerShell\Secure\LM234AAA.ASDFF'
        $decryptedPassword = get-content $PFileLocation | convertto-securestring -key $Key
        $cred = New-Object System.Management.Automation.PsCredential 'temp',$decryptedpassword    # Sets false credentials to expose the plain text password
        $LMAPIPass = $cred.GetNetworkCredential().password # Pulls password into clear text format.
        $LMAPIUser = "srvrapi"  
        Write-Verbose "Completed generation of password."
        
        Write-Verbose "Finished startup processes. " # Only shows on -Debug flag, useful for debut / non verbose purposes. 
    }
PROCESS {
        Write-Verbose "Starting process." # This is bound to CmdletBinding(), and will write only if the command is run with -verbose


        function LMGet-Hosts($groupID) {    #Function to add host

                    # Add the host
                    $GetHostsResponse = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHosts?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&hostGroupId=$groupID"
                    $rawHosts = Invoke-RestMethod($GetHostsResponse)


                    $hostCount = 0
                    $date = date -Format dd-MM-yy
                    Add-Content "C:\SiteOpsScripts\LogicMonitorReporting\logs\logicmon_report_$date.txt" "Please have the following systems moved to the correct group. They are currently in the default API folder.`n`n"


                    foreach($name in $rawHosts.data.hosts.name)
                        {
                            $getHostInfo = "https://careerbuilder.logicmonitor.com/santaba/rpc/getHost?c=careerbuilder&u=$LMAPIUser&p=$LMAPIPass&displayName=$name"
                            $rawInfo = Invoke-RestMethod($getHostInfo)

                            $createdOn = $rawInfo.data.createdOn

                            #FUNCTION GOES HERE#
                            #getTimeDifference($createdOn,$name)
                            $unixtime = $createdOn
                            $origin = New-Object -TypeName DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
                            $conversion = $origin.AddSeconds($unixtime)
                            $createdDate = $conversion
                            $currentDate = date

                            $difference = New-TimeSpan -Start $createdDate -End $currentDate
                            $daysInApi = $difference.Days
                            $date = date -Format dd-MM-yy

                            if ($daysInApi -gt 14 ){
                                Add-Content "C:\SiteOpsScripts\LogicMonitorReporting\logs\logicmon_report_$date.txt" "`nHost $name has been in API group for more than 14 days (total days: $daysInApi)."
                                
                                $hostCount++
                                }
                            else {}
                        }
                        

                        Function sendEmail
                        { 
                            $contentTarget = "C:\SiteOpsScripts\LogicMonitorReporting\logs\logicmon_report_$date.txt"
                            $From = "QTM Management 1 <qtmmgmt1@atl.careerbuilder.com>"
                            $To   = "Site Backend <sitebackend@careerbuilder.com>"
                            $Sub  = "There are $hostCount hosts in API folder for over 2 weeks."

                            Send-MailMessage -to $To -from $From -Subject $Sub -Body (Get-Content $contentTarget | Out-String) -SmtpServer "10.240.62.150"
                        }


                        sendEmail
           }

LMGet-Hosts($hostGroup)




} # End of Process
END {
Write-Verbose "All hosts added. "
} # End of End Process

} # End of CBLMAdd-Host function


Export-ModuleMember -Function Set-CBLMSDT
Export-ModuleMember -Function Move-CBLMHost
Export-ModuleMember -Function Add-CBLMHost
Export-ModuleMember -Function Remove-CBLMHost
Export-ModuleMember -Function Get-HostsInGroup