<# Lisab DNS A kirjed Linuxi serveritele ja võrguseadmetele. Käivita DC1-s. #>
$zone = "kollanokad.praktika"
$records = @{
  "fortigate"="172.18.1.1"; "switch"="172.18.1.2"; "unifi-ap"="172.18.1.3";
  "proxmox"="172.18.100.2"; "dc1"="172.18.30.10"; "dc2"="172.18.30.11";
  "veeb1"="172.18.30.40"; "veeb2"="172.18.30.41"; "koormusjaotur"="172.18.30.42";
  "veeb"="172.18.30.42"; "docker"="172.18.30.50"; "andmebaas"="172.18.30.51";
  "monitor"="172.18.30.52"; "siem"="172.18.30.53"
}
foreach ($name in $records.Keys) {
    $ip = $records[$name]
    if (-not (Get-DnsServerResourceRecord -ZoneName $zone -Name $name -ErrorAction SilentlyContinue)) {
        Add-DnsServerResourceRecordA -ZoneName $zone -Name $name -IPv4Address $ip
    }
}
