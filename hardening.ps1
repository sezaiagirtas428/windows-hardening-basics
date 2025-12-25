Write-Output "Starting basic Windows hardening..."

# Disable Guest account
net user Guest /active:no

Write-Output "Guest account disabled."
