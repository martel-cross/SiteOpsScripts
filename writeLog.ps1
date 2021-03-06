function writeLog ($content, $logFile = 'main')
{
    #Get log paths
    $logDir = (Split-Path $script:MyInvocation.MyCommand.Path -Parent) + '\log\'
    $logPath = $logDir + "$logFile" + '.log'
    
    #Check to see if log has been initiliazed
    #and initialize the log if not
    $logInit = $logFile + 'LogInitialized'
    
    if ((Test-Path -LiteralPath "variable:script:$logInit") -eq $FALSE -or `
       (Get-Variable -Name "$logInit" -Scope 'Script') -eq $FALSE)
    {
        initializeLog $logFile $logDir $logPath
        
        New-Variable -Name "$logInit" -Value $TRUE -Scope 'Script'        
    }
    
    #Write the content to the log
    foreach ($obj in $content)
    {
        Out-File -InputObject ((Get-Date).ToString() + ':  ' + $obj) -FilePath $logPath -Append
    }
}


function initializeLog ($logFile, $logDir, $logPath)
{   
    #Create log directory if it doesn't exist
    if ((Test-Path $logDir) -eq $FALSE)
    {
        $catchOutput = New-Item $logDir -type Directory
    }
    #Keep a total of at most 3 old logs. Rename old logs
    elseif ((Test-Path $logPath) -eq $TRUE)
    {
        $arrPath = @($logPath,`
                     $logPath.Replace('.log', 'OLD1.log'),`
                     $logPath.Replace('.log', 'OLD2.log'),`
                     $logPath.Replace('.log', 'OLD3.log'))
        
        for ($i=2; $i -ge 0; $i--)
        {
            if ((Test-Path $arrPath[$i]) -eq $TRUE)
            {
                Move-Item -Path $arrPath[$i] -Destination $arrPath[$i + 1] -Force
            }
        }        
    }
    
    $str = "$logFile log created at: " + (Get-Date).ToString()
    
    Out-File -InputObject $str -FilePath $logPath
}