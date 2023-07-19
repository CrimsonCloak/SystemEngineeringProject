#Controle of DNS geïnstalleerd is kan aan de hand van volgend commando

Get-WindowsFeature –Name *DNS*

#Indien niet geïnstalleerd volgend commando (+ management tools)

Add-WindowsFeature –Name DNS -IncludeManagementTools

#Set Forwarder
Set-DnsServerForwarder -IPAddress "8.8.8.8"

#Reverse DNS
Add-DnsServerPrimaryZone -NetworkId "10.10.20.0/24" -ReplicationScope Domain # VLAN 20 - Interne Server
Add-DnsServerPrimaryZone -NetworkId "10.10.30.0/24" -ReplicationScope Domain # VLAN 30 - Werkstations crew
Add-DnsServerPrimaryZone -NetworkId "10.10.40.0/24" -ReplicationScope Domain # VLAN 40 - Werkstations cast
Add-DnsServerPrimaryZone -NetworkId "10.10.50.0/24" -ReplicationScope Domain # VLAN 50 - Routers & Internet

### REVERSE DNS VOOR IPV6
#Maak 4 zones voor de netwerken
Add-DnsServerPrimaryZone -NetworkId "2001:db8:acad:2::/64" -ReplicationScope Domain # VLAN 20 - Interne Server
Add-DnsServerPrimaryZone -NetworkId "2001:db8:acad:3::/64" -ReplicationScope Domain # VLAN 30 - Werkstations crew
Add-DnsServerPrimaryZone -NetworkId "2001:db8:acad:4::/64" -ReplicationScope Domain # VLAN 40 - Werkstations cast
Add-DnsServerPrimaryZone -NetworkId "2001:db8:acad:5::/64" -ReplicationScope Domain # VLAN 50 - Routers & Internet
#Remove & Add DNS A, AAAA en Ptr voor host
Remove-DnsServerResourceRecord -ZoneName "thematrix.eiland-x.be" -RRType "A" -Name "$env:COMPUTERNAME"
#Add-DnsServerResourceRecordA -Name "$env:COMPUTERNAME" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv4Address "10.10.20.2" -AllowUpdateAny
#Add-DnsServerResourceRecordAAAA TODO # Resource record IPv6
#Add-DnsServerResourceRecordPtr -Name "2" -ZoneName "20.10.10.in-addr.arpa" -PtrDomainName "thematrix.eiland-x.be" #Pointer record IPv4
#Add-DnsServerResourceRecordPtr -Name "?" -ZoneName "IPV6?-addr.arpa" -PtrDomainName "thematrix.eiland-x.be" #Pointer record IPv6 TODO

