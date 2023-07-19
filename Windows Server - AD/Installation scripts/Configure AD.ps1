$domainname = Read-Host "geef het domein naam in"
$netbiosname = $domainname.Split(".")[0]

Install-ADDSForest `
  -DomainName "$domainname" `
  -CreateDnsDelegation:$false `
  -DatabasePath "C:\Windows\NTDS" ` 
  -DomainMode "7" ` 
  -DomainNetbiosName "$netbiosname" ` 
  -ForestMode "7" ` 
  -InstallDns:$true ` 
  -LogPath "C:\Windows\NTDS" ` 
  -NoRebootOnCompletion:$True ` 
  -SysvolPath "C:\Windows\SYSVOL" ` 
  -Force:$true