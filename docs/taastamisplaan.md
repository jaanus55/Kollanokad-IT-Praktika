# Taastamisplaan

1. Kontrolli füüsilise serveri ja RAID seisundit.
2. Käivita Proxmox ning kontrolli `pveversion`, `pvesm status` ja VM-ide olekut.
3. Taasta DC1 ja DC2 varukoopiast. Kontrolli AD replikatsiooni käsuga `repadmin /replsummary`.
4. Taasta DHCP failover ja kontrolli klientide IP jagamist.
5. Taasta andmebaasiserver ja WordPressi andmebaas.
6. Taasta veeb1/veeb2 failid viimasest WordPressi varukoopiast.
7. Kontrolli HAProxy lehte `veeb.kollanokad.praktika`.
8. Kontrolli monitooringut `monitor.kollanokad.praktika` ja SIEM-i `siem.kollanokad.praktika`.
9. Kontrolli, et VPN, UniFi ja Vaultwarden töötavad.