# Add A-records, AAA-records and PTR records for all other hosts
    # VLAN 20: Interne servers
        # Router ?

        # agentsmith (domain controller) 10.10.20.2 | 2001:db8:acad:2::2
        Add-DnsServerResourceRecordA -Name "agentsmith" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv4Address "10.10.20.2" -AllowUpdateAny #Resource record IPv4
        Add-DnsServerResourceRecordAAAA -Name "agentsmith" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv6Address "2001:db8:acad:2::2" -AllowUpdateAny # Resource record IPv6
        # Add-DnsServerResourceRecordPtr -Name "2" -ZoneName "0.20.10.10.in-addr.arpa" -PtrDomainName "agentsmith.thematrix.eiland-x.be" #Pointer record IPv4 -> deze worden automatisch aangemaakt!
        # Add-DnsServerResourceRecordPtr -Name "::2" -ZoneName "2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.d.a.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -PtrDomainName "agentsmith.thematrix.eiland-x.be" -AllowUpdateAny #Pointer record IPv6 -> deze worden automatisch aangemaakt!

        # trinity (webserver) 10.10.20.3 | 2001:db8:acad:2::3
        Add-DnsServerResourceRecordA -Name "trinity" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv4Address "10.10.20.3" -AllowUpdateAny #Resource record IPv4
        Add-DnsServerResourceRecordAAAA -Name "trinity" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv6Address "2001:db8:acad:2::3" -AllowUpdateAny # Resource record IPv6
        # Add-DnsServerResourceRecordPtr -Name "3" -ZoneName "0.20.10.10.in-addr.arpa" -PtrDomainName "trinity.thematrix.eiland-x.be" #Pointer record IPv4 -> deze worden automatisch aangemaakt!
        # Add-DnsServerResourceRecordPtr -Name "::3" -ZoneName "3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.d.a.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -PtrDomainName "trinity.thematrix.eiland-x.be" -AllowUpdateAny #Pointer record IPv6 -> deze worden automatisch aangemaakt!
        
        
        # neo (email exchange) 10.10.20.4 | 2001:db8:acad:2::4
        Add-DnsServerResourceRecordA -Name "neo" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv4Address "10.10.20.4" -AllowUpdateAny #Resource record IPv4
        Add-DnsServerResourceRecordAAAA -Name "neo" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv6Address "2001:db8:acad:2::4" -AllowUpdateAny # Resource record IPv6
        # Add-DnsServerResourceRecordPtr -Name "4" -ZoneName "0.20.10.10.in-addr.arpa" -PtrDomainName "neo.thematrix.eiland-x.be" #Pointer record IPv4 -> deze worden automatisch aangemaakt!
        # Add-DnsServerResourceRecordPtr -Name "::4" -ZoneName "4.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.d.a.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -PtrDomainName "neo.thematrix.eiland-x.be" -AllowUpdateAny #Pointer record IPv6 -> deze worden automatisch aangemaakt!

        # theoracle (matrix.org) 10.10.20.5 | 2001:db8:acad:2::5
        Add-DnsServerResourceRecordA -Name "theoracle" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv4Address "10.10.20.5" -AllowUpdateAny #Resource record IPv4
        Add-DnsServerResourceRecordAAAA -Name "theoracle" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv6Address "2001:db8:acad:2::5" -AllowUpdateAny # Resource record IPv6
        # Add-DnsServerResourceRecordPtr -Name "5" -ZoneName "0.20.10.10.in-addr.arpa" -PtrDomainName "theoracle.thematrix.eiland-x.be" -AllowUpdateAny #Pointer record IPv4 -> deze worden automatisch aangemaakt!
        # Add-DnsServerResourceRecordPtr -Name "::5" -ZoneName "5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.d.a.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -PtrDomainName "theoracle.thematrix.eiland-x.be" -AllowUpdateAny #Pointer record IPv6 -> deze worden automatisch aangemaakt!


        # dozer (monitoring) 10.10.20.6 | 2001:db8:acad:2::6
        Add-DnsServerResourceRecordA -Name "dozer" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv4Address "10.10.20.6" -AllowUpdateAny #Resource record IPv4
        Add-DnsServerResourceRecordAAAA -Name "dozer" -ZoneName "thematrix.eiland-x.be" -CreatePtr -IPv6Address "2001:db8:acad:2::6" -AllowUpdateAny # Resource record IPv6
        # Add-DnsServerResourceRecordPtr -Name "6" -ZoneName "0.20.10.10.in-addr.arpa" -PtrDomainName "dozer.thematrix.eiland-x.be" #Pointer record IPv4 -> deze worden automatisch aangemaakt!
        # Add-DnsServerResourceRecordPtr -Name "::6" -ZoneName "6.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.0.0.d.a.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -PtrDomainName "dozer.thematrix.eiland-x.be" -AllowUpdateAny #Pointer record IPv6 -> deze worden automatisch aangemaakt!

        Add-DnsServerResourceRecordA -Name "@" -ZoneName "thematrix.eiland-x.be" -IPv4Address "10.10.20.3" -AllowUpdateAny #Dit eens testen aub :)


    # VLAN 30: Werkstations crew
        # Toevoegen van 2 PC's ?

    # VLAN 40: Werkstations cast
        # Toevoegen van 2 PC's ?

    # VLAN 50:Routers en internet
        # pointer records nodig hier?


    
# Add CNAME-records (www for webserver,imap for mail,...)

#Dozer
Add-DnsServerResourceRecordCName -Name "grafana" -HostNameAlias "trinity.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"
Add-DnsServerResourceRecordCName -Name "prometheus" -HostNameAlias "trinity.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"
Add-DnsServerResourceRecordCName -Name "uptime" -HostNameAlias "trinity.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"
#Trinity

Add-DnsServerResourceRecordCName -Name "www" -HostNameAlias "trinity.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"
Add-DnsServerResourceRecordCName -Name "rallly" -HostNameAlias "trinity.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"
Add-DnsServerResourceRecordCName -Name "www.rallly" -HostNameAlias "trinity.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"
# Add MX record for Email Exchange
Add-DnsServerResourceRecordMX -Preference 50  -Name "." -TimeToLive 02:00:00 -MailExchange "neo.thematrix.eiland-x.be" -ZoneName "thematrix.eiland-x.be"




