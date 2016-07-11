param($labelname)

$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'C:'"
$drive.name
Set-WmiInstance -input $drive -Arguments @{DriveLetter = 'C:'; Label=$labelname}
