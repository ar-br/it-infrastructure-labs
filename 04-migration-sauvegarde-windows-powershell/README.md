# Migration et sauvegarde d'un poste Windows 10 — Inventaire PowerShell

> Réinstallation complète d'un poste sans perte de données : inventaire détaillé en PowerShell, sauvegarde sur support externe, vérification d'intégrité, réinitialisation de Windows, puis restauration des données, des favoris, des logiciels et des paramètres.

**Contexte :** Projet d'école (PPE 3) — Geneva Institute of Technology, module IT Essentials / ICT-187 · septembre 2026 · projet individuel

**Technologies :** Windows 10 Pro · PowerShell (registre, CIM/WMI, `Get-LocalUser`, `Get-Printer`, `Out-File`) · Microsoft Edge · VMware Workstation

### Compétences mises en œuvre

- Inventaire d'un poste en PowerShell : dossiers utilisateur, logiciels (registre HKLM/HKCU/Wow6432Node), réseau, comptes, groupe Administrateurs, imprimantes
- Repérage des données souvent oubliées : favoris, fichiers mail .pst/.ost, licences, VPN, certificats
- Sauvegarde structurée et datée, vérifiée par script (comptage fichiers/dossiers) et sur un autre poste
- Réinstallation de Windows, contrôle des pilotes, restauration et comparaison avant/après
- Scripts réutilisables : voir le dossier [`scripts/`](scripts/)

---

> Un poste de travail doit être entièrement réinstallé. Avant de tout effacer, je fais l'inventaire de ce qu'il contient, je sauvegarde les données sur une clé USB et je vérifie cette sauvegarde. Après la réinstallation, je restaure les données, les favoris et les paramètres essentiels, puis je documente la procédure pour qu'elle puisse être refaite sur un autre poste.

| Élément | Valeur |
|---|---|
| Module | IT Essentials — ICT-187, classe E1A |
| Environnement | Machine virtuelle VMware |
| Système | Windows 10 Professionnel |
| Nom du poste | `DESKTOP-CS3EK94` (avant) → `DESKTOP-7NH9ODD` (après) |
| Compte principal | `AR.BR` |
| Disque système | 79,6 Go (50,0 Go libres avant réinstallation) |
| Réseau | Ethernet, DHCP — `192.168.136.139` / `255.255.255.0` |
| Passerelle / DNS | `192.168.136.2` |
| Groupe de travail | `WORKGROUP` |
| Navigateur | Microsoft Edge |
| Support de sauvegarde | Clé USB 4 Go (3,74 Go utiles), FAT32 |
| Méthode de réinstallation | Réinitialiser ce PC → Réinstallation locale, suppression de tout |

---

## Introduction et objectifs

L'objectif de ce projet est de migrer un poste de travail vieillissant sans perdre aucune donnée : l'utilisateur doit retrouver, après la réinstallation, ses documents, ses favoris et ses paramètres essentiels.

Je réalise tout le projet sur une machine virtuelle VMware. Cela me permet de m'entraîner à une opération risquée (effacer complètement un poste) sans mettre en danger un vrai ordinateur, et de recommencer si quelque chose se passe mal.

La plupart des relevés sont faits avec **PowerShell lancé en tant qu'administrateur**. La ligne de commande est plus rapide que l'interface graphique pour interroger le système, et le résultat peut être copié dans un fichier texte pour servir de preuve.

Les étapes à réaliser sont les suivantes :

- **Étape 1** — Inventaire des données à conserver
- **Étape 2** — Sauvegarde sur un support externe
- **Étape 3** — Vérification de l'intégrité de la sauvegarde
- **Étape 4** — Réinstallation propre du système d'exploitation
- **Étape 5** — Réinstallation des logiciels
- **Étape 6** — Restauration des données et vérification
- **Étape 7** — Reconfiguration des paramètres essentiels
- **Étape 8** — Rédaction de la procédure (le présent document)

---

## Étape 1 — Inventaire des données à conserver

L'inventaire est la base de toute la migration : ce qui n'est pas repéré à cette étape ne sera pas sauvegardé, et sera donc perdu au formatage.

### 1.1 Dossiers de l'utilisateur

Je commence par ouvrir PowerShell en tant qu'administrateur. Les droits administrateur sont nécessaires pour pouvoir lire certaines informations système plus loin dans l'inventaire.

Je liste d'un seul coup le contenu des dossiers personnels de l'utilisateur : Documents, Bureau, Images, Téléchargements, Vidéos et Musique. La variable `$env:USERPROFILE` pointe automatiquement vers le profil de l'utilisateur connecté, ce qui rend la commande réutilisable sur n'importe quel poste.

```powershell
dir "$env:USERPROFILE\Documents"
dir "$env:USERPROFILE\Desktop"
dir "$env:USERPROFILE\Pictures"
dir "$env:USERPROFILE\Downloads"
dir "$env:USERPROFILE\Videos"
dir "$env:USERPROFILE\Music"
```

