C:\batch\grimreaper.vbs d:\Spool\HHMail\backup 7 delete rec
C:\batch\grimreaper.vbs d:\Spool\HHMail 45 delete rec
C:\batch\grimreaper.vbs d:\mailarchive 4 delete rec
C:\batch\grimreaper.vbs d:\mailarchive\oddbounces 6 delete rec

C:\batch\grimreaper.vbs d:\inetpub\mailroot 7 delete rec
C:\batch\grimreaper.vbs d:\inetpub\mailroot\Drop 2 delete rec
C:\batch\grimreaper.vbs d:\inetpub\mailsite 7 delete rec
C:\batch\grimreaper.vbs d:\inetpub\mailsite\Drop 2 delete rec
C:\batch\grimreaper.vbs d:\inetpub\mailemail 7 delete rec
C:\batch\grimreaper.vbs d:\inetpub\mailemail\Drop 2 delete rec
C:\batch\grimreaper.vbs d:\inetpub\mailapply 10 delete rec

C:\batch\grimreaper.vbs d:\infectedmail\mailapply delete rec
C:\batch\grimreaper.vbs d:\infectedmail\mailemail delete rec
C:\batch\grimreaper.vbs d:\infectedmail\mailsite delete rec
C:\batch\grimreaper.vbs d:\infectedmail\mailroot delete rec

C:\batch\grimreaper.vbs d:\Abbott\Archive 2 delete rec
C:\batch\grimreaper.vbs d:\Abbott\Attachments 2 delete rec
C:\batch\grimreaper.vbs d:\Newman\Archive 2 delete rec
C:\batch\grimreaper.vbs d:\Newman\Error 2 delete rec
C:\batch\grimreaper.vbs d:\recruiter\archive 7 delete
C:\batch\grimreaper.vbs d:\recruiter\failed 7 delete
C:\batch\grimreaper.vbs d:\EmailAnonymousResume\archive 7 delete
C:\batch\grimreaper.vbs d:\EmailAnonymousResume\failed 7 delete

cscript "C:\batch\grimreaper.vbs" "c:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files" 10 delete rec

cscript "C:\batch\grimreaper.vbs" "C:\Program Files (x86)\Cloudera\Flume 0.9.4\log" 7 delete rec

C:\batch\grimreaper.vbs d:\iislogs 5 delete rec
C:\batch\grimreaper.vbs c:\Logs 5 delete
C:\batch\grimreaper.vbs d:\Logs 5 delete rec 

C:\batch\grimreaper.vbs d:\Logs\stats\drop 1 delete 
C:\batch\grimreaper.vbs d:\Logs\stats\processed 0 delete 
 
C:\batch\grimreaper.vbs D:\Deployment\logs 14 delete rec 
C:\batch\grimreaper.vbs D:\DeploymentV3\logs 14 delete rec 
C:\batch\grimreaper.vbs D:\Deployment\tempFiles 1 delete rec 
C:\batch\grimreaper.vbs D:\DeploymentV3\tempFiles 1 delete rec 
cscript c:\batch\grimreaper.vbs "D:\deploymentv3\TallyAndTimings" 2 delete rec 
 
C:\batch\grimreaper.vbs d:\Logs\stats 2 delete 

cscript c:\batch\grimreaper.vbs "D:\platformstats\stat\processed" 0 delete rec
cscript c:\batch\grimreaper.vbs "D:\platformstats\stat" 2 delete rec

cscript c:\batch\grimreaper.vbs "c:\Program Files\DebugDiag\Logs" 3 delete rec

C:\Batch\ReapOldSettingControlXML.vbs

C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -File "c:\batch\SCPFolderReaper.ps1"

C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -File "c:\batch\FolderReaper.ps1"
