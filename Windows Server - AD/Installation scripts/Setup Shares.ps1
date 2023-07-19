#Initialize Disk 1 (20gb)
Initialize-Disk -Number 1
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Shares"

#Make Share Folders (Persoonlijke Folder)
New-Item "S:\Profiles" -ItemType Directory
New-Item "S:\Homes" -ItemType Directory

#Make Shares (Persoonlijke Folder)
New-SmbShare -Name "Profiles" -Path "S:\Profiles" -FullAccess "Everyone"
New-SmbShare -Name "Homes" -Path "S:\Homes" -FullAccess "Everyone"


#Make Share Folders (Cast&Crew)
New-Item "S:\Cast" -ItemType Directory
New-Item "S:\Crew" -ItemType Directory

#Make Shares (Cast&Crew)
New-SmbShare -Name "Cast" -Path "S:\Cast" -FullAccess "Everyone"
New-SmbShare -Name "Crew" -Path "S:\Crew" -FullAccess "Everyone"