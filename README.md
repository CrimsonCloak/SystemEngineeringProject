# System Engineering Project

## Opzet

System Engineering Project was een opleidingsonderdeel binnen de opleiding Toegepaste Informatica aan de HOGENT. Het idee is om een complexe IT-infrastructuur op te stellen, te laten functioneren en dit geautomatiseerd laten opzetten. De eindevaluatie van dit project bestond voor een deel ook op het uitrollen van de netwerkapparatuur binnen een beperkte tijd van 1,5 uur. Deze repository geeft een goed idee van de omvang en scope van het project, en welke vaardigheden we hier als team hebben ontwikkeld.

### Netwerk
De volgende netwerktopologie werd uitgewerkt voor dit project. Het volledige netwerk alsook de bijhorende functionaliteiten en componentent (met uitzondering van de interne servers en end devices) werden uitgewerkt en geïmplementeerd in [Packet Tracer](/Netwerkconfiguratie/Netwerktopologie.pkt). Dit geef een mooi visueel overzicht van welke toestellen en functionaliteiten  verwerkt zitten binnen het project. De selectie van de private IP-adressen en de VLANS werden opgenomen in volgende [IP-adrestabel](/Netwerkconfiguratie/IP_Address_Table.xlsx). Merk op dat het effectieve uitrollen van deze apparatuur niét virtueel is verlopen! De end devices en interne servers werden gesimuleerd via Virtualbox, maar met Bridged Adapters werden deze aangesloten op fysieke netwerkapparatuur die we ter beschikking hadden in het netwerklokaal van de HOGENT. 





## Componenten

Volgende functionaliteiten zijn verwerkt binnen de IT-infrastructuur:
- [Active Directory Domeincontroller](/Windows%20Server%20-%20AD/) : Windows-Server 2019 (CLI) met functie van Active Directory Domeincontroller en DNS-server
- [Webserver](AlmaLinux%20-%20Webserver/): AlmaLinux met functie van Apache Webserver, Wordpress als CMS, Rallly-server, nginx reverse proxy.
- [Email Exchange](/Windows%20Server%20-%20Email/): Windows Server 2019 (CLI)  met functie van Exchange Server (2019)
- [Matrix.org](/AlmaLinux%20-%20Matrix.org/): AlmaLinux met functie van Synapse-server en Matrix.org server.
- [Monitoring server](/AlmaLinux%20-%20Monitoring/): AlmaLinux met functie van Grafana-Server en Prometheus. Elke interne server heeft een specifieke exporter waarvan men data van kan scrapen die wordt gevisualiseerd aan de hand van Grafana-dashboards. UptimeKuma wordt ook gebruikt om uptime te monitoren aan de hand van pingtesten.
- [TFTP-server](/AlmaLinux%20-%20TFTP/): AlmaLinux met functie van een TFTP-server. Wordt gebruikt om netwerkconfiguratie over te zetten op Cisco-netwerkapparatuur (running-configs worden opgeslagen na voorbereide configuratie en rechtstreeks op de switches gezet). In geval van nood en voor redundantie zijn ook de nodige [commando's voor configuraties](/Netwerkconfiguratie/network.md) opgenomen.



## Werkwijze

## Groepsleden

| Naam     | GitHub gebruikersnaam                   |
| :---     | :---                                    |
| Alexander Veldeman | [Alexander Veldeman](https://github.com/CrimsonCloak) |
| Ferre De Belie | [Ferre De Belie](https://github.com/Ferredb) |
| Lars Van Craenem | [Lars Van Craenem](https://github.com/LarsVC4) |
| Quinten Moreels | [Quinten Moreels](https://github.com/QuintenMoreels-HOGENT) |
| Joren Vekeman | [Joren Vekeman](https://github.com/jvekeman) |

