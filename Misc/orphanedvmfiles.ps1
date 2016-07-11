Clear-content datastoreorphans.csv
$fileheader = "datastore,path,file,size,moddate"
add-content Datastoreorphans.csv $fileheader
$fileMgr = Get-View FileManager
$arrUsedDisks = Get-View -ViewType VirtualMachine | % {$_.Layout} | % {$_.Disk} | % {$_.DiskFile}
$arrDS = Get-Datastore | Sort-Object -property Name
foreach ($strDatastore in $arrDS) {
	#Write-Host $strDatastore.Name
	$ds = Get-Datastore -Name $strDatastore.Name | % {Get-View $_.Id}
	$dc = $ds.Datacenter.Extensiondata
	$fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
	$fileQueryFlags.FileSize = $true
	$fileQueryFlags.FileType = $true
	$fileQueryFlags.Modification = $true
	$searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
	$searchSpec.details = $fileQueryFlags
	$searchSpec.matchPattern = "*.vmdk"
	$searchSpec.sortFoldersFirst = $true
	$dsBrowser = Get-View $ds.browser
	$rootPath = "[" + $ds.Name + "]"
	$searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)

	foreach ($folder in $searchResult)
	{
		foreach ($fileResult in $folder.File){
		$delete = "False"
			if ($fileResult.Path)
			{
				if (-not ($arrUsedDisks -contains ($folder.FolderPath + $fileResult.Path))){
					$row = "" | Select DS, Path, File, Size, ModDate
					$row.DS = $strDatastore.Name
					$row.Path = $folder.FolderPath
					$row.File = $fileResult.Path
					$row.Size = $fileResult.FileSize
					$row.ModDate = $fileResult.Modification
					$addtofile =$row.ds +","+$row.path+","+$row.file+","+$row.size+","+$row.moddate
					if (($row.file -notlike "*disk-vdcs*")){
					add-content datastoreorphans.csv $addtofile}
					# if (($row.file -notlike "*disk-vdcs*")){$delete = "True"}
					# Write-host "Delete Flag is set as " $delete
					# $row
					# if($Delete -eq "True"){
					#start-sleep -seconds 5
                   #$dsBrowser.DeleteFile($folder.FolderPath + $fileresult.Path)
					#$fileMgr.DeleteDatastoreFile($folder.FolderPath)
					
					# }
					
				}
			}
		}
	}
} 
Send-mailmessage -to Siteopssupport@careerbuilder.com -from Siteops@careerbuilder.com -SmtpServer relay.careerbuilder.com -subject "VMDK Orphan Report"  -body "Orphaned VMDK files in datastores, see attached file" -attachment datastoreorphans.csv