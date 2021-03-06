#This script will take all Cluster Disks out of Maintenance mode (not including the Quorum disk)

#Imports the failoverclusters module
Import-Module failoverclusters

#Takes all cluster disks out of Maintenance mode
Get-ClusterResource | ?{$_.ResourceType.Name -eq "Physical Disk"}| ?{$_.OwnerGroup.Name -ne "Cluster Group"} |Resume-ClusterResource

