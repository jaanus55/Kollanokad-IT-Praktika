<#
.SYNOPSIS
  Loob AD OU-d, grupid ja kasutajad kasutajad.csv failist.
.DESCRIPTION
  - Domeen: kollanokad.praktika
  - Skript kontrollib OU olemasolu.
  - Skript kontrollib grupi olemasolu.
  - Skript loob kasutaja ainult juhul, kui seda veel ei ole.
  - Sisselogimisnimi on kujul eesnime esimene täht + perenimi.
  - Fail võib olla TAB-eraldajaga, sest praktikas selgus, et kasutajad.csv oli TABiga eraldatud.
#>
Import-Module ActiveDirectory

$Domain = Get-ADDomain
$DomainDN = $Domain.DistinguishedName
$DnsRoot = $Domain.DNSRoot
$CsvPath = "C:\ADscripts\kasutajad.csv"

function Convert-ToSamAccountName {
    param([string]$FirstName, [string]$LastName)
    $sam = ($FirstName.Substring(0,1) + $LastName).ToLower()
    $sam = $sam -replace "õ","o" -replace "ä","a" -replace "ö","o" -replace "ü","u" -replace "š","s" -replace "ž","z"
    return $sam
}

function Ensure-OU {
    param([string]$Name, [string]$Path)
    $existing = Get-ADOrganizationalUnit -LDAPFilter "(ou=$Name)" -SearchBase $Path -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        Write-Host "OU loodud: $Name"
    }
}

function Ensure-Group {
    param([string]$Name, [string]$Path)
    if (-not (Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $Name -SamAccountName $Name -GroupCategory Security -GroupScope Global -Path $Path
        Write-Host "Grupp loodud: $Name"
    }
}

# OU struktuur vastavalt ülesandele
Ensure-OU -Name "ARVUTID" -Path $DomainDN
Ensure-OU -Name "Staff" -Path "OU=ARVUTID,$DomainDN"
Ensure-OU -Name "Töötajad" -Path "OU=ARVUTID,$DomainDN"
Ensure-OU -Name "KASUTAJAD" -Path $DomainDN
foreach ($ou in @("IT","Staff","Töötajad","Kontor","Raamatupidamine")) {
    Ensure-OU -Name $ou -Path "OU=KASUTAJAD,$DomainDN"
}

# Praktikas kasutatud failis olid väljad: Name, Username, Password, OU.
# Kui Username puudub, luuakse see automaatselt kujul eesnimi+perenimi reegli järgi.
$users = Import-Csv $CsvPath -Delimiter "`t"
foreach ($user in $users) {
    $name = $user.Name.Trim()
    $parts = $name.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    $firstName = $parts[0]
    $lastName = $parts[-1]
    $username = if ($user.Username) { $user.Username.Trim() } else { Convert-ToSamAccountName $firstName $lastName }
    $password = ConvertTo-SecureString $user.Password.Trim() -AsPlainText -Force
    $ouName = $user.OU.Trim()
    $ouDN = "OU=$ouName,OU=KASUTAJAD,$DomainDN"

    Ensure-Group -Name $ouName -Path $ouDN

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name $name `
            -GivenName $firstName `
            -Surname $lastName `
            -SamAccountName $username `
            -UserPrincipalName "$username@$DnsRoot" `
            -AccountPassword $password `
            -Enabled $true `
            -Path $ouDN `
            -ChangePasswordAtLogon $true
        Write-Host "Kasutaja loodud: $username"
    } else {
        Write-Host "Kasutaja juba olemas: $username"
    }

    Add-ADGroupMember -Identity $ouName -Members $username -ErrorAction SilentlyContinue
}
