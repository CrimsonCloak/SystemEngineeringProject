# Networks

## VLAN 20 : Interne Servers (5 Servers)

Subnet IPV4: 10.10.20.0/24
Subnet IPV6: 2001:db8:acad:2::/64

IPV4:

- 10.10.20.1 | ROUTER
- 10.10.20.2 | agentsmith (Windows Server 2019) (Active Directory)
- 10.10.20.3 | trinity (AlmaLinux) (Webserver)
- 10.10.20.4 | neo (Windows Server 2019) (Exchange)
- 10.10.20.5 | theoracle (AlmaLinux) (Matrix.org)
- 10.10.20.6 | dozer (AlmaLinux) (Eigen keuze)
- 10.10.20.7 | tftp (AlmaLinux)

IPV6:

- 2001:db8:acad:2::1 | ROUTER
- 2001:db8:acad:2::2 | agentsmith (Windows Server 2019) (Active Directory)
- 2001:db8:acad:2::3 | trinity (AlmaLinux) (Webserver)
- 2001:db8:acad:2::4 | neo (Windows Server 2019) (Exchange)
- 2001:db8:acad:2::5 | theoracle (AlmaLinux) (Matrix.org)
- 2001:db8:acad:2::6 | dozer (AlmaLinux) (Eigen keuze)

## VLAN 30 : Werkstations crew (via dhcp)

Subnet IPV4: 10.10.30.0/24
Subnet IPV6: 2001:db8:acad:3::/64

2 end devices via dhcp

IPV4

- 10.10.30.1 | ROUTER
- Kunnen VLAN 20 en Internet bereiken

IPV6

- 2001:db8:acad:3::1 | ROUTER

## VLAN 40 : Werkstations cast (via dhcp)

Subnet IPV4: 10.10.40.0/24
Subnet IPV6: 2001:db8:acad:4::/64

4 end devices via dhcp vlan 40

IPV4

- 10.10.40.1 | ROUTER
- Kunnen Internet bereiken

IPV6

- 2001:db8:acad:4::1 | ROUTER

## VLAN 50 : Routers & Internet

Subnet IPV4: 10.10.50.0/24
Subnet IPV6: 2001:db8:acad:5::/64

IPV4

- Multilayer switch interface naar Router 10.10.50.1 (default route naar 10.10.50.2)
- Internet: NAT : 10.10.50.2

IPV6

- Multilayer switch interface naar Router 2001:db8:acad:5::1 (default route naar 2001:db8:acad:5::2)
- Internet: NAT : 2001:db8:acad:5::2

## Verdeling Multilayer Switch

- FA0/1: Switch 1
- FA0/2: Switch 2
- FA0/3: Switch 3
- Gig0/1: Router 1

## Verdeling Switch 1

- FA0/1: Multilayer Switch
- FA0/2: Interne server - Windows Server AD : agentsmith
- FA0/3: Interne server - Exchange email server : neo
- FA0/4: Interne server - AlmaLinux webserver : trinity
- FA0/5: Interne server - AlmaLinux matrix.org server : theoracle
- FA0/6: Interne server - AlmaLinux eigen keuze server : dozer

## Verdeling Switch 2

- FA0/1: Multilayer Switch
- FA0/2: End device - crew 1
- FA0/3: End device - crew 2
- FA0/4: End device - director 1 (crew)
- FA0/5: End device - director 2 (crew)

## Verdeling Switch 3

- FA0/1: Multilayer Switch
- FA0/2: End device - cast 1
- FA0/3: End device - cast 2

# Configuratie

## Switch 1

Switch(config)#vlan 20
Switch(config-vlan)#name Servers
Switch(config-vlan)#exit
Switch(config)#vlan 30
Switch(config-vlan)#name Crew
Switch(config-vlan)#exit
Switch(config)#vlan 40
Switch(config-vlan)#name Cast
Switch(config-vlan)#exit
Switch(config)#interface range f0/13 - 14
Switch(config-if-range)#switchport mode access
Switch(config-if-range)#switchport access vlan 40
Switch(config-if-range)#exit
Switch(config)#interface f0/1
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk allow vlan all
Switch(config-if)#exit
Switch(config)#interface g0/1
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk allow vlan all
Switch(config)#interface vlan 40
Switch(config-if)#ip address 10.10.40.10 255.255.255.0

## Switch 2

Switch(config)#vlan 40
Switch(config-vlan)#name Cast
Switch(config)#vlan 20
Switch(config-vlan)#name Servers
Switch(config-vlan)#exit
Switch(config)#vlan 30
Switch(config-vlan)#name Crew
Switch(config-vlan)#exit
Switch(config)#interface range f0/13 - 18
Switch(config-if-range)#switchport mode access
Switch(config-if-range)#switchport access vlan 20
Switch(config-if-range)#exit
Switch(config)#interface range f0/1-2
Switch(config-if-range)#switchport mode trunk
Switch(config-if-range)#switchport trunk allow vlan all
Switch(config-if-range)#exit
Switch(config)#interface g0/1
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk allow vlan all
Switch(config)#interface vlan 20
Switch(config-if)#ip address 10.10.20.10 255.255.255.0