![Figure 1](https://hackmd.io/_uploads/rkLHrbuYfg.png)
*Figure 1 — Saisie des commandes `dir` sur les six dossiers personnels dans PowerShell administrateur*

![Figure 2](https://hackmd.io/_uploads/rywrSW_KMl.png)
*Figure 2 — Résultat : un dossier « test » dans Documents, un raccourci Microsoft Edge sur le Bureau, « Camera Roll » et « Saved Pictures » dans Images, un dossier dans Téléchargements*

On voit ainsi tous les dossiers et fichiers présents. Vidéos et Musique n'affichent rien : ils sont vides.

### 1.2 Favoris et profil du navigateur

Toujours dans PowerShell, je repère où Microsoft Edge stocke les données du profil. Les favoris sont l'un des oublis les plus fréquents lors d'une migration, car ils ne se trouvent pas dans les dossiers personnels habituels.

```powershell
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
```

![Figure 3](https://hackmd.io/_uploads/r1uHBZOKGe.png)
*Figure 3 — Contenu du dossier du profil Edge « Default » (cache, extensions, sessions…)*

Ce dossier contient tout le profil Edge. Pour cibler uniquement les favoris, j'affiche le fichier `Bookmarks` :

```powershell
Get-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"
```

![Figure 4](https://hackmd.io/_uploads/HJYHB-OKzg.png)
*Figure 4 — Le fichier `Bookmarks` (2 802 octets) qui contient les favoris Edge*

Je note les deux emplacements :

| Donnée | Emplacement |
|---|---|
| Favoris Edge | `C:\Users\AR.BR\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks` |
| Profil complet Edge | `C:\Users\AR.BR\AppData\Local\Microsoft\Edge\User Data\Default` |

### 1.3 Paramètres réseau

Je relève ensuite la configuration réseau complète. Si le poste avait une IP fixe, il faudrait la ressaisir à l'identique après la réinstallation, sinon il ne serait plus joignable par les autres machines.

```powershell
ipconfig /all
```

![Figure 5](https://hackmd.io/_uploads/B1YBrWOFMx.png)
*Figure 5 — `ipconfig /all` : poste DESKTOP-CS3EK94, DHCP activé, IPv4 192.168.136.139, masque 255.255.255.0, passerelle et DNS 192.168.136.2*

Cette commande affiche l'adresse IP, l'état du DHCP, le masque, la passerelle, les serveurs DNS et l'adresse physique de la carte. On voit que le poste est en **DHCP** : il n'y a donc pas d'adresse fixe à reconfigurer à la main.

J'affiche maintenant le domaine ou le groupe de travail. Cette information dit si le poste est géré par un serveur (domaine) ou autonome (groupe de travail).

```powershell
systeminfo | findstr /C:"Domaine" /C:"Domain"
```

![Figure 6](https://hackmd.io/_uploads/BJ9BB-OYMg.png)
*Figure 6 — Le poste appartient au groupe de travail WORKGROUP*

Pour aller plus vite, j'ai aussi utilisé un script, généré avec l'aide d'une IA (Claude), qui regroupe la configuration IP, l'état du Wi-Fi et le domaine / groupe de travail dans une seule sortie, découpée en sections lisibles.

![Figure 7](https://hackmd.io/_uploads/r1jrS-uFGl.png)
*Figure 7 — Script regroupé : sections « Configuration réseau », « Wi-Fi » (service WLAN non démarré) et « Domaine / Groupe de travail » (WORKGROUP, PartOfDomain = False)*

La section Wi-Fi indique que le service de configuration sans fil n'est pas en cours d'exécution : le poste est relié en Ethernet et n'a aucun réseau Wi-Fi enregistré.

### 1.4 Logiciels installés

Je liste les logiciels installés en interrogeant le registre Windows. C'est plus complet que le Panneau de configuration et le résultat peut être trié et exporté. La clé `HKLM` contient les logiciels installés pour toute la machine, la clé `HKCU` ceux installés uniquement pour l'utilisateur connecté.

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null} | Sort-Object DisplayName
```

```powershell
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null} | Sort-Object DisplayName
```

![Figure 8](https://hackmd.io/_uploads/SyeiHHb_Kfg.png)
*Figure 8 — Logiciels machine (VMware Tools, Visual C++ 2022, outils de mise à jour Microsoft) et logiciel par utilisateur (Microsoft OneDrive)*

### 1.5 Données « cachées » : mails, licences, VPN

Certaines données ne sont pas dans les dossiers personnels et sont souvent oubliées. Je vérifie d'abord s'il existe des fichiers de messagerie Outlook (`.pst` / `.ost`) sur le poste :

```powershell
Get-ChildItem -Path C:\Users\ -Include *.pst,*.ost -Recurse -ErrorAction SilentlyContinue
```

![Figure 9](https://hackmd.io/_uploads/rk3rB-utMg.png)
*Figure 9 — Recherche des fichiers Outlook .pst/.ost : aucun résultat*

Je fais la même vérification pour les profils Thunderbird :

```powershell
Get-ChildItem "$env:APPDATA\Thunderbird\Profiles" -ErrorAction SilentlyContinue
```

![Figure 10](https://hackmd.io/_uploads/Sy3BSWOKfx.png)
*Figure 10 — Recherche d'un profil Thunderbird : aucun résultat*

Aucune des deux commandes ne renvoie de résultat : il n'y a pas de messagerie locale à sauvegarder.

Je passe aux licences. Cette commande lit la clé Windows d'origine enregistrée dans le firmware (BIOS/UEFI) de la machine :

```powershell
(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
```

![Figure 11](https://hackmd.io/_uploads/BkpHrW_Kze.png)
*Figure 11 — Lecture de la clé produit OEM : aucune valeur renvoyée*

La commande n'affiche rien, ce qui veut dire qu'aucune clé n'est enregistrée dans le firmware. C'est logique sur une machine virtuelle.

Je vérifie ensuite s'il existe des connexions VPN configurées :

```powershell
Get-VpnConnection
```

![Figure 12](https://hackmd.io/_uploads/SJArS-dYGx.png)
*Figure 12 — `Get-VpnConnection` : aucun VPN configuré*

Ici aussi, le processus est un peu long commande par commande. J'ai donc utilisé un second script tout-en-un, généré avec l'aide de Claude, qui enchaîne les mails locaux, la clé produit Windows, les VPN et les certificats :

```powershell
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
```

![Figure 13](https://hackmd.io/_uploads/H1CSBbuFze.png)
*Figure 13 — Résultat du script : pas de mails locaux, pas de VPN, pas de certificats ; licence Windows Professional edition*

Ce script confirme les résultats précédents et ajoute deux informations : il n'y a aucun certificat installé, et la licence active est une **Windows Professional edition**.

### 1.6 Comptes utilisateurs et imprimantes

Je relève les comptes locaux présents sur le poste. Il faudra les recréer à l'identique après la réinstallation, sinon les utilisateurs ne pourront plus se connecter.

```powershell
Get-LocalUser
```

![Figure 14](https://hackmd.io/_uploads/HkyLSZOtMe.png)
*Figure 14 — Comptes locaux actifs : adm-maintenance, AR.BR, damien, Gael, Yohan (plus les comptes système désactivés)*

Je liste ensuite les imprimantes installées :

```powershell
Get-Printer
```

![Figure 15](https://hackmd.io/_uploads/rJGPHbdFGx.png)
*Figure 15 — Imprimantes : OneNote, Microsoft XPS Document Writer, Microsoft Print to PDF et Fax, toutes locales*

Enfin, je regarde quels comptes font partie du groupe Administrateurs. C'est important pour la sécurité : après la migration, seuls ces comptes-là doivent retrouver des droits d'administration.

```powershell
Get-LocalGroupMember -Group "Administrateurs"
```

![Figure 16](https://hackmd.io/_uploads/HyfvSZuFzl.png)
*Figure 16 — Membres du groupe Administrateurs : Administrateur, adm-maintenance et AR.BR*

---

## Étape 2 — Sauvegarde sur un support externe

### 2.1 Choix et vérification du support

Pour la sauvegarde, j'utilise une clé USB. Un support externe est indispensable : une sauvegarde laissée sur le disque du poste serait effacée en même temps que lui.

![Figure 17](https://hackmd.io/_uploads/BkXvS-utMx.png)
*Figure 17 — La clé USB (lecteur E:) est vide*

Avant de copier quoi que ce soit, je vérifie l'espace disponible dans les propriétés de la clé.

![Figure 18](https://hackmd.io/_uploads/H1EDS-OYfx.png)
*Figure 18 — Propriétés de la clé : FAT32, capacité 3,74 Go, espace libre 3,74 Go*

La clé fait 4 Go et elle est vide. Comme ma VM contient très peu de données personnelles, c'est largement suffisant.

### 2.2 Création d'une arborescence datée

Pour que la sauvegarde soit claire et facile à retrouver, je crée dans PowerShell un dossier daté sur le Bureau, avec un sous-dossier numéroté pour chaque catégorie de l'inventaire :

```powershell
$date = Get-Date -Format "yyyy-MM-dd"
$base = "$env:USERPROFILE\Desktop\Inventaire_$date"

New-Item -ItemType Directory -Path $base -Force
New-Item -ItemType Directory -Path "$base\01_Dossiers_utilisateur" -Force
New-Item -ItemType Directory -Path "$base\02_Favoris_navigateur" -Force
New-Item -ItemType Directory -Path "$base\03_Reseau" -Force
New-Item -ItemType Directory -Path "$base\04_Logiciels_installes" -Force
New-Item -ItemType Directory -Path "$base\05_Donnees_planquees" -Force
New-Item -ItemType Directory -Path "$base\06_Comptes_Imprimantes" -Force
```

![Figure 19](https://hackmd.io/_uploads/Hk4vr-uYGx.png)
*Figure 19 — Création du dossier Inventaire_2026-09-15 et de ses six sous-dossiers numérotés*

La date dans le nom permet de savoir immédiatement de quand date la sauvegarde, et la numérotation garde les dossiers dans l'ordre de l'inventaire.

![Figure 20](https://hackmd.io/_uploads/SySwr-uFMe.png)
*Figure 20 — Le dossier Inventaire apparaît sur le Bureau*

Il me suffit ensuite de copier ce dossier sur la clé USB avec un copier-coller (Ctrl+C / Ctrl+V).

![Figure 21](https://hackmd.io/_uploads/H1gSDBbdKfx.png)
*Figure 21 — Le dossier Inventaire_2026-09-15 est copié sur la clé USB*

### 2.3 Export des favoris

Je sauvegarde maintenant les favoris. Plutôt que de copier le fichier `Bookmarks` brut, je les exporte au format `.html` : c'est un format standard que tous les navigateurs savent réimporter.

Dans Edge, j'ouvre le menu « … » puis **Favoris**.

![Figure 22](https://hackmd.io/_uploads/ry8DH-dKGx.png)
*Figure 22 — Menu d'Edge, entrée « Favoris » (Ctrl+Maj+O)*

![Figure 23](https://hackmd.io/_uploads/rkwwHW_Yzg.png)
*Figure 23 — Dans le panneau Favoris, menu « … » puis « Exporter les favoris »*

![Figure 24](https://hackmd.io/_uploads/rkDPH-_Kzl.png)
*Figure 24 — Enregistrement sur le Bureau sous le nom favorites_15_09_2026.html (type HTML Document)*

![Figure 25](https://hackmd.io/_uploads/rJuDHWdKMl.png)
*Figure 25 — Le fichier de favoris exporté sur le Bureau*

Je copie ensuite ce fichier sur la clé USB.

![Figure 26](https://hackmd.io/_uploads/HktvrWuKGx.png)
*Figure 26 — La clé contient maintenant le dossier Inventaire et le fichier favorites_15_09_2026.html (1,70 Ko)*

### 2.4 Liste des logiciels et configuration réseau

J'enregistre maintenant la liste des logiciels et la configuration réseau dans des fichiers texte. L'intérêt est de garder ces informations **en dehors du poste** : une fois le disque effacé, il ne sera plus possible de relancer les commandes pour les retrouver.

Dans PowerShell, je redirige la sortie de `ipconfig /all` vers un fichier texte grâce à `Out-File` :

```powershell
ipconfig /all | Out-File "$env:USERPROFILE\Desktop\config_reseau.txt"
```

![Figure 27](https://hackmd.io/_uploads/rkFvH-OYzl.png)
*Figure 27 — Export de la configuration réseau dans config_reseau.txt*

Puis j'exporte la liste complète des logiciels. Cette version interroge les trois emplacements du registre (logiciels 64 bits, logiciels 32 bits dans `Wow6432Node`, et logiciels de l'utilisateur) pour ne rien oublier :

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null} | Sort-Object DisplayName | Out-File "$env:USERPROFILE\Desktop\logiciels_installes.txt"
```

![Figure 28](https://hackmd.io/_uploads/B15vrbdKMe.png)
*Figure 28 — Export de la liste des logiciels dans logiciels_installes.txt*

Je déplace les deux fichiers texte sur la clé USB.

![Figure 29](https://hackmd.io/_uploads/Hy2dSbuYMe.png)
*Figure 29 — Contenu final de la clé : Inventaire_2026-09-15, favorites_15_09_2026.html, config_reseau et logiciels_installes*

### 2.5 Capture de l'espace utilisé avant réinstallation

Juste avant la réinstallation, je fais une capture de l'espace disque du poste. Cette preuve ne pourra plus être faite après le formatage.

![Figure 30](https://hackmd.io/_uploads/Hyh_SWuFfe.png)
*Figure 30 — Avant réinstallation : disque C: avec 50,0 Go libres sur 79,6 Go, clé USB E: avec 3,74 Go libres*

---

## Étape 3 — Vérification de l'intégrité de la sauvegarde

Une sauvegarde n'a de valeur que si elle est complète et lisible. Je la vérifie donc de trois façons avant d'effacer quoi que ce soit.

### 3.1 Comparaison du nombre de fichiers et de dossiers

J'utilise un script PowerShell, réalisé avec l'aide de Claude, qui compte les fichiers et les dossiers dans la source (le Bureau) et dans la destination (la clé), puis indique si les deux correspondent :

```powershell
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
```

![Figure 31](https://hackmd.io/_uploads/rkTOr-uYMg.png)
*Figure 31 — Résultat : source et destination contiennent 0 fichier / 6 dossiers, message « OK - Copie complete »*

Le nombre d'éléments est identique des deux côtés : tout a bien été copié.

### 3.2 Comparaison de la taille totale

Le nombre de fichiers ne suffit pas : un fichier peut être présent mais incomplet si la copie a été interrompue. Je compare donc aussi la taille. Je fais un clic droit sur le dossier du Bureau, puis **Propriétés**.

![Figure 32](https://hackmd.io/_uploads/HJaOB-dFfe.png)
*Figure 32 — Clic droit sur le dossier Inventaire du Bureau, puis « Propriétés »*

![Figure 33](https://hackmd.io/_uploads/HyAdBbdYfl.png)
*Figure 33 — Dossier source : taille 0 octet, 0 fichier, 6 dossiers*

La taille est de 0 octet, ce qui est normal puisque ma VM ne contient presque aucune donnée. Je fais la même chose sur la clé USB.

![Figure 34](https://hackmd.io/_uploads/BJkKSbdtGl.png)
*Figure 34 — Clic droit sur le dossier Inventaire de la clé USB, puis « Propriétés »*

![Figure 35](https://hackmd.io/_uploads/B1kFHb_Fzl.png)
*Figure 35 — Dossier sur la clé (E:\) : taille 0 octet, 0 fichier, 6 dossiers*

Les propriétés sont identiques des deux côtés.

### 3.3 Ouverture des éléments sauvegardés

J'ouvre ensuite des éléments au hasard sur la clé pour vérifier qu'ils ne sont pas corrompus.

![Figure 36](https://hackmd.io/_uploads/H1lFBWuYGe.png)
*Figure 36 — Ouverture du sous-dossier 04_Logiciels_installes sur la clé : il s'ouvre normalement et est vide*

Les dossiers s'ouvrent correctement. Ils ne contiennent pas de fichier, comme l'indiquaient déjà les propriétés.

### 3.4 Test de la clé sur un autre poste

Avant de réinstaller, je vérifie une dernière fois que la clé est lisible **sur un autre ordinateur**. C'est la seule façon d'être sûr que la sauvegarde ne dépend pas du poste que je vais effacer.

![Figure 37](https://hackmd.io/_uploads/B1ZtrWOFzg.jpg)
*Figure 37 — La clé branchée sur un autre ordinateur : on retrouve Inventaire_2026-09-15, config_reseau, favorites_15_09_2026.html et logiciels_installes*

---

## Étape 4 — Réinstallation du système d'exploitation

### 4.1 Réinitialisation du poste

La sauvegarde étant vérifiée, je peux lancer la réinstallation. Je passe par **Paramètres → Mise à jour et sécurité**.

![Figure 38](https://hackmd.io/_uploads/BJ-KSWOYGe.png)
*Figure 38 — Paramètres Windows, catégorie « Mise à jour et sécurité »*

![Figure 39](https://hackmd.io/_uploads/S1GKHZdKGg.png)
*Figure 39 — Menu « Récupération » dans la colonne de gauche*

![Figure 40](https://hackmd.io/_uploads/SJmYHWOFze.png)
*Figure 40 — Section « Réinitialiser ce PC », bouton « Commencer »*

Windows propose deux sources pour réinstaller le système. Je choisis la **réinstallation locale**, qui utilise les fichiers déjà présents sur la machine et évite de télécharger plus de 4 Go.

![Figure 41](https://hackmd.io/_uploads/By7FBbuYGg.png)
*Figure 41 — Choix entre « Téléchargement dans le cloud » et « Réinstallation locale »*

Le résumé confirme que tout sera supprimé : fichiers personnels, comptes d'utilisateur, paramètres et applications. C'est bien une réinstallation complète, et non une simple réparation qui conserverait les fichiers.

![Figure 42](https://hackmd.io/_uploads/S1EYSb_KGx.png)
*Figure 42 — « Prêt pour réinitialiser ce PC » : suppression des fichiers, comptes, paramètres et applications*

![Figure 43](https://hackmd.io/_uploads/SkwcHbdFzx.png)
*Figure 43 — Réinitialisation en cours (80 %)*

### 4.2 Configuration initiale de Windows

Une fois la réinitialisation terminée, je refais la configuration de base de Windows, en commençant par la disposition du clavier.

![Figure 44](https://hackmd.io/_uploads/S1gD5rZOtGe.png)
*Figure 44 — Assistant de configuration : choix de la disposition de clavier (Français)*

![Figure 45](https://hackmd.io/_uploads/H1u9BWOYfx.png)
*Figure 45 — Proposition d'Edge d'importer les données d'un autre navigateur*

![Figure 46](https://hackmd.io/_uploads/rJEy8bdtMe.jpg)
*Figure 46 — Configuration terminée : bureau de Windows vierge, seules la Corbeille et Microsoft Edge sont présents*

### 4.3 Récupération de la sauvegarde sur le poste

Je rebranche la clé USB et je récupère tous ses éléments.

![Figure 47](https://hackmd.io/_uploads/H1qqBZOFzl.png)
*Figure 47 — Contenu de la clé USB relue depuis le poste réinstallé*

Je les colle sur le Bureau du poste pour pouvoir travailler dessus pendant la suite de la restauration. La clé, elle, reste intacte en cas de problème.

![Figure 48](https://hackmd.io/_uploads/HkiqSbdtzl.png)
*Figure 48 — Les quatre éléments de la sauvegarde copiés sur le Bureau*

### 4.4 Pilotes

Je vérifie maintenant les pilotes. Pour savoir sur quel site de fabricant chercher le pilote du chipset, j'identifie d'abord la carte mère :

```powershell
Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
```

![Figure 49](https://hackmd.io/_uploads/SkjcHWOtGx.png)
*Figure 49 — Carte mère : Intel Corporation, 440BX Desktop Reference Platform (carte virtuelle émulée par VMware)*

Je fais la même chose pour la carte graphique :

```powershell
Get-CimInstance Win32_VideoController | Select-Object Name
```

![Figure 50](https://hackmd.io/_uploads/Byncr-uYzg.png)
*Figure 50 — Carte graphique : VMware SVGA 3D*

Les deux composants sont des périphériques virtuels fournis par VMware. Pour confirmer que rien ne manque, j'ouvre le Gestionnaire de périphériques.

![Figure 51](https://hackmd.io/_uploads/Hya5r-_Fzg.png)
*Figure 51 — Gestionnaire de périphériques de DESKTOP-7NH9ODD : aucun point d'exclamation jaune*

Aucun périphérique n'affiche de point d'exclamation jaune : tous les pilotes sont installés et fonctionnent.

---

## Étape 5 — Réinstallation des logiciels

Pour réinstaller le logiciel PDF que j'utilisais, j'ouvre le dossier de sauvegarde que j'ai déposé sur le poste.

![Figure 52](https://hackmd.io/_uploads/SJaqHbdKfg.png)
*Figure 52 — Le dossier Inventaire_2026-09-15 sur le Bureau du poste réinstallé*

![Figure 53](https://hackmd.io/_uploads/rJRqrW_YMe.png)
*Figure 53 — Ouverture du sous-dossier 04_Logiciels_installes*

![Figure 54](https://hackmd.io/_uploads/BkyirbOFze.png)
*Figure 54 — Le dossier contient l'installateur de Soda PDF (SodaPDFInstaller)*

Je lance l'installation de Soda PDF.

![Figure 55](https://hackmd.io/_uploads/rJeoH-uKGe.png)
*Figure 55 — Installation de Soda PDF en cours (« Préparation en cours… »)*

Je vérifie ensuite que le logiciel démarre correctement. Une installation qui se termine sans erreur ne garantit pas que le programme fonctionne, d'où ce test.

![Figure 56](https://hackmd.io/_uploads/r1WjSWuFzg.png)
*Figure 56 — Soda PDF s'ouvre normalement sur son écran d'accueil*

---

## Étape 6 — Restauration des données et vérification

### 6.1 Restauration des dossiers

Je recopie maintenant les dossiers sauvegardés vers le poste. Je sélectionne les dossiers de mon point de récupération :

![Figure 57](https://hackmd.io/_uploads/rJ42SbdYfg.png)
*Figure 57 — Sélection des six sous-dossiers de la sauvegarde*

Je les colle dans **Documents** avec un copier-coller (Ctrl+C / Ctrl+V). Une fois la copie faite, je peux supprimer les dossiers récupérés qui se trouvent au mauvais endroit (sur le Bureau), pour ne pas garder de doublons.

![Figure 58](https://hackmd.io/_uploads/S1E3BbOFGl.png)
*Figure 58 — Les dossiers restaurés dans Documents, à côté du dossier Soda PDF Files*

### 6.2 Réimport des favoris

Je remets ensuite les favoris dans le navigateur. J'ouvre Edge, puisque c'était le navigateur utilisé avant la migration, et je clique sur l'icône des favoris.

![Figure 59](https://hackmd.io/_uploads/SkSkIZuFGg.jpg)
*Figure 59 — Edge sur le poste réinstallé, bouton des favoris dans la barre d'outils*

![Figure 60](https://hackmd.io/_uploads/SkL3SbuYzl.png)
*Figure 60 — Menu « … » du panneau Favoris, puis « Importer les favoris »*

![Figure 61](https://hackmd.io/_uploads/B1D2S-OtGx.png)
*Figure 61 — Page Paramètres → Profils → Importer les données du navigateur*

Dans « Autres emplacements d'importation », je choisis d'importer les données du navigateur maintenant.

![Figure 62](https://hackmd.io/_uploads/BkDhSWdFfg.png)
*Figure 62 — « Importer les données du navigateur maintenant », bouton « Importer »*

![Figure 63](https://hackmd.io/_uploads/ry_hBW_tzg.png)
*Figure 63 — Fenêtre d'importation, source proposée par défaut : Microsoft Internet Explorer*

Je remplace la source par un **fichier HTML de favoris**, qui correspond au fichier exporté à l'étape 2.

![Figure 64](https://hackmd.io/_uploads/Hy_hBbdYzl.png)
*Figure 64 — Choix de la source « Fichier HTML Favoris ou signets »*

Je sélectionne mon fichier de sauvegarde :

![Figure 65](https://hackmd.io/_uploads/ryF3rWuKMx.png)
*Figure 65 — Sélection du fichier favorites_15_09_2026.html*

![Figure 66](https://hackmd.io/_uploads/S1K2r-_Yfx.png)
*Figure 66 — Favoris restaurés dans la barre des favoris : portail CFF et AliExpress*

Mes favoris sont revenus.

### 6.3 Vérification de la restauration

Pour vérifier que toutes les données sont revenues, je refais le même contrôle qu'à l'étape 3 : je prends le dossier restauré, j'ouvre ses **Propriétés** et je compare la taille et le nombre d'éléments avec ceux de la sauvegarde. Dans mon cas, la taille est de 0 octet des deux côtés, car il s'agit d'un exercice sur une VM qui ne contient pas de fichiers réels.

---

## Étape 7 — Reconfiguration des paramètres essentiels

### 7.1 Réseau et groupe de travail

J'arrive à la fin de la migration. Je vérifie à nouveau la configuration réseau pour la comparer avec celle relevée avant la réinstallation (fichier `config_reseau.txt`).

```powershell
ipconfig /all
```

![Figure 67](https://hackmd.io/_uploads/Hyq2BbOKfx.png)
*Figure 67 — Après réinstallation : DESKTOP-7NH9ODD, DHCP activé, IPv4 192.168.136.139, masque 255.255.255.0, passerelle et DNS 192.168.136.2*

Le poste est toujours en DHCP et a récupéré exactement la même adresse IP, la même passerelle et les mêmes DNS qu'avant. Aucune modification manuelle n'est donc nécessaire.

J'affiche ensuite l'état du Wi-Fi :

```powershell
netsh wlan show interfaces
```

![Figure 68](https://hackmd.io/_uploads/S1snBWdYfe.png)
*Figure 68 — `netsh wlan show interfaces` : le service de configuration sans fil (wlansvc) n'est pas démarré*

Comme le poste est connecté en Ethernet, ce service n'est pas en fonction, ce qui correspond à l'inventaire de départ.

Et je vérifie le domaine / groupe de travail :

```powershell
systeminfo | findstr /i "domaine"
```

![Figure 69](https://hackmd.io/_uploads/Hks2BZ_Kzl.png)
*Figure 69 — Le poste est de nouveau dans le groupe de travail WORKGROUP*

### 7.2 Imprimante

J'installe maintenant une imprimante. Je vais dans **Paramètres → Périphériques**.

![Figure 70](https://hackmd.io/_uploads/Bk2hSZdYGe.png)
*Figure 70 — Paramètres Windows (compte local AR.BR), catégorie « Périphériques »*

![Figure 71](https://hackmd.io/_uploads/BJkArZ_tMl.png)
*Figure 71 — « Imprimantes et scanners », lien « Je ne trouve pas l'imprimante recherchée dans la liste »*

![Figure 72](https://hackmd.io/_uploads/ryeASb_Kfe.png)
*Figure 72 — Option « Ajouter une imprimante locale ou réseau avec des paramètres manuels »*

![Figure 73](https://hackmd.io/_uploads/S1bArZdtMl.png)
*Figure 73 — Choix du port existant PORTPROMPT: (Port local)*

![Figure 74](https://hackmd.io/_uploads/BkGCrZOYGe.png)
*Figure 74 — Choix du pilote : fabricant Microsoft, Microsoft MS-XPS Class Driver 2*

Je lance une page de test pour vérifier que l'imprimante fonctionne. Comme elle est branchée sur le port `PORTPROMPT` (impression vers un fichier), Windows me demande où enregistrer l'impression au lieu de l'envoyer sur papier.

![Figure 75](https://hackmd.io/_uploads/HkmAH-_YMg.png)
*Figure 75 — Imprimante « Microsoft MS-XPS Class Driver 2 (Copie 1) » ajoutée ; la page de test ouvre la fenêtre « Enregistrer l'impression sous » (.prn)*

On voit ainsi que l'impression de test est bien prise en charge.

### 7.3 Comptes utilisateurs

Je termine par les comptes utilisateurs, que je compare à ceux relevés pendant l'inventaire.

```powershell
net user
```

![Figure 76](https://hackmd.io/_uploads/H1X0rWOtfe.png)
*Figure 76 — Comptes de DESKTOP-7NH9ODD : Administrateur, AR.BR, Damien, Gael, Yohan, plus les comptes système*

On retrouve bien les comptes des utilisateurs du poste.

### 7.4 Mails, VPN et certificats

L'inventaire de l'étape 1 n'a trouvé aucun fichier de messagerie local, aucune connexion VPN et aucun certificat (figures 9 à 13). Il n'y a donc rien à reconfigurer de ce côté.

---

## Points de vigilance et pièges rencontrés

- **Ne jamais formater avant d'avoir testé la sauvegarde sur un autre poste** (figure 37). Une clé qui ne se lit que sur le poste d'origine ne sert à rien une fois ce poste effacé.
- **Les favoris ne sont pas dans les dossiers personnels.** Il faut les exporter à part en `.html` depuis le navigateur.
- **Les informations système disparaissent au formatage.** La configuration réseau, la liste des logiciels et la capture de l'espace disque doivent être exportées dans des fichiers et copiées hors du poste *avant* la réinstallation.
- **Le nom du poste change après la réinitialisation** (`DESKTOP-CS3EK94` → `DESKTOP-7NH9ODD`). Si d'autres machines ou des partages utilisaient l'ancien nom, il faut le renommer.
- **La clé USB est en FAT32**, ce qui limite chaque fichier à 4 Go. Pour sauvegarder de grosses vidéos ou une archive complète, il faut un support en NTFS ou exFAT.
- **Vérifier qu'un logiciel démarre, pas seulement qu'il s'installe.**
- **Garder la clé intacte jusqu'à la validation finale.** Travailler sur une copie (ici sur le Bureau) évite d'abîmer la seule sauvegarde existante.

---

## Récapitulatif

| Élément | Configuration retenue |
|---|---|
| Poste | VM VMware, Windows 10 Professionnel, disque 79,6 Go |
| Inventaire | Dossiers personnels, favoris Edge, réseau, logiciels, mails/licences/VPN/certificats, comptes, imprimantes |
| Support de sauvegarde | Clé USB 4 Go FAT32 |
| Structure de la sauvegarde | `Inventaire_2026-09-15` (6 sous-dossiers numérotés) + `favorites_15_09_2026.html` + `config_reseau.txt` + `logiciels_installes.txt` |
| Vérification | Script de comptage fichiers/dossiers, comparaison des tailles, ouverture des éléments, test sur un autre PC |
| Réinstallation | Réinitialiser ce PC → Réinstallation locale, suppression de tout |
| Pilotes | Aucune erreur dans le Gestionnaire de périphériques |
| Logiciels | Soda PDF réinstallé et testé |
| Données | Dossiers restaurés dans Documents, favoris réimportés depuis le fichier HTML |
| Réseau | DHCP, 192.168.136.139/24, passerelle et DNS 192.168.136.2, WORKGROUP |
| Imprimante | Microsoft MS-XPS Class Driver 2 sur PORTPROMPT, test d'impression effectué |
| Comptes | Administrateur, AR.BR, Damien, Gael, Yohan |

---

## Conclusion

La migration est terminée : le poste a été entièrement réinstallé, la sauvegarde a été vérifiée avant l'effacement, puis les dossiers, les favoris, le logiciel PDF, la configuration réseau, l'imprimante et les comptes utilisateurs ont été remis en place.

Ce projet m'a surtout appris que **la réussite d'une migration se joue avant la réinstallation**. Le formatage lui-même ne prend que quelques clics, mais tout ce qui n'a pas été inventorié et vérifié avant est perdu. J'ai aussi constaté l'intérêt de PowerShell par rapport à l'interface graphique : une seule commande permet de lister six dossiers, d'interroger le registre ou de comparer une sauvegarde, et le résultat peut être exporté dans un fichier qui sert de preuve. Les scripts regroupés rendent l'inventaire beaucoup plus rapide et surtout reproductible sur un autre poste.

Avant d'appliquer cette procédure sur un vrai poste en production, plusieurs améliorations seraient utiles :

- Faire la réinstallation depuis une **clé USB bootable** en supprimant et recréant les partitions, pour repartir d'un disque totalement propre.
- Appliquer **toutes les mises à jour Windows** juste après l'installation, avant de restaurer les données, pour corriger les failles connues.
- **Remettre les dossiers à leur emplacement d'origine** (Documents, Téléchargements, etc.) plutôt que dans un seul dossier, pour que l'utilisateur retrouve ses repères.
- Ajouter à la sauvegarde une **copie horodatée des résultats d'inventaire** (comptes, imprimantes, membres du groupe Administrateurs) dans le dossier `06_Comptes_Imprimantes`.
- Utiliser `robocopy` avec un fichier journal pour les copies, afin d'avoir une trace détaillée de chaque fichier copié.
- Mettre en place une **sauvegarde automatique** régulière (Historique des fichiers ou sauvegarde réseau) pour ne plus dépendre d'une copie manuelle.
- Faire **valider la restauration par l'utilisateur** avant d'effacer la clé de sauvegarde.
