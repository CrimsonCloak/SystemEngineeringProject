#OUs
New-ADOrganizationalUnit -Name "DomainWorkstations" -Path "DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "PCs" -Path "OU=DomainWorkstations,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Cast" -Path "OU=PCs,OU=DomainWorkstations,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Crew" -Path "OU=PCs,OU=DomainWorkstations,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Directors" -Path "OU=Crew,OU=PCs,OU=DomainWorkstations,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=DomainWorkstations,DC=thematrix,DC=eiland-x,DC=be"

New-ADOrganizationalUnit -Name "DomainUsers" -Path "DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Cast" -Path "OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Crew" -Path "OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Directors" -Path "OU=Crew,OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be"
New-ADOrganizationalUnit -Name "Producers" -Path "OU=Crew,OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be"

#Create Groups
New-ADGroup -Name "Crew Users" -SamAccountName CrewUsers -GroupCategory Security -GroupScope Global -DisplayName "Crew Users" -Path "CN=Users,DC=thematrix,DC=eiland-x,DC=be"
New-ADGroup -Name "Cast Users" -SamAccountName CastUsers -GroupCategory Security -GroupScope Global -DisplayName "Cast Users" -Path "CN=Users,DC=thematrix,DC=eiland-x,DC=be"
New-ADGroup -Name "Directors Users" -SamAccountName DirectorsUsers -GroupCategory Security -GroupScope Global -DisplayName "Directors Users" -Path "CN=Users,DC=thematrix,DC=eiland-x,DC=be"
New-ADGroup -Name "Producers Users" -SamAccountName ProducersUsers -GroupCategory Security -GroupScope Global -DisplayName "Producers Users" -Path "CN=Users,DC=thematrix,DC=eiland-x,DC=be"

#Create Users
$Users = Import-Csv .\CSV-Files\Users.csv -Delimiter ";"
$Domain = "thematrix.eiland-x.be"
foreach ($User in $Users) {
    $firstname = $User.Firstname
    $lastname = $User.Lastname
    $username = $User.Username
    $email = $User.Email
    $password = $User.Password
    $group = $User.Group
    $ou = $User.OU

    $user = New-ADUser -SamAccountName "$username" -UserPrincipalName "$username@$Domain" -Name "$firstname $lastname" -GivenName "$firstname" -Surname "$lastname" -Enabled $true -DisplayName "$lastname, $firstname" -Path "$ou" -EmailAddress "$email" -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) -CannotChangePassword $true -ProfilePath "\\$env:COMPUTERNAME\Profiles\$username" -HomeDrive "Z" -HomeDirectory "\\$env:COMPUTERNAME\Homes\$username"
    #Add Users To Group
    Add-ADGroupMember -Identity $group"Users" -Members "$username"
}


#Create PCs
$PCs = Import-Csv .\CSV-Files\PCs.csv -Delimiter ";"
foreach ($PC in $PCs) {
    $naam = $PC.Naam
    $ou = $PC.OU

    New-ADComputer -Name "$naam" -SAMAccountName "$naam" -Path "$ou" 
}