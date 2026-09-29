# IT Infrastructure Labs

**Armin Brouard** · Étudiant en 1ère année d'informatique · Infrastructure, Réseaux & Cybersécurité · Geneva Institute of Technology

Ce dépôt rassemble mes projets techniques les plus complets, réalisés pendant ma formation (CFC en infrastructure réseaux et systèmes, double diplomation avec un Bachelor Estiam). Chaque projet est documenté étape par étape, avec captures d'écran, commandes utilisées, problèmes rencontrés et solutions apportées.

![VMware](https://img.shields.io/badge/VMware-ESXi%20%7C%20vCenter%20%7C%20Workstation-607078?logo=vmware&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%20Server%202025-0078D6?logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?logo=ubuntu&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-scripts-5391FE?logo=powershell&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-CLI-4EAA25?logo=gnubash&logoColor=white)

---

## Projets

| # | Projet | Thèmes | Technologies |
|---|---|---|---|
| 01 | [**VMware ESXi 8 & vCenter sur serveur HP ProLiant**](01-vmware-esxi-vcenter/) | Virtualisation, serveur physique, cluster | ESXi 8.0.3, VCSA, vSphere, iLO, SSH, Windows Server 2025 |
| 02 | [**Déploiement standardisé de postes Windows**](02-deploiement-windows-sysprep-clonezilla/) | Image système, déploiement de parc | Sysprep, Clonezilla, PowerShell, Linux CLI |
| 03 | [**Sécurisation d'un poste Windows multi-utilisateurs**](03-securisation-poste-windows-ntfs/) | Contrôle d'accès, durcissement | NTFS / icacls, secpol.msc, PowerShell |
| 04 | [**Migration et sauvegarde d'un poste Windows**](04-migration-sauvegarde-windows-powershell/) | Inventaire, sauvegarde, restauration | PowerShell (registre, CIM), scripts |
| 05 | [**Ubuntu : installation, mise à jour et sécurité de base**](05-ubuntu-installation-securisation/) | Linux, réseau, pare-feu | Ubuntu 26.04, apt, nmcli, UFW |

### En bref

- **01 — ESXi & vCenter** : installation d'ESXi sur un serveur rack (2× Xeon, 192 Go de RAM, RAID), datastores VMFS, VM Windows Server 2025 avec snapshot, administration en SSH (`vim-cmd`), déploiement de vCenter et ajout de l'hôte dans un cluster.
- **02 — Sysprep & Clonezilla** : poste de référence conforme à un cahier des charges, généralisé puis cloné et redéployé. Environ 40 % de temps gagné dès le premier poste, avec une procédure écrite pour un autre technicien.
- **03 — Sécurisation Windows** : dossiers personnels cloisonnés par ACL NTFS, verrouillage de session, politique de mots de passe, puis tests d'accès croisés entre utilisateurs.
- **04 — Migration** : inventaire complet en PowerShell (logiciels, réseau, comptes, VPN, certificats…), sauvegarde vérifiée par script, réinstallation et restauration. Les scripts sont dans [`scripts/`](04-migration-sauvegarde-windows-powershell/scripts/).
- **05 — Ubuntu** : installation raisonnée en VM, mises à jour, diagnostic réseau, pare-feu UFW et revue des services.

---

## Compétences

| Domaine | Ce que je sais faire |
|---|---|
| **Virtualisation** | VMware ESXi, vCenter (VCSA), VMware Workstation, snapshots, datastores, virtualisation imbriquée |
| **Systèmes Windows** | Installation, déploiement par image (Sysprep), comptes locaux, droits NTFS, stratégie de sécurité locale, migration |
| **Systèmes Linux** | Ubuntu, gestion des paquets apt, services, partitionnement (parted, ext4) |
| **Réseau** | Adressage IP statique / DHCP, DNS, NAT, diagnostic (`ipconfig`, `ip a`, `nmcli`, `ping`) |
| **Sécurité** | Principe du moindre privilège, cloisonnement des accès, politique de mots de passe, pare-feu UFW |
| **Scripting** | PowerShell (inventaire, export, vérification), Bash |
| **Documentation** | Procédures reproductibles, cahiers des charges, checklists de conformité |

---

## Méthode

Chaque projet suit la même logique : **définir le besoin → réaliser → vérifier → documenter**. Je note aussi les problèmes rencontrés et la manière dont je les ai résolus. C'est souvent là que j'apprends le plus.

> Les environnements sont des labs (machines virtuelles ou serveur de salle de cours). Les mots de passe ont été retirés de la documentation.

---

📍 Genève / Annemasse · 🎯 En recherche de stage en infrastructure, réseaux ou cybersécurité
