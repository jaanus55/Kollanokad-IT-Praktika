<#
Seadistab kontori klientide DHCP ala VLAN 10 jaoks ja lisab põhilised valikud.
#>
Add-DhcpServerInDC -DnsName "DC1.kollanokad.praktika"
Add-DhcpServerv4Scope -Name "VLAN10-Kontori-kliendid" -StartRange 172.18.10.2 -EndRange 172.18.10.14 -SubnetMask 255.255.255.240 -State Active
Set-DhcpServerv4OptionValue -ScopeId 172.18.10.0 -Router 172.18.10.1 -DnsServer 172.18.30.10,172.18.30.11 -DnsDomain "kollanokad.praktika"
Restart-Service dhcpserver
