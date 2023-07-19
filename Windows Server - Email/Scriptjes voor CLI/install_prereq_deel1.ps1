#Installeren van Processes
Start-Process -Wait -Filepath ".\Installers\rewrite_amd64_en-US.msi" -ArgumentList "/quiet /norestart" -PassThru
Start-Process -Wait -Filepath ".\Installers\ndp48-x86-x64-allos-enu(1).exe" -ArgumentList "/quiet /accepteula /norestart" -PassThru
Start-Process -Wait -Filepath ".\Installers\vcredist_x64.exe" -ArgumentList "/quiet /accepteula /repair" -PassThru
#Installeren WindowsFeatures

#Restart-Computer