#  group policies:
# 	1. Enkel directors hebben toegang tot control panel
# 	2. Niemand kan toolbars toevoegen aan de taakbalk
# 	3. Cast heeft geen toegang tot properties van netwerkadapters
#   4. Disablen van local user accounts op de computers -> Noodzakelijk?
	



# 1. UserConfiguration/Policies/Administrative templates/Control Panel -> Prohibit access to Control Panel and PC Settings (dit applyen op alle anderen behalve director OU?)

# Make the group policy
New-GPO -Name "ControlPanelProhibition" -Comment "GPO om iedereen behalve de director OU toegang tot control panel te verbieden" 

# Actually edit the group policy so it works
Set-GPRegistryValue -Name "ControlPanelProhibition" -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'   -ValueName 'NoControlPanel' -Value 1  -Type Dword

# Link the group policy to the correct ou('s)
New-GPLink -Name "ControlPanelProhibition" -Target "OU=Cast,OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be" 


# 2. UserConfiguration/Policies/Administrative templates/Start Menu and Taskbar -> Do not display any custom toolbars in the taskbar (applyen op iedereen)
New-GPO -Name "TaskbarProhibition" -Comment "GPO om iedereen het aanpassen van de taakbalk te verbieden" 

# Actually edit the group policy so it works
Set-GPRegistryValue -Name "TaskbarProhibition" -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'   -ValueName 'NoToolbarsOnTaskbar' -Value 1   -Type Dword

# Link the group policy to the correct ou('s)
New-GPLink -Name "TaskbarProhibition" -Target "OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be" 

# 3. UserConfiguration/Policies/Administrative templates/Network/NetworkConnections -> Prohibit access to properties of components of a LAN connection (applyen op cast OU)
New-GPO -Name "BlockNetworkAdapters" -Comment "GPO om de cast OU toegang tot de netwerkadapters property te verbieden" 

# Actually edit the group policy so it works
Set-GPRegistryValue -Name "BlockNetworkAdapters" -Key 'HKCU\Software\Policies\Microsoft\Windows\Network Connections'   -ValueName 'NC_LanProperties' -Value 1  -Type Dword
# Link the group policy to the correct ou('s)
New-GPLink -Name "BlockNetworkAdapters" -Target "OU=Cast,OU=DomainUsers,DC=thematrix,DC=eiland-x,DC=be" 

# # 4. Computer Configuration/Policies/Windows Settings/Security Settings/Local Policies/Security Options -> Accounts: Block Microsoft Accounts
# New-GPO -Name "BlockLocalAccounts" -Comment "GPO om inloggen met lokale acounts te verbieden"
# # Actually edit the group policy so it works
# Set-GPRegistryValue -Name "BlockLocalAccounts" -Key 
# # Link the group policy to the correct ou('s)

# New-GPLink -Name "BlockLocalAccounts" -Target "OU=DomainWorkstations,DC=thematrix,DC=local" 