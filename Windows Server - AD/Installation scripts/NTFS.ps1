#NTFS Permissions (Cast)
#(get-acl -Path "C:\Shares\Cast").Access
$identity = 'thematrix\CastUsers'
$rights = 'Modify'
$inheritance = 'ContainerInherit, ObjectInherit'
$propagation = 'None'
$type = 'Allow'

$Acl = Get-Acl -Path "S:\Cast"

$ADD = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$REMOVES = $Acl.Access | Where-Object {($_.IdentityReference -eq 'BUILTIN\Users')}

$Acl.AddAccessRule($ADD)
$Acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path "S:\Cast" -AclObject $Acl

$Acl = Get-Acl -Path "S:\Cast"
foreach ($REMOVE in $REMOVES) {
    $Acl.RemoveAccessRule($REMOVE)
}

Set-Acl -Path "S:\Cast" -AclObject $Acl


#NTFS Permissions (Crew)
#(get-acl -Path "C:\Shares\Crew").Access
$identity = 'thematrix\CrewUsers'
$rights = 'Modify'
$inheritance = 'ContainerInherit, ObjectInherit'
$propagation = 'None'
$type = 'Allow'

$Acl = Get-Acl -Path "S:\Crew"

$ADD = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)
$REMOVES = $Acl.Access | Where-Object {($_.IdentityReference -eq 'BUILTIN\Users')}

$Acl.AddAccessRule($ADD)
$Acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path "S:\Crew" -AclObject $Acl

$Acl = Get-Acl -Path "S:\Crew"
foreach ($REMOVE in $REMOVES) {
    $Acl.RemoveAccessRule($REMOVE)
}

Set-Acl -Path "S:\Crew" -AclObject $Acl