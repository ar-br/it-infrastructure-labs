# VMware ESXi 8 & vCenter (VCSA) — Installation sur serveur HP ProLiant

> Installation de l'hyperviseur VMware ESXi 8.0.3 sur un serveur rack physique, création de datastores et de VM (dont Windows Server 2025), administration en SSH, puis déploiement de vCenter Server Appliance et intégration de l'hôte dans un cluster.

**Contexte :** Projet d'école — Geneva Institute of Technology, 1ère année · septembre 2026 · réalisé en équipe de 4

**Technologies :** VMware ESXi 8.0.3 · vCenter Server Appliance (VCSA) · vSphere Client · HP ProLiant DL380p Gen8 (iLO, RAID) · VMware Workstation · Windows Server 2025 · SSH · DNS

### Compétences mises en œuvre

- Installation d'un hyperviseur type 1 sur serveur physique (BIOS/RBSU, volume RAID, DCUI)
- Configuration réseau de l'hôte : IP statique, DNS, nom d'hôte
- Gestion du stockage : création de datastores VMFS, upload d'ISO
- Création et gestion de VM : VMware Tools, tests réseau, snapshots
- Administration en ligne de commande via SSH (`vim-cmd`, `df -h`)
- Déploiement de vCenter (VCSA), ajout d'un hôte dans un cluster, gestion des licences
- Diagnostic : disque système déjà utilisé, virtualisation imbriquée bloquée par Hyper-V/VBS

---

## Partie 1 – Installation d'ESXi sur le serveur physique (HP ProLiant DL380p Gen8)

Installation d'ESXi 8.0.3 directement sur le serveur rack de la salle, puis configuration de base depuis la console (DCUI) et l'interface web.

### Étape 1 – Démarrage du serveur

Au démarrage (POST), le serveur HP ProLiant détecte ses 2 processeurs Intel Xeon E5-2630 v2 et ses 192 Go de RAM. L'iLO est joignable en 10.10.10.3.

![Figure 1](https://hackmd.io/_uploads/H1OMMaH5fe.jpg)

### Étape 2 – Vérification du BIOS (RBSU)

Passage dans les options système du BIOS pour contrôler la configuration du serveur (processeurs, mémoire, ordre de démarrage) avant l'installation.

![Figure 2](https://hackmd.io/_uploads/HJKzGpSqGg.jpg)

### Étape 3 – Lancement de l'installateur ESXi

Le serveur démarre sur le média d'installation et charge les modules de l'installateur ESXi.

![Figure 3](https://hackmd.io/_uploads/BkqGz6Sqfg.jpg)

### Étape 4 – Écran d'accueil de l'installation

Écran de bienvenue de VMware ESXi 8.0.3. On valide avec Entrée pour continuer.

![Figure 4](https://hackmd.io/_uploads/Hk9Mz6H5fg.jpg)

### Étape 5 – Choix du disque d'installation

Sélection du volume logique HP (RAID) de 558 Go sur lequel ESXi va être installé.

![Figure 5](https://hackmd.io/_uploads/rkjfzpS5Mg.jpg)

### Étape 6 – Premier démarrage d'ESXi

Après l'installation et le redémarrage, l'hyperviseur ESXi 8.0.3 se charge.

![Figure 6](https://hackmd.io/_uploads/rk2Mz6Hqzx.jpg)

### Étape 7 – Console DCUI

ESXi est démarré : la console affiche le modèle du serveur, les ressources et l'adresse à utiliser pour administrer l'hôte depuis un navigateur.

![Figure 7](https://hackmd.io/_uploads/rkTzzpSqzx.jpg)

### Étape 8 – Configuration DNS et nom d'hôte

Dans la DCUI (F2), on configure le serveur DNS (10.40.10.50) et le nom d'hôte ESXi-GIT-DA.

![Figure 8](https://hackmd.io/_uploads/S1CfG6Bcfe.jpg)

### Étape 9 – Accès à l'interface web (Host Client)

Connexion à l'hôte ESXI-GIT-DA via le navigateur : on retrouve le matériel HP ProLiant DL380p Gen8, la version ESXi et l'état des ressources.

![Figure 9](https://hackmd.io/_uploads/rk0fzTS9Me.jpg)

## Partie 2 – Installation d'ESXi dans une VM (VMware Workstation)

Refaire l'installation en lab sur un PC avec VMware Workstation (ESXi « imbriqué »), puis créer un datastore et une VM.

### Étape 10 – Préparation de la VM ESXi

Création d'une VM « VMware ESXi 8 and later » dans Workstation : 8 Go de RAM, 2 processeurs, disque de 70 Go et l'ISO d'ESXi dans le lecteur CD.

![Figure 10](https://hackmd.io/_uploads/Hy1XG6S5Mg.jpg)

### Étape 11 – Accueil de l'installateur

La VM démarre sur l'ISO et affiche l'écran d'accueil d'ESXi 8.0.3.

![Figure 11](https://hackmd.io/_uploads/S1JmGpH9Gl.jpg)

### Étape 12 – Choix du disque

Sélection du disque virtuel de 70 Go (mpx.vmhba0:C0:T0:L0).

![Figure 12](https://hackmd.io/_uploads/rkxmMpBczx.jpg)

### Étape 13 – Disposition du clavier

Choix du clavier « Swiss French ».

![Figure 13](https://hackmd.io/_uploads/r1bQzTr5fl.jpg)

### Étape 14 – Avertissement matériel

L'installateur signale que la virtualisation matérielle n'est pas disponible dans la VM. Pas bloquant pour l'installation, on continue.

![Figure 14](https://hackmd.io/_uploads/r1ZmzTB5fl.jpg)

### Étape 15 – Confirmation

Confirmation de l'installation avec F11 (le disque va être repartitionné).

![Figure 15](https://hackmd.io/_uploads/BkGmMaS5Mx.jpg)

### Étape 16 – Installation en cours

Copie des fichiers d'ESXi sur le disque.

![Figure 16](https://hackmd.io/_uploads/rJmQMprqzl.jpg)

### Étape 17 – Installation terminée

ESXi est installé (licence d'évaluation de 60 jours). On retire le média puis on redémarre.

![Figure 17](https://hackmd.io/_uploads/HyQQfpr9Ge.jpg)

### Étape 18 – Premier démarrage

Chargement d'ESXi dans la VM après le redémarrage.

![Figure 18](https://hackmd.io/_uploads/HyEXzaB9zl.jpg)

### Étape 19 – Console DCUI

L'hôte est prêt et a reçu une adresse IP en DHCP (192.168.221.136).

![Figure 19](https://hackmd.io/_uploads/HkN7fpHcMe.jpg)

### Étape 20 – Connexion à la DCUI

Touche F2 pour se connecter avec le compte administrateur et accéder à la configuration.

![Figure 20](https://hackmd.io/_uploads/H1S7MTrqGe.jpg)

### Étape 21 – Adresse IP statique

Configuration d'une IPv4 statique pour la gestion : 192.168.0.69 / 255.255.255.0.

![Figure 21](https://hackmd.io/_uploads/r1H7MTHcMg.jpg)

### Étape 22 – Interface web ESXi

Connexion au Host Client : aucune banque de données n'est encore configurée sur l'hôte.

![Figure 22](https://hackmd.io/_uploads/SyLXGpB5zg.jpg)

### Étape 23 – Création d'un datastore

Stockage > Nouvelle banque de données > Créer une banque de données VMFS.

![Figure 23](https://hackmd.io/_uploads/rJD7GaBczg.jpg)

### Étape 24 – Problème : pas de disque libre

Aucun périphérique disponible : le disque de 70 Go est déjà utilisé par le système ESXi.

![Figure 24](https://hackmd.io/_uploads/S1uQMar9zg.jpg)

### Étape 25 – Ajout d'un 2e disque

Dans Workstation, ajout d'un nouveau disque virtuel de 50 Go à la VM ESXi.

![Figure 25](https://hackmd.io/_uploads/H1_Qz6H5Gg.jpg)

### Étape 26 – Réanalyse du stockage

Après une réanalyse, le nouveau disque de 50 Go apparaît dans les périphériques.

![Figure 26](https://hackmd.io/_uploads/BJK7MaB9Gx.jpg)

### Étape 27 – Sélection du nouveau disque

Nom du datastore « Stockage ESXi-01 » et choix du disque de 50 Go.

![Figure 27](https://hackmd.io/_uploads/rk9mGpH5Gl.jpg)

### Étape 28 – Partitionnement

Utilisation de tout l'espace disque en VMFS 6.

![Figure 28](https://hackmd.io/_uploads/HyomzpH5zg.jpg)

### Étape 29 – Datastore créé

La banque de données « Stockage ESXi-01 » est créée et visible.

![Figure 29](https://hackmd.io/_uploads/rJomfaB5zg.jpg)

### Étape 30 – Création d'une VM

Assistant Nouvelle machine virtuelle : nom « VM de ESXi-01 », système invité Windows 10 64 bits.

![Figure 30](https://hackmd.io/_uploads/BkhmM6r9Ge.jpg)

### Étape 31 – Paramètres de la VM

2 vCPU, 8 Go de RAM, disque de 48 Go sur le datastore Stockage ESXi-01, provisionnement statique.

![Figure 31](https://hackmd.io/_uploads/ry3XGaHqGg.jpg)

### Étape 32 – Réseau et lecteur CD

Carte réseau sur « VM Network » et lecteur CD/DVD connecté.

![Figure 32](https://hackmd.io/_uploads/SJTXMaB9zl.jpg)

### Étape 33 – VM créée

La VM apparaît dans la liste des machines virtuelles.

![Figure 33](https://hackmd.io/_uploads/Bk0mM6r5Mx.jpg)

### Étape 34 – Dossier ISO

Dans l'explorateur de banque de données, création d'un répertoire « ISO ».

![Figure 34](https://hackmd.io/_uploads/rkR7zTBcMe.jpg)

### Étape 35 – Upload de l'ISO

Téléchargement de l'ISO de Windows 10 vers le dossier ISO du datastore.

![Figure 35](https://hackmd.io/_uploads/rkxBfar9zx.jpg)

### Étape 36 – Sélection de l'ISO

Dans les paramètres de la VM, on choisit Windows 10.iso depuis le datastore.

![Figure 36](https://hackmd.io/_uploads/HJWSGTrcfl.jpg)

### Étape 37 – Lecteur CD configuré

Lecteur CD/DVD en « Fichier ISO banque de données », connecté. On enregistre.

![Figure 37](https://hackmd.io/_uploads/S1x-SMaHczx.jpg)

### Étape 38 – Problème : la VM ne démarre pas

Échec de la mise sous tension : l'hôte ne prend pas en charge AMD-V (virtualisation imbriquée).

![Figure 38](https://hackmd.io/_uploads/SyMrMTBcMl.jpg)

### Étape 39 – Activation de la virtualisation imbriquée

Dans Workstation, on coche « Virtualize Intel VT-x/EPT or AMD-V/RVI » sur la VM ESXi.

![Figure 39](https://hackmd.io/_uploads/SyGSMpScGl.jpg)

### Étape 40 – Limite du poste

Workstation refuse encore la virtualisation imbriquée sur ce PC (Hyper-V / sécurité basée sur la virtualisation active), d'où le passage sur le serveur du labo.

![Figure 40](https://hackmd.io/_uploads/B1QHf6r9Mg.jpg)

## Partie 3 – Serveur ESXi du labo (ESXi-GIT-DA) et VM Windows Server 2025

Utilisation de l'hôte ESXi du labo (10.40.10.181) pour stocker l'ISO, créer une VM Windows Server 2025, la tester et faire un snapshot.

### Étape 41 – Vue d'ensemble de l'hôte

Tableau de bord de l'hôte ESXi du labo (Dell), avec les ressources CPU, mémoire et stockage.

![Figure 41](https://hackmd.io/_uploads/SJ4BGTH5ze.jpg)

### Étape 42 – Datastore principal

Le datastore « datastore1 » (VMFS5, 2,72 To) est disponible.

![Figure 42](https://hackmd.io/_uploads/BkxNrGTrcfg.jpg)

### Étape 43 – ISO Windows Server 2025

Upload de l'ISO windows-server-2025.iso (7,71 Go) dans le dossier iso du datastore.

![Figure 43](https://hackmd.io/_uploads/SJSBfar9fl.jpg)

### Étape 44 – Deuxième datastore

Création d'un « Datastore 2 » sur le disque local Dell de 136 Go.

![Figure 44](https://hackmd.io/_uploads/H1UHzaB9Me.jpg)

### Étape 45 – Création de la VM Windows Server 2025

Paramètres de la VM : CPU, 4 Go de RAM, disque de 40 Go, contrôleur LSI Logic SAS, réseau VM Network et lecteur CD connecté.

![Figure 45](https://hackmd.io/_uploads/H1IHzaSqMl.jpg)

### Étape 46 – VM créée

La VM Windows Server 2025 apparaît dans la liste des machines virtuelles.

![Figure 46](https://hackmd.io/_uploads/B1vBM6Bqfg.jpg)

### Étape 47 – Démarrage et VMware Tools

Tâches récentes : mise sous tension de la VM et montage de l'installateur VMware Tools.

![Figure 47](https://hackmd.io/_uploads/B1uHGpS9Gx.jpg)

### Étape 48 – Installation des VMware Tools

Installation des VMware Tools dans Windows Server pour de meilleures performances et la gestion depuis ESXi.

![Figure 48](https://hackmd.io/_uploads/S1OBGarqfl.jpg)

### Étape 49 – Windows Server installé

Gestionnaire de serveur ouvert sur la VM, accessible via la console VMRC.

![Figure 49](https://hackmd.io/_uploads/ryYrGpBcMl.jpg)

### Étape 50 – Vérification IP

ipconfig : la VM a l'adresse 10.40.10.173 avec la passerelle 10.40.10.1.

![Figure 50](https://hackmd.io/_uploads/Sy9rfaHcMe.jpg)

### Étape 51 – Test de connectivité

ping 8.8.8.8 : la VM sort bien sur Internet.

![Figure 51](https://hackmd.io/_uploads/Bk9rM6rqze.jpg)

### Étape 52 – Test DNS

ping google.com : la résolution de noms fonctionne.

![Figure 52](https://hackmd.io/_uploads/HkjHM6B9Gl.jpg)

### Étape 53 – Snapshot de la VM

Clic droit sur la VM > Snapshots > Prendre un snapshot, pour pouvoir revenir en arrière avant les mises à jour.

![Figure 53](https://hackmd.io/_uploads/S1nBf6S5Me.jpg)

### Étape 54 – Connexion SSH à l'hôte

Connexion en SSH à l'hôte ESXi : ssh root@10.40.10.181.

![Figure 54](https://hackmd.io/_uploads/B1TrfaScGx.jpg)

### Étape 55 – Commandes ESXi

df -h pour voir les volumes et vim-cmd vmsvc/getallvms pour lister les VM (WinServ25_DA).

![Figure 55](https://hackmd.io/_uploads/rkTBGpS9fl.jpg)

### Étape 56 – Vérification du snapshot

vim-cmd vmsvc/snapshot.get 1 : le snapshot « snapshot avant màj » est bien présent.

![Figure 56](https://hackmd.io/_uploads/BkArzpH9Gx.jpg)

### Étape 57 – État de la VM

vim-cmd vmsvc/power.getstate 1 : la VM est allumée (Powered on).

![Figure 57](https://hackmd.io/_uploads/rJJ8GTH9Mx.jpg)

## Partie 4 – Déploiement et configuration de vCenter (VCSA)

Déploiement de vCenter Server Appliance sur l'hôte ESXI-GIT-DA, puis ajout de l'hôte ESXi dans le cluster géré par vCenter.

### Étape 58 – Stage 1 – Paramètres réseau de l'appliance

Dans l'installateur VCSA : réseau VM Network, IPv4 statique, nom VCSA.git.da, IP 10.40.10.182 / 255.255.255.0, passerelle 10.40.10.1 et DNS 10.40.10.250. L'avertissement indique que le nom VCSA.git.da n'est pas encore résolu par le DNS : il faut créer l'enregistrement DNS.

![Figure 58](https://hackmd.io/_uploads/SJeLfpB9Ml.jpg)

### Étape 59 – Stage 1 – Récapitulatif (1er essai)

Récapitulatif avant déploiement avec l'installateur 6.5 : hôte cible ESXI-GIT-DA.git.da, VM « VCSA GIT-DA », taille Tiny, datastore1 en mode thick.

![Figure 59](https://hackmd.io/_uploads/HJ-IM6r5fl.jpg)

### Étape 60 – Stage 1 – Récapitulatif final

Nouveau déploiement avec l'installateur plus récent : taille Small, stockage Large, mêmes paramètres réseau, ports HTTP 80 et HTTPS 443. On lance le déploiement avec Finish.

![Figure 60](https://hackmd.io/_uploads/H1lbIf6B5Gg.jpg)

### Étape 61 – Ajout d'un hôte dans vCenter

Dans le vSphere Client, clic droit sur CLUSTER-DA > Add Host, puis saisie du nom ou de l'adresse IP de l'hôte ESXi.

![Figure 61](https://hackmd.io/_uploads/HJfLzTB5Gl.jpg)

### Étape 62 – Identifiants de l'hôte

Connexion à l'hôte avec le compte root et son mot de passe.

![Figure 62](https://hackmd.io/_uploads/Hkf8fpH9zl.jpg)

### Étape 63 – Résumé de l'hôte

vCenter reconnaît l'hôte 10.40.10.180 : HP ProLiant DL380p Gen8, VMware ESXi 8.0.3, avec la VM SRV_2025_01.

![Figure 63](https://hackmd.io/_uploads/rkmUzprcMe.jpg)

### Étape 64 – Attribution de la licence

Sélection de la licence vSphere 8 Enterprise (License 1) à la place du mode évaluation. L'attribution est validée.

![Figure 64](https://hackmd.io/_uploads/SyN8zaScfl.jpg)

### Étape 65 – Mode verrouillage (lockdown)

Le lockdown mode est laissé sur Disabled pour garder l'accès direct à l'hôte.

![Figure 65](https://hackmd.io/_uploads/ByB8z6S5zx.jpg)

### Étape 66 – Fin de l'assistant

Récapitulatif : hôte 10.40.10.180 dans CLUSTER-DA, licence 1, réseau VM Network, datastore1, lockdown désactivé. Clic sur Finish.

![Figure 66](https://hackmd.io/_uploads/H1H8z6B5Mx.jpg)

### Étape 67 – Inventaire final

Dans vCenter (10.40.10.182) : Datacenter > CLUSTER-DA avec les hôtes ESXi (10.40.10.193, esxi01.git.da) et les VM pc1, pc_gestion, VCSA-DA et WinServ25_DA.

![Figure 67](https://hackmd.io/_uploads/ryLIzaHqzx.jpg)

