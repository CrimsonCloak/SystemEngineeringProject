#Create Users
$Users = Import-Csv .\Users.csv -Delimiter ";"
foreach ($User in $Users) {
    $email = $User.Email
    Enable-Mailbox -Identity $email
    
}