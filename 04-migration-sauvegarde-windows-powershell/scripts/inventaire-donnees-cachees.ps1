# Inventaire des données "cachées" avant migration d'un poste Windows
# (mails locaux, clé produit, VPN, certificats)
# À lancer dans PowerShell en tant qu'administrateur.

Write-Host "=== Fichiers mails locaux (.pst/.ost) ===" -ForegroundColor Cyan
Get-ChildItem -Path C:\Users\ -Include *.pst,*.ost -Recurse -ErrorAction SilentlyContinue

Write-Host "`n=== Clé produit Windows ===" -ForegroundColor Cyan
Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object {$_.PartialProductKey} | Select-Object Name, PartialProductKey

Write-Host "`n=== VPN configurés ===" -ForegroundColor Cyan
Get-VpnConnection

Write-Host "`n=== Certificats utilisateur ===" -ForegroundColor Cyan
Get-ChildItem -Path Cert:\CurrentUser\My

Write-Host "`n=== Certificats machine ===" -ForegroundColor Cyan
Get-ChildItem -Path Cert:\LocalMachine\My