## Switch 3

Switch(config)#vlan 20
Switch(config-vlan)#name Servers
Switch(config-vlan)#exit
Switch(config)#vlan 40
Switch(config-vlan)#name Cast
Switch(config-vlan)#exit
Switch(config)#vlan 30
Switch(config-vlan)#name Crew
Switch(config-vlan)#exit
Switch(config)#interface range f0/13 - 16
Switch(config-if-range)#switchport mode access
Switch(config-if-range)#switchport access vlan 30
Switch(config-if-range)#exit
Switch(config)#interface f0/1
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk allow vlan all
Switch(config-if)#exit
Switch(config)#interface g0/1
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk allow vlan all
Switch(config)#interface vlan 30
Switch(config-if)#ip address 10.10.30.10 255.255.255.0

## Multilayer Switch

Switch(config)#ip routing
Switch(config)#vlan 40
Switch(config-vlan)#name Cast
Switch(config-vlan)#vlan 30
Switch(config-vlan)#name Crew
Switch(config-vlan)#vlan 20
Switch(config-vlan)#name Servers
Switch(config-vlan)#exit
Switch(config)#interface range G1/0/1 - 3
Switch(config-if-range)#switchport mode trunk
Switch(config-if-range)#switchport trunk allowed vlan all
Switch(config-if-range)#exit
Switch(config)#interface vlan 40
Switch(config-if)#ip address 10.10.40.1 255.255.255.0
Switch(config-if)#exit
Switch(config)#interface vlan 30
Switch(config-if)#ip address 10.10.30.1 255.255.255.0
Switch(config-if)#exit
Switch(config)#interface vlan 20
Switch(config-if)#ip address 10.10.20.1 255.255.255.0
Switch(config-if)#exit
Switch(config)#interface G1/0/13
Switch(config-if)#no switchport
Switch(config-if)#ip address 10.10.50.1 255.255.255.0
Switch(config-if)#exit
Switch(config)#ip route 0.0.0.0 0.0.0.0 10.10.50.10
Switch(config)#ip dhcp excluded-address 10.10.40.1
Switch(config)#ip dhcp excluded-address 10.10.40.10
Switch(config)#ip dhcp pool Cast
Switch(dhcp-config)#network 10.10.40.0 255.255.255.0
Switch(dhcp-config)#default-router 10.10.40.1
Switch(dhcp-config)#dns-server 10.10.20.2
Switch(dhcp-config)#domain-name thematrix.local
Switch(dhcp-config)#exit
Switch(config)#ip dhcp excluded-address 10.10.30.1
Switch(config)#ip dhcp excluded-address 10.10.30.10
Switch(config)#ip dhcp pool Crew
Switch(dhcp-config)#network 10.10.30.0 255.255.255.0
Switch(dhcp-config)#default-router 10.10.30.1
Switch(dhcp-config)#dns-server 10.10.20.2
Switch(dhcp-config)#domain-name thematrix.local
Switch(dhcp-config)#exit
Switch(config)#ip dhcp excluded-address 10.10.20.1
Switch(config)#ip dhcp excluded-address 10.10.20.10

## acl

Switch(config)#ip access-list extended crew
Switch(config-ext-nacl)#deny ip 10.10.30.0 0.0.0.255 10.10.40.0 0.0.0.255
Switch(config-ext-nacl)#permit ip any any
Switch(config-ext-nacl)#exit
Switch(config)#interface vlan 30
Switch(config-if)#ip access-group crew in
Switch(config-if)#
Switch(config)#ip access-list extended cast
Switch(config-ext-nacl)#permit ip 10.10.40.0 0.0.0.255 10.10.50.0 0.0.0.255
Switch(config-ext-nacl)#permit ip 10.10.40.0 0.0.0.255 10.10.20.2 0.0.0.0
Switch(config-ext-nacl)#permit udp any host 255.255.255.255 eq 67
Switch(config-ext-nacl)#permit udp any host 255.255.255.255 eq 68
Switch(config-ext-nacl)#permit udp any host 255.255.255.255 eq 53
Switch(config-ext-nacl)#deny ip 10.10.40.0 0.0.0.255 10.10.30.0 0.0.0.255
Switch(config-ext-nacl)#permit ip any any
Switch(config-ext-nacl)#exit
Switch(config)#interface vlan 40
Switch(config-if)#ip access-group cast in
Switch(config-if)#

## Router

Router(config)#ip route 10.10.0.0 255.255.0.0 10.10.50.1
Router(config)#interface G0/0/1
Router(config-if)#ip address 10.10.50.10 255.255.255.0
Router(config-if)#ip nat inside
Router(config-if)#exit
Router(config)#interface G0/0/0
Router(config-if)#ip address dhcp
Router(config-if)#ip nat outside
Router(config-if)#exit
Router(config)#access-list 1 permit 10.10.0.0 0.0.255.255
Router(config)#ip nat inside source list 1 interface G0/0/0 overload
