<#
Paigaldab DC1 serverisse AD DS, DNS, DHCP, failiserveri ja WDS rollid.
Käivita PowerShell administraatorina Windows Server 2025 graafilises serveris.
#>
Rename-Computer -NewName "DC1" -Restart

# Pärast taaskäivitust käivita järgmine osa:
Install-WindowsFeature AD-Domain-Services,DNS,DHCP,FS-FileServer,FS-DFS-Namespace,FS-DFS-Replication,WDS -IncludeManagementTools

Install-ADDSForest `
  -DomainName "kollanokad.praktika" `
  -DomainNetbiosName "KOLLANOKAD" `
  -InstallDNS `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM parool") `
  -Force
