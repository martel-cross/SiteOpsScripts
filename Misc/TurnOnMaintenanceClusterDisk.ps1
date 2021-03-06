#This script will put all Cluster Disks into Maintenance mode (not including the Quorum disk)

#Imports the failoverclusters module
Import-Module failoverclusters


#Puts cluster disks into Maintenance mode
Get-ClusterResource | ?{$_.ResourceType.Name -eq "Physical Disk"} | ?{$_.OwnerGroup.Name -ne "Cluster Group"}  | Suspend-ClusterResource

