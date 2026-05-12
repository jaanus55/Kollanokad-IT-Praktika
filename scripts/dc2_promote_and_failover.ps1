<#
Seadistab Windows Server Core masina DC2 teiseks domeenikontrolleriks ja DHCP failover partneriks.
Käivita DC2-s administraatorina pärast võrgu ja DNS-i seadistamist.
#>
Rename-Computer -NewName "DC2" -Restart

# Pärast taaskäivitust:
Install-WindowsFeature AD-Domain-Services,DNS,DHCP,FS-FileServer,FS-DFS-Namespace,FS-DFS-Replication -IncludeManagementTools
Install-ADDSDomainController -DomainName "kollanokad.praktika" -InstallDNS -Credential (Get-Credential "KOLLANOKAD\Administrator") -Force

# DHCP failover luuakse DC1 pealt:
# Add-DhcpServerv4Failover -ComputerName DC1 -Name "DC1-DC2-Failover" -PartnerServer DC2.kollanokad.praktika -ScopeId 172.18.10.0 -LoadBalancePercent 50 -SharedSecret "MuudaSeeSaladus"
