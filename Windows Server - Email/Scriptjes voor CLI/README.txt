Scriptjes werken enkel op een CLI Windows 2019 Server

Momenteel is alles hardcoded, ik zou dus nog niet aanraden om het zelf allemaal al uit te voeren.

Volgorde om uit te voeren:
1. prepare_VM.ps1 -> restart VM als dat niet vanzelf is gebeurd en vergeet niet om een bridged adaptor te gebruiken
2. install_prereq_deel1.ps1 -> Installers worden niet gedownload! Restart VM hierna
3. install_features.ps1 -> Restart VM hierna
4. install_prereq_deel2.ps1 -> Optioneel VM restarten
5. install_exchange.ps1 -> Restart VM hierna
6. create_mailboxes.ps1 -> Kan zijn dat één van de users error geeft

