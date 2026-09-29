# Sécurisation d'un poste Windows 10 multi-utilisateurs — Droits NTFS & stratégie de sécurité locale

> Mise en place d'un poste partagé par plusieurs utilisateurs : comptes séparés, dossiers personnels cloisonnés par les droits NTFS, verrouillage automatique de session et politique de mots de passe, puis tests d'accès avec chaque compte.

**Contexte :** Projet d'école (PPE 2) — Geneva Institute of Technology, 1ère année · septembre 2026 · projet individuel

**Technologies :** Windows 10 · PowerShell · `net user` / `New-LocalUser` · `icacls` · `secpol.msc` · VMware Workstation

### Compétences mises en œuvre

- Gestion des comptes locaux en ligne de commande (standard vs administrateur, compte de maintenance dédié)
- Cloisonnement des données avec les ACL NTFS : héritage, contrôle total, propriétaire, droits de traversée (RX,AD)
- Durcissement via la stratégie de sécurité locale : verrouillage après inactivité, longueur, complexité et historique des mots de passe
- Validation par des tests d'accès croisés entre utilisateurs
- Regard critique : points à corriger avant une mise en production (chiffrement réversible, OS en fin de support, sauvegarde)

---

> Installation d'un poste Windows 10 dans une machine virtuelle VMware, partagé par 3 élèves : comptes séparés, dossiers personnels protégés par les droits NTFS, verrouillage automatique de la session et politique de mot de passe, puis test avec chaque compte.

| Paramètre | Valeur |
|---|---|
| Hyperviseur | VMware Workstation Pro 17 |
| Système | Windows 10 Éducation x64 |
| Nom de la VM | VM etudian |
| Nom de la machine | DESKTOP-CS3EK94 |
| Ressources | 80 Go de disque, 8780 Mo de RAM, 8 cœurs, réseau en NAT |
| Compte administrateur | AR.BR |
| Compte de maintenance | adm-maintenance |
| Comptes élèves | damien, Yohan, Gael |
| Dossiers personnels | C:\Perso |
| Verrouillage de session | 600 secondes (10 min) |
| Politique de mot de passe | 9 caractères minimum, complexité, historique de 4 |

---

## 1. Introduction et objectifs

L'objectif est de préparer un poste Windows 10 utilisé par plusieurs élèves, où chacun a son propre compte et son dossier privé, sans pouvoir toucher aux réglages de la machine ni aux fichiers des autres.

Je travaille dans une machine virtuelle : ça permet de tester la configuration sans risque pour mon PC et de revenir en arrière facilement en cas d'erreur.

Les étapes à réaliser :

- créer la machine virtuelle et installer Windows 10 ;
- faire les mises à jour et régler le fuseau horaire ;
- mettre un mot de passe sur le compte administrateur ;
- créer les 3 comptes élèves et un compte de maintenance ;
- créer des dossiers personnels protégés par les droits NTFS ;
- mettre en place le verrouillage automatique de la session ;
- définir une politique de mot de passe ;
- tester le résultat avec les 3 comptes.

---

## 2. Création de la machine virtuelle

Pour commencer, on va créer une VM sur VMware Workstation.

