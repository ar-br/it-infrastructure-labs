# Exporte la configuration réseau et la liste complète des logiciels installés dans des fichiers texte,
# pour les garder hors du poste avant la réinstallation.

ipconfig /all | Out-File "$env:USERPROFILE\Desktop\config_reseau.txt"

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null} | Sort-Object DisplayName | Out-File "$env:USERPROFILE\Desktop\logiciels_installes.txt"
