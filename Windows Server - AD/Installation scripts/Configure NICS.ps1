$ipofwan = Read-Host "Geef het oude ip adres van het WAN"

#WAN
$wan = Get-NetIPAddress | Where-Object {$_.IPAddress -eq "$ipofwan"}
$wan_name = $wan.InterfaceAlias

Rename-NetAdapter "$wan_name" -NewName "WAN"

$oldipoflan = Read-Host "Geef het oude ip adres van het LAN"

#LAN
$lan = Get-NetIPAddress | Where-Object {$_.IPAddress -like "$oldipoflan"}
$lan_name = $lan.InterfaceAlias

$ipoflan = read-host "Geef het nieuwe ip adres op van het LAN"
$prefix = read-host "Geef de prefix lengte van dit adres"
$dg = read-host "Geef de default gateway op van het LAN"

Rename-NetAdapter "$lan_name" -NewName "LAN"
New-NetIPAddress -InterfaceAlias "LAN" -IPAddress "$ipoflan" -PrefixLength "$prefix" -DefaultGateway "$dg"

Set-DnsClientServerAddress -InterfaceAlias "LAN" -ServerAddresses "127.0.0.1"