![Figure 1](https://hackmd.io/_uploads/rk_lAFLYGx.png)
*Figure 1 — Écran d'accueil de VMware Workstation Pro 17 avec l'assistant de création de machine virtuelle*

![Figure 2](https://hackmd.io/_uploads/S1_xCtIFfg.png)
*Figure 2 — Choix de l'installation depuis un fichier ISO (Win10_22H2_French_x64), Windows 10 x64 détecté*

Je vais mettre l'ISO de Windows 10 et choisir la version Windows 10 Éducation. VMware propose une installation simplifiée : je renseigne directement le nom du compte (AR.BR) et son mot de passe.

![Figure 3](https://hackmd.io/_uploads/SkFlRYIKMg.png)
*Figure 3 — Easy Install : version Windows 10 Education, nom complet AR.BR et mot de passe*

![Figure 4](https://hackmd.io/_uploads/ryYxCtLKfl.png)
*Figure 4 — Nom de la machine virtuelle « VM etudian » et emplacement C:\VM Pro\windows 10 PPE2*

Puis je donne un nom à la VM et je la mets sur mon disque C (C:\VM Pro) pour un maximum de performance.

![Figure 5](https://hackmd.io/_uploads/r19x0YLKMl.png)
*Figure 5 — Taille du disque fixée à 80 Go (60 Go recommandés), disque découpé en plusieurs fichiers*

Je vais sélectionner mon stockage : pour ma part, ce sera 80 Go, un peu plus que les 60 Go recommandés pour Windows 10, pour garder de la marge pour les mises à jour et les dossiers des utilisateurs.

![Figure 6](https://hackmd.io/_uploads/B1ieAFIFGg.png)
*Figure 6 — Réglage de la mémoire de la VM à 8780 Mo dans la fenêtre Hardware*

Je vais configurer la RAM de ma VM et le nombre de cœurs du processeur. Plus la VM a de ressources, plus Windows sera fluide, mais il faut en laisser assez à mon PC.

![Figure 7](https://hackmd.io/_uploads/B1olAK8FMl.png)
*Figure 7 — Récapitulatif avant création : 80 Go de disque, 8780 Mo de RAM, carte réseau en NAT, 8 cœurs*

On peut voir mes réglages dans le récapitulatif : 80 Go de disque, 8780 Mo de RAM, 8 cœurs et une carte réseau en NAT.

---

## 3. Installation de Windows 10

Puis je lance la VM.

![Figure 8](https://hackmd.io/_uploads/B12gRtUtzl.png)
*Figure 8 — Installation de Windows en cours : copie des fichiers de Windows*

Et Windows 10 s'installe, plus qu'à attendre. Puis, une fois installé, le système va se mettre en préparation.

![Figure 9](https://hackmd.io/_uploads/BJhgAKUtzg.png)
*Figure 9 — Préparation du système : « Cette opération peut durer plusieurs minutes »*

![Figure 10](https://hackmd.io/_uploads/SJagAY8YMl.png)
*Figure 10 — Bureau de Windows 10 après la fin de l'installation*

---

## 4. Mises à jour et fuseau horaire

Installation terminée. Maintenant, je vais faire les mises à jour Windows et configurer le fuseau horaire. Les mises à jour corrigent les failles de sécurité connues, et le bon fuseau horaire permet d'avoir l'heure juste sur le poste.

![Figure 11](https://hackmd.io/_uploads/ry0xRtLFfl.png)
*Figure 11 — Paramètres Windows, rubrique « Heure et langue »*

![Figure 12](https://hackmd.io/_uploads/SyyW0YIYMl.png)
*Figure 12 — Choix du fuseau horaire (UTC+01:00) Amsterdam, Berlin, Berne, Rome, Stockholm, Vienne*

![Figure 13](https://hackmd.io/_uploads/SkJWCKLFfx.png)
*Figure 13 — Pays ou région réglé sur Suisse*

Je choisis le fuseau horaire de Berne (UTC+01:00), puis je vais dans Région et je mets Suisse.

Ensuite, je vais lancer les mises à jour Windows.

![Figure 14](https://hackmd.io/_uploads/SkgWCYIYzg.png)
*Figure 14 — Paramètres Windows, rubrique « Mise à jour et sécurité »*

![Figure 15](https://hackmd.io/_uploads/H1WZ0F8tzx.png)
*Figure 15 — Windows Update : téléchargement des mises à jour disponibles*

---

## 5. Mot de passe administrateur

Maintenant, je vais définir un mot de passe admin pour la machine. Un compte administrateur sans mot de passe, c'est une porte ouverte : n'importe qui devant le poste pourrait tout modifier.

![Figure 16](https://hackmd.io/_uploads/SkGbCtLtfl.png)
*Figure 16 — Recherche de Windows PowerShell et option « Exécuter en tant qu'administrateur »*

Je vais dans PowerShell et je l'exécute en admin, car gérer des comptes demande les droits administrateur.

![Figure 17](https://hackmd.io/_uploads/HJf-Ct8KGe.png)
*Figure 17 — Commande Net User AR.BR tapée dans PowerShell administrateur*

Puis je tape `Net User` suivi de mon nom de compte (AR.BR) et du mot de passe. Cela met un mot de passe sur le compte administrateur.

```powershell
Net User AR.BR <mot_de_passe>
```

---

## 6. Création des comptes utilisateurs

Puis ensuite, je vais ajouter les 3 comptes élèves : damien, Yohan et Gael. Chacun a son propre compte, ce qui permet de séparer leurs fichiers et leurs droits.

Avec la commande `net user` suivie du nom de la personne, de son mot de passe et de `/add`, ça ajoute des comptes locaux. Ce sont des comptes standard, donc sans droits administrateur.

> [!NOTE]
> Les mots de passe de ce lab ont été remplacés par `<mot_de_passe>` dans ce dépôt. En pratique, `net user <nom> *` permet de saisir le mot de passe de façon masquée, sans l'écrire en clair.

```powershell
net user damien <mot_de_passe> /add
```

```powershell
net user Yohan <mot_de_passe> /add
```

```powershell
net user Gael <mot_de_passe> /add
```

![Figure 18](https://hackmd.io/_uploads/H1mbCtIKfl.png)
*Figure 18 — Mot de passe du compte AR.BR, liste des comptes avec net user, puis création des comptes damien, Yohan et Gael*

On peut voir mes 3 utilisateurs.

Puis je vais créer un compte de maintenance admin avec la commande `New-LocalUser`. Avoir un compte dédié à la maintenance permet de séparer l'administration du poste de son utilisation normale.

```powershell
New-LocalUser adm-maintenance -FullName "AR.BR" -Description "maintenance" -Password (Read-Host -AsSecureString "Mot de passe")
```

![Figure 19](https://hackmd.io/_uploads/SyQb0FLFGe.png)
*Figure 19 — Création du compte adm-maintenance avec New-LocalUser, compte activé*

![Figure 20](https://hackmd.io/_uploads/SkN-0KItfg.png)
*Figure 20 — Windows Update indique que cette version de Windows a atteint la fin du support*

En même temps, j'ai pu faire toutes les mises à jour nécessaires. Maintenant, il m'indique que ma version de Windows a atteint la fin du support et me propose de passer à Windows 11, mais je ne suis pas intéressé : Windows 10 est très bien sur certains points.

---

## 7. Dossiers personnels protégés par les droits NTFS

Maintenant, je vais créer des dossiers personnels protégés par les droits NTFS. Le but est que chaque élève ait un dossier privé que les autres ne peuvent pas ouvrir.

Pour cela, il va falloir faire plusieurs étapes : regarder les dossiers, couper l'héritage, donner le contrôle total du dossier à damien et le rendre propriétaire.

### 7.1 Droits sur le dossier de chaque élève

Premièrement, je vais regarder ce qu'il y a dans mon dossier C:\Perso. Avec cette commande, je vais afficher mes dossiers.

```powershell
dir C:\Perso
```

![Figure 21](https://hackmd.io/_uploads/HyrZRY8YMg.png)
*Figure 21 — Contenu de C:\Perso : les dossiers damien, Gael et Yohan*

Maintenant, avec cette commande, je vais regarder qui a des droits d'accès au dossier de damien.

```powershell
icacls C:\Perso\damien
```

![Figure 22](https://hackmd.io/_uploads/rJSZRtLYMg.png)
*Figure 22 — Droits sur C:\Perso\damien : damien, Administrateurs et Système en contrôle total (F)*

On peut voir que c'est juste : seuls damien, les administrateurs et le système ont accès au dossier. Mais pour arriver à cela, j'ai fait les commandes suivantes.

J'ai coupé l'héritage, pour que le dossier ne suive plus automatiquement les droits du dossier parent.

```powershell
icacls C:\Perso\damien /inheritance:d
```

![Figure 23](https://hackmd.io/_uploads/ByU-Ct8Yfl.png)
*Figure 23 — Héritage coupé sur C:\Perso\damien avec /inheritance:d*

Après, je lui ai donné le contrôle total sur le dossier. Les options (OI)(CI) font que les droits s'appliquent aussi aux fichiers et sous-dossiers.

```powershell
icacls C:\Perso\damien /grant "damien:(OI)(CI)F"
```

![Figure 24](https://hackmd.io/_uploads/SJL-RFIFGx.png)
*Figure 24 — Contrôle total donné à damien sur son dossier avec /grant*

Puis je le rends propriétaire, comme ça c'est vraiment son dossier.

```powershell
icacls C:\Perso\damien /setowner damien
```

![Figure 25](https://hackmd.io/_uploads/S1PZ0FUYGl.png)
*Figure 25 — damien défini comme propriétaire de son dossier avec /setowner*

Puis on regarde si tout a bien marché.

```powershell
icacls C:\Perso\Gael
```

![Figure 26](https://hackmd.io/_uploads/BJ8GCt8Fzl.png)
*Figure 26 — Vérification sur C:\Perso\Gael : Gael, Administrateurs et Système en contrôle total*

Et voilà, on peut voir que ça a bien marché, et je fais la même chose pour mes autres profils.

### 7.2 Droits sur le dossier parent C:\Perso

Une fois tout cela fait, il reste une seule chose : le dossier parent.

Cette commande supprime les droits hérités sur le dossier parent C:\Perso. On a créé un dossier privé pour chacun, mais il faut ensuite leur redonner un chemin d'accès.

```powershell
icacls C:\Perso /inheritance:r
```

![Figure 27](https://hackmd.io/_uploads/Bk8zAt8YGe.png)
*Figure 27 — Suppression des droits hérités sur C:\Perso avec /inheritance:r*

Cette commande remet les droits du système (SYSTEM), dont Windows a besoin pour fonctionner correctement.

```powershell
icacls C:\Perso /grant "SYSTEM:(OI)(CI)F"
```

![Figure 28](https://hackmd.io/_uploads/ryDzAYLKfg.png)
*Figure 28 — Contrôle total redonné à SYSTEM sur C:\Perso*

Puis cette commande remet les droits des administrateurs, pour qu'ils puissent toujours gérer les dossiers.

```powershell
icacls C:\Perso /grant "Administrateurs:(OI)(CI)F"
```

![Figure 29](https://hackmd.io/_uploads/SJuf0F8YGx.png)
*Figure 29 — Contrôle total redonné au groupe Administrateurs sur C:\Perso*

Les 3 peuvent passer par le chemin d'accès pour atteindre leur dossier. Avec les droits (RX,AD), ils peuvent parcourir C:\Perso sans avoir le contrôle total dessus.

```powershell
icacls C:\Perso /grant "Utilisateurs:(RX,AD)"
```

![Figure 30](https://hackmd.io/_uploads/HyOGRK8tGl.png)
*Figure 30 — Droits (RX,AD) donnés au groupe Utilisateurs sur C:\Perso*

![Figure 31](https://hackmd.io/_uploads/r1tGCFUKGe.png)
*Figure 31 — Vérification avec icacls C:\Perso : Utilisateurs (RX,AD), Administrateurs et Système (F)*

Et voilà, on peut voir que ça fonctionne : sur C:\Perso, il ne reste que les droits des utilisateurs, des administrateurs et du système. Chaque utilisateur a donc accès à son propre dossier, mais pas aux dossiers des autres.

---

## 8. Verrouillage automatique de la session

Maintenant, je vais mettre un verrouillage automatique de la session après inactivité. Si un élève quitte le poste sans se déconnecter, personne ne pourra utiliser sa session à sa place.

Je fais le raccourci Windows + R et je tape `secpol.msc` pour ouvrir la stratégie de sécurité locale.

![Figure 32](https://hackmd.io/_uploads/SkcGAtLtGx.png)
*Figure 32 — Console Stratégie de sécurité locale*

![Figure 33](https://hackmd.io/_uploads/SJ9GAYUtfx.png)
*Figure 33 — Stratégies locales > Options de sécurité*

![Figure 34](https://hackmd.io/_uploads/HJszRK8KMg.png)
*Figure 34 — Paramètre « Ouverture de session interactive : limite d'inactivité de l'ordinateur », encore non défini*

Puis je vais dans Stratégies locales > Options de sécurité et je cherche « Ouverture de session interactive : limite d'inactivité de l'ordinateur ». Double-clic dessus et mettre 10 min (600 secondes).

![Figure 35](https://hackmd.io/_uploads/BJhGCYUKfl.png)
*Figure 35 — Limite d'inactivité réglée sur 600 secondes*

---

## 9. Politique de mot de passe

Puis je vais mettre une politique de mot de passe. Elle oblige les utilisateurs à choisir des mots de passe solides et à les changer régulièrement.

Je fais le raccourci Windows + R et je tape `secpol.msc`.

![Figure 36](https://hackmd.io/_uploads/Sy2MAKUYze.png)
*Figure 36 — Fenêtre Exécuter avec secpol.msc*

Je vais dans Stratégies de comptes > Stratégie de mot de passe.

![Figure 37](https://hackmd.io/_uploads/Sy6G0FUKzg.png)
*Figure 37 — Stratégies de comptes > Stratégie de mot de passe*

Je règle la longueur minimale du mot de passe. Au final, elle est à 9 caractères, comme on le voit dans la colonne Paramètre de sécurité.

![Figure 38](https://hackmd.io/_uploads/BkpGRKIKGl.png)
*Figure 38 — Propriétés de « Longueur minimale du mot de passe »*

J'active « Le mot de passe doit respecter des exigences de complexité ». Le mot de passe doit alors mélanger plusieurs types de caractères : majuscules, minuscules, chiffres et caractères spéciaux.

![Figure 39](https://hackmd.io/_uploads/B1AfCtIYfl.png)
*Figure 39 — Exigences de complexité activées, longueur minimale à 9 caractères*

J'active aussi « Enregistrer les mots de passe en utilisant un chiffrement réversible ».

![Figure 40](https://hackmd.io/_uploads/ry1mCKLtzg.png)
*Figure 40 — « Enregistrer les mots de passe en utilisant un chiffrement réversible » activé*

Je mets la durée de vie minimale à 90 jours : le mot de passe ne peut pas être changé avant ce délai.

![Figure 41](https://hackmd.io/_uploads/B1JmRYIYfx.png)
*Figure 41 — Durée de vie minimale du mot de passe : 90 jours*

Je mets la durée de vie maximale à 360 jours : après ce délai, le mot de passe expire et il faut en choisir un nouveau.

![Figure 42](https://hackmd.io/_uploads/rylmCYLtfe.png)
*Figure 42 — Durée de vie maximale du mot de passe : 360 jours*

Je conserve l'historique des 4 derniers mots de passe, pour qu'un utilisateur ne puisse pas réutiliser un ancien mot de passe.

![Figure 43](https://hackmd.io/_uploads/BJWmAKIFfe.png)
*Figure 43 — Historique des mots de passe : 4 mots de passe mémorisés*

---

## 10. Test avec les 3 comptes

Et maintenant, je vais faire un test pour voir que tout fonctionne pour les 3 comptes : chacun ne doit pas pouvoir ouvrir le dossier des autres, ni avoir les droits admin.

### 10.1 Damien

![Figure 44](https://hackmd.io/_uploads/H1-XRKUKGl.png)
*Figure 44 — Damien : Windows demande le mot de passe d'un administrateur pour lancer l'invite de commandes*

![Figure 45](https://hackmd.io/_uploads/r1f7CY8Fzl.png)
*Figure 45 — Damien : accès refusé au dossier Yohan*

### 10.2 Yohan

![Figure 46](https://hackmd.io/_uploads/B1mQ0K8FGl.png)
*Figure 46 — Yohan : accès refusé au dossier damien*

![Figure 47](https://hackmd.io/_uploads/BJQ7AK8Yzx.png)
*Figure 47 — Yohan : Windows demande le mot de passe d'un administrateur pour modifier la sécurité*

### 10.3 Gael

![Figure 48](https://hackmd.io/_uploads/rJV7AtLYGl.png)
*Figure 48 — Gael : accès refusé au dossier Yohan*

![Figure 49](https://hackmd.io/_uploads/BySXCK8Yzl.png)
*Figure 49 — Gael : Windows demande le mot de passe d'un administrateur pour modifier la sécurité*

![Figure 50](https://hackmd.io/_uploads/rkHQ0tLKzl.png)
*Figure 50 — Gael : son propre dossier C:\Perso\Gael s'ouvre*

Son propre dossier s'ouvre bien.

---

## 11. Récapitulatif

| Élément | Configuration retenue |
|---|---|
| Machine virtuelle | VMware Workstation Pro 17, 80 Go, 8780 Mo de RAM, 8 cœurs, NAT |
| Système | Windows 10 Éducation x64, fuseau UTC+01:00, région Suisse |
| Compte administrateur | AR.BR, protégé par un mot de passe |
| Compte de maintenance | adm-maintenance, créé avec New-LocalUser |
| Comptes élèves | damien, Yohan, Gael (comptes standard) |
| Dossiers personnels | C:\Perso\(nom de l'élève) : héritage coupé, contrôle total et propriété pour l'élève |
| Dossier parent C:\Perso | SYSTEM et Administrateurs (F), Utilisateurs (RX,AD) |
| Verrouillage de session | Limite d'inactivité de 600 secondes |
| Politique de mot de passe | 9 caractères, complexité, durée de vie 90 à 360 jours, historique de 4 |

---

## 12. Conclusion

Au final, j'ai un poste Windows 10 dans une VM avec un compte administrateur protégé par un mot de passe, un compte de maintenance et 3 comptes élèves standard. Chaque élève a son dossier privé dans C:\Perso, protégé par les droits NTFS. La session se verrouille après 10 minutes d'inactivité et une politique de mot de passe oblige à utiliser des mots de passe solides.

Les tests montrent que les 3 comptes n'ont pas les droits administrateur et ne peuvent pas ouvrir les dossiers des autres.

Ce projet m'a appris à gérer des comptes et des droits en ligne de commande avec net user et icacls, et à utiliser la stratégie de sécurité locale. J'ai aussi compris qu'il faut penser au dossier parent : protéger les dossiers personnels ne suffit pas, il faut que les utilisateurs puissent encore y accéder.

Avant une vraie mise en production, on pourrait encore :

- désactiver le chiffrement réversible des mots de passe, qui les rend plus faciles à récupérer en cas d'attaque ;
- passer à une version de Windows encore supportée, car Windows 10 ne reçoit plus de mises à jour de sécurité ;
- mettre en place une sauvegarde des dossiers personnels des élèves.
