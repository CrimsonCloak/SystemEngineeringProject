Rename-Computer -NewName "neo"
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.20.4 -PrefixLength 24 -DefaultGateway "10.10.20.1"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.10.20.2"
Add-Computer -ComputerName NEO -LocalCredential NEO\vboxuser -DomainName thematrix.eiland-x.be -Credential THEMATRIX\Administrator -Force