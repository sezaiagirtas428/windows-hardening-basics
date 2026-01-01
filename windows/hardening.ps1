# Firewall hardening (basic)
Write-Output "Configuring Windows Firewall..."

netsh advfirewall set allprofiles state on
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

Write-Output "Firewall enabled and inbound default set to block."
# Service hardening (basic)
Write-Output "Disabling unnecessary services..."

sc config "RemoteRegistry" start= disabled
sc stop "RemoteRegistry"

Write-Output "RemoteRegistry service disabled."
