# Crée sur le Bureau un dossier de sauvegarde daté, avec un sous-dossier par catégorie d'inventaire.

$date = Get-Date -Format "yyyy-MM-dd"
$base = "$env:USERPROFILE\Desktop\Inventaire_$date"

New-Item -ItemType Directory -Path $base -Force
New-Item -ItemType Directory -Path "$base\01_Dossiers_utilisateur" -Force
New-Item -ItemType Directory -Path "$base\02_Favoris_navigateur" -Force
New-Item -ItemType Directory -Path "$base\03_Reseau" -Force
New-Item -ItemType Directory -Path "$base\04_Logiciels_installes" -Force
New-Item -ItemType Directory -Path "$base\05_Donnees_planquees" -Force
New-Item -ItemType Directory -Path "$base\06_Comptes_Imprimantes" -Force
