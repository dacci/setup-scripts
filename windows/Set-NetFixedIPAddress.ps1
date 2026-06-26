$ErrorActionPreference = "Stop"

$Ifs = Get-NetIPInterface -AddressFamily IPv4 -Dhcp Enabled
foreach ($If in $Ifs) {
  $Config = Get-NetIPConfiguration -InterfaceIndex $If.InterfaceIndex
  $Addresses = Get-NetIPAddress `
    -InterfaceIndex $If.InterfaceIndex `
    -AddressFamily IPv4 `
    -PrefixOrigin Dhcp

  Set-NetIPInterface `
    -InterfaceIndex $If.InterfaceIndex `
    -AddressFamily IPv4 `
    -Dhcp Disabled

  foreach ($Address in $Addresses) {
    New-NetIPAddress `
      -InterfaceIndex $If.InterfaceIndex `
      -AddressFamily IPv4 `
      -IPAddress $Address.IPAddress `
      -PrefixLength $Address.PrefixLength `
      -DefaultGateway $Config.IPv4DefaultGateway.NextHop
  }

  if ($Config.DNSServer.ServerAddresses -and $Config.DNSServer.ServerAddresses.Count -gt 0) {
    Set-DnsClientServerAddress `
      -InterfaceIndex $If.InterfaceIndex `
      -ServerAddresses $Config.DNSServer.ServerAddresses
  }
}
