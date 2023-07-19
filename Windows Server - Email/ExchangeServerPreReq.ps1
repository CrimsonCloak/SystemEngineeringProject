Install-WindowsFeature RSAT-ADDS

if (!(Test-Path .\vcredist.exe)) {
Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe" -OutFile "vcredist.exe"
}

Start-Process -Wait -Filepath vcredist.exe -ArgumentList "/quiet /accepteula /repair" -PassThru

if (!(Test-Path .\ucmaruntime.exe)) {
	Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe" -OutFile "ucmaruntime.exe"
}

Start-Process -Wait -Filepath ucmaruntime.exe -ArgumentList "/q /norestart" -PassThru

if (!(Test-Path .\ndp48.exe)) {
	Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe" -OutFile "ndp48.exe"
}

Start-Process -Wait -Filepath ndp48.exe -ArgumentList "/quiet /accepteula /norestart" -PassThru

if (!(Test-Path .\iisrewrite.exe)) {
	Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile "iisrewrite.msi"
}

Start-Process -Wait -Filepath iisrewrite.msi -ArgumentList "/quiet /norestart" -PassThru

Install-WindowsFeature Server-Media-Foundation, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS

Restart-Computer