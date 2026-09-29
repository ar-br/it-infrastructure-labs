# Compare le nombre de fichiers et de dossiers entre la source et la sauvegarde.
# Adapter $source et $dest avant de lancer.

$source = "$env:USERPROFILE\Desktop\Inventaire_2026-09-15"
$dest   = "E:\Inventaire_2026-09-15"

$srcF = (Get-ChildItem $source -Recurse -File).Count
$srcD = (Get-ChildItem $source -Recurse -Directory).Count
$dstF = (Get-ChildItem $dest -Recurse -File).Count
$dstD = (Get-ChildItem $dest -Recurse -Directory).Count

Write-Host "SOURCE      : $srcF fichiers / $srcD dossiers" -ForegroundColor Cyan
Write-Host "DESTINATION : $dstF fichiers / $dstD dossiers" -ForegroundColor Cyan

if ($srcF -eq $dstF -and $srcD -eq $dstD) {
    Write-Host "OK - Copie complete" -ForegroundColor Green
} else {
    Write-Host "ATTENTION - Difference detectee" -ForegroundColor Red
}
