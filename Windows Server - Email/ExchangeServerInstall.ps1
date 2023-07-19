$mountedDrive = Mount-DiskImage -ImagePath ".\ExchangeServer.iso" -PassThru

Add-PartitionAccessPath -DiskNumber $mountedDrive.Number -PartitionNumber 1 -AssignDriveLetter E

E:\Setup.exe /m:install /roles:mb /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /InstallWindowsComponents /OrganizationName:neo