New-SendConnector -Name "Alerting" -AddressSpaces * -Custom -DNSRoutingEnabled $false -SmartHosts 10.10.20.4 -SmartHostAuthMechanism None
#& F:\Scripts\Install-AntiSpamAgents.ps1
#Set-TransportConfig -InternalSMTPServers @{Add="10.10.20.4"}