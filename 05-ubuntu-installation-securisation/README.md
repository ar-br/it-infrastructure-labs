# Ubuntu 26.04 — Installation en VM, mise à jour et sécurité de base

> Installation d'Ubuntu 26.04 Desktop dans VMware Workstation avec justification de chaque choix, puis configuration post-installation en ligne de commande : mises à jour apt, vérification réseau, activation du pare-feu UFW et contrôle des services.

**Contexte :** Projet d'école — Geneva Institute of Technology, 1ère année · septembre 2026 · projet individuel

**Technologies :** Ubuntu 26.04 LTS · VMware Workstation Pro 17 · Bash · apt · nmcli · ip · UFW · systemd/service

### Compétences mises en œuvre

- Dimensionnement d'une VM (CPU, RAM, disque) en fonction de l'hôte
- Installation Linux raisonnée : hors-ligne, partitionnement, chiffrement, pilotes propriétaires
- Gestion des paquets : `apt update` vs `apt upgrade`, `autoremove`
- Diagnostic réseau : interfaces, DHCP, NAT, adresse MAC, tests `ping`
- Sécurité de base : pare-feu UFW, revue des services lancés au démarrage

---

> **Procédure pas à pas illustrée**
> Version installée : Ubuntu 26.04 Desktop (64 bits)
> Hyperviseur : VMware Workstation Pro 17.5.2
> Système hôte : Windows 11
> Date : 9 septembre 2026

---

## Objectif et prérequis

Ce document décrit l'installation complète d'Ubuntu 26.04 dans une machine virtuelle VMware Workstation Pro 17, depuis la récupération du fichier ISO jusqu'au lancement de l'installation du système.

Travailler dans une machine virtuelle permet de tester un système d'exploitation sans toucher à la machine physique : en cas d'erreur, il suffit de supprimer la VM ou de revenir à un instantané (snapshot).

### Prérequis

- VMware Workstation Pro 17 installé sur la machine hôte.
- Le fichier ISO d'Ubuntu 26.04 Desktop 64 bits (environ 6 Go).
- Au minimum 8 Go de RAM et 40 Go d'espace disque libre sur l'hôte.
- La virtualisation matérielle (Intel VT-x ou AMD-V) activée dans le BIOS/UEFI.

### Configuration retenue pour la machine virtuelle

| Élément | Valeur retenue |
| --- | --- |
| Système invité | Ubuntu 26.04 Desktop 64 bits |
| Hyperviseur | VMware Workstation Pro 17.5.2 |
| Processeurs | 4 processeurs x 2 cœurs (8 cœurs au total) |
| Mémoire vive | 8 Go (8192 Mo) |
| Disque dur virtuel | 40 Go, réparti en plusieurs fichiers |
| Emplacement | `C:\VM Pro\unbuntu test` (disque local) |
| Carte réseau | NAT |
| Chiffrement du disque | Aucun |

---

## Partie 1 – Récupération du fichier ISO

L'image ISO est le fichier qui contient l'intégralité du système d'exploitation. C'est l'équivalent numérique d'un DVD d'installation : sans ce fichier, il est impossible d'installer Ubuntu. La machine virtuelle le montera comme un lecteur CD/DVD virtuel pour démarrer dessus.

Dans mon cas, l'ISO m'a été transmise via un lien SwissTransfer. Il est également possible de la télécharger directement depuis le site officiel ubuntu.com.

![figure-01](https://hackmd.io/_uploads/HyzbxhROGx.png)

> [!NOTE]
> **À vérifier avant de continuer**
> - Le fichier doit porter l'extension `.iso` et non `.zip` ou `.img`.
> - Vérifier que le téléchargement est bien complet : une ISO tronquée provoque un plantage en plein milieu de l'installation.
> - Noter l'emplacement du fichier (ici le dossier Téléchargements), il sera demandé à l'étape suivante.

---

## Partie 2 – Création de la machine virtuelle

Cette partie consiste à définir le « matériel » virtuel de la machine : disque, mémoire, processeurs et lecteur de CD/DVD contenant l'ISO.

### 2.1 – Lancer l'assistant de création

Depuis l'onglet **Home** de VMware Workstation Pro, cliquer sur **Create a New Virtual Machine**. L'assistant de création s'ouvre alors.

![figure-02](https://hackmd.io/_uploads/S1C-g2R_ze.png)

### 2.2 – Choisir le type de configuration

Deux modes sont proposés :

- **Typical (recommended)** : VMware choisit lui-même les paramètres techniques (contrôleur SCSI, type de disque, compatibilité). C'est le mode le plus rapide et il convient parfaitement ici.
- **Custom (advanced)** : permet de régler manuellement chaque paramètre. Utile uniquement pour des besoins particuliers, par exemple assurer la compatibilité avec une ancienne version de VMware.

Je sélectionne **Typical**, puis **Next**.

![figure-03](https://hackmd.io/_uploads/SJKNx3A_fl.png)

### 2.3 – Sélectionner l'image ISO

L'assistant demande d'où provient le système à installer. Je coche **Installer disc image file (iso)**, puis **Browse** pour aller chercher le fichier dans le dossier Téléchargements.

VMware analyse l'image et affiche un message de confirmation : « Ubuntu 64-bit 26.04 detected ». Cette détection automatique déclenche le mode **Easy Install**, qui préremplit une partie de l'installation d'Ubuntu.

![figure-04](https://hackmd.io/_uploads/HkSHg2CdMg.png)

![figure-05](https://hackmd.io/_uploads/B1zIg3AuGl.png)

### 2.4 – Renseigner le compte utilisateur (Easy Install)

Comme le mode Easy Install est actif, VMware demande dès maintenant le nom complet, le nom d'utilisateur et le mot de passe du futur compte Linux. Ces informations seront réinjectées automatiquement pendant l'installation d'Ubuntu.

![figure-06](https://hackmd.io/_uploads/S1j8x2COMg.png)

![figure-07](https://hackmd.io/_uploads/Bkmqx2CuMg.png)

> [!NOTE]
> **Bon à savoir**
> - Le nom d'utilisateur doit être en minuscules et sans espace ni accent.
> - Ce mot de passe servira aussi pour toutes les commandes `sudo` : il ne faut pas l'oublier.

### 2.5 – Nommer la machine et choisir son emplacement

Il faut ensuite donner un nom à la machine virtuelle et indiquer le dossier dans lequel ses fichiers seront stockés.

Je place la VM sur le disque local `C:`, dans un dossier dédié. C'est important : si les fichiers sont enregistrés sur un disque réseau, une clé USB ou un dossier synchronisé sur le cloud (OneDrive, Google Drive), les performances s'effondrent, car le disque virtuel est sollicité en permanence en lecture et en écriture.

![figure-08](https://hackmd.io/_uploads/ryTbWn0_fx.png)

### 2.6 – Définir la capacité du disque virtuel

VMware recommande 20 Go pour Ubuntu ; j'ai porté cette valeur à 40 Go afin d'avoir de la marge pour installer des paquets et des outils par la suite.

Deux modes de stockage sont proposés :

- **Store virtual disk as a single file** : un seul gros fichier, légèrement plus performant.
- **Split virtual disk into multiple files** : le disque est découpé en plusieurs fichiers de 2 Go. C'est l'option que je retiens, car elle facilite la copie de la VM d'une machine à l'autre.

À noter : le disque n'occupe pas immédiatement 40 Go sur l'hôte. Il grossit au fur et à mesure que la VM se remplit.

![figure-09](https://hackmd.io/_uploads/Byczb2RuGg.png)

### 2.7 – Vérifier le récapitulatif et personnaliser le matériel

L'assistant affiche un résumé de la configuration. Les valeurs par défaut proposées ici (4 Go de RAM, 2 cœurs) sont suffisantes, mais je souhaite plus de ressources : je clique donc sur **Customize Hardware** avant de valider avec **Finish**.

![figure-10](https://hackmd.io/_uploads/BJVXZhA_Ge.png)

### 2.8 – Ajuster la mémoire vive

Je porte la mémoire allouée à 8192 Mo, soit 8 Go. VMware affiche trois repères utiles sur la réglette :

- Le minimum recommandé par le système invité : 2 Go.
- La valeur recommandée : 4 Go.
- Le maximum conseillé selon la RAM de l'hôte : 11,6 Go.

Il ne faut jamais dépasser ce maximum, sinon l'hôte se met à utiliser son fichier d'échange et l'ensemble devient très lent.

![figure-11](https://hackmd.io/_uploads/H1eNW30_fx.png)

### 2.9 – Ajuster les processeurs

Je configure 4 processeurs virtuels de 2 cœurs chacun, soit 8 cœurs au total. Là encore, il faut rester en dessous du nombre de cœurs physiques de la machine hôte, sous peine de dégrader les performances au lieu de les améliorer.

Les options du bloc « Virtualization engine » restent décochées : elles ne servent que pour la virtualisation imbriquée, c'est-à-dire faire tourner un hyperviseur à l'intérieur de la VM.

Un clic sur **Close**, puis sur **Finish**, crée la machine virtuelle et la démarre automatiquement.

![figure-12](https://hackmd.io/_uploads/Sk2NbhCdze.png)

---

## Partie 3 – Premier démarrage de la machine

La machine virtuelle démarre sur l'image ISO. Un écran violet affichant « Ubuntu 26.04 » apparaît : c'est le chargement de la session live, qui prend généralement une à deux minutes.

![figure-13](https://hackmd.io/_uploads/SkKS-nA_Gx.png)

Des messages du noyau peuvent défiler pendant cette phase, comme ici des avertissements relatifs au Bluetooth. Ils sont sans conséquence : la VM tente d'initialiser un périphérique qui n'existe pas réellement. Il suffit d'attendre.

![figure-14](https://hackmd.io/_uploads/Sy9YZ20_Gx.png)

---

## Partie 4 – Installation d'Ubuntu

L'assistant graphique d'Ubuntu prend le relais. Il se compose d'une quinzaine d'écrans successifs, matérialisés par les points de progression en bas de la fenêtre.

### 4.1 – Choix de la langue

Le premier écran permet de sélectionner la langue de l'installateur, qui sera aussi celle du système une fois installé. Je choisis le français.

![figure-15](https://hackmd.io/_uploads/BJkob3AOMe.png)

### 4.2 – Connexion à Internet

Je coche « Je ne souhaite pas me connecter à internet pour l'instant ». Ce choix se justifie pour plusieurs raisons :

- L'installateur ne télécharge alors ni mises à jour ni logiciels supplémentaires, ce qui réduit fortement la durée de l'installation.
- On évite les blocages liés à un miroir de dépôt lent ou indisponible.
- L'installation reste reproductible : deux machines installées à des moments différents partent de la même base.

La VM conserve malgré tout son accès réseau grâce à la carte en mode NAT. Les mises à jour pourront donc être faites après le premier démarrage avec la commande `sudo apt update && sudo apt upgrade`.

![figure-16](https://hackmd.io/_uploads/B1js-2A_fe.png)

### 4.3 – Mise à jour de l'installateur

Ubuntu propose de mettre à jour son propre programme d'installation. Je clique sur **Ignorer** : la version fournie avec l'ISO fonctionne parfaitement et cette mise à jour rallongerait inutilement la procédure.

![figure-17](https://hackmd.io/_uploads/rkB2-2Cufe.png)

### 4.4 – Installer ou essayer Ubuntu

Deux possibilités sont offertes : essayer Ubuntu en session live, sans rien modifier, ou l'installer réellement sur le disque. Je sélectionne **Installer Ubuntu**.

![figure-18](https://hackmd.io/_uploads/rylaWh0dMx.png)

### 4.5 – Type d'installation

Je retiens l'**Installation interactive**, qui déroule les écrans un par un. Les deux autres options (fichier `autoinstall.yaml` et Landscape) servent à déployer automatiquement un grand nombre de machines identiques en entreprise.
![figure-19](https://hackmd.io/_uploads/Bk-gz2RdGg.png)

### 4.6 – Applications à installer

L'**Installation par défaut** ne met en place que l'essentiel : le navigateur et les utilitaires de base. L'**Installation complète** ajoute la suite bureautique, des jeux et divers outils, mais alourdit sensiblement l'installation. Je choisis la première option.

![figure-20](https://hackmd.io/_uploads/S1VyM3R_ze.png)

### 4.7 – Logiciels propriétaires

Je laisse les deux cases décochées afin de gagner du temps, mon objectif étant d'obtenir un système fonctionnel rapidement.

- **Pilotes tiers (graphiques et Wi-Fi)** : inutiles ici, la VM utilise du matériel virtuel émulé par VMware.
- **Codecs multimédias** : ils peuvent être installés plus tard avec le paquet `ubuntu-restricted-extras`.

Sur une machine physique équipée d'une carte graphique NVIDIA ou d'une carte Wi-Fi, il serait en revanche conseillé de cocher la première case.

![figure-21](https://hackmd.io/_uploads/HkM-G3Rdzx.png)

### 4.8 – Configuration du disque

Je choisis **Effacer le disque et installer Ubuntu**. L'avertissement affiché en rouge indique que toutes les données du disque seront supprimées : dans une machine virtuelle, cela ne concerne que le disque virtuel de 40 Go créé plus tôt, qui est vide. Le disque physique de l'hôte n'est absolument pas touché.

L'option **Partitionnement manuel** permettrait de définir soi-même les partitions (`/`, `/home`, swap), ce qui n'a pas d'intérêt dans le cadre de ce test.

![figure-22](https://hackmd.io/_uploads/ByyQM30dfl.png)

### 4.9 – Chiffrement du disque

Je sélectionne **Pas de chiffrement**. Le chiffrement protège les données en cas de vol de la machine, mais il impose la saisie d'une phrase secrète à chaque démarrage et ralentit légèrement le système. Il n'apporte rien pour une VM de test.

![figure-23](https://hackmd.io/_uploads/HysQz2C_fe.png)

### 4.10 – Création du compte utilisateur

Cet écran demande le nom de l'utilisateur, le nom de l'ordinateur sur le réseau, l'identifiant de connexion et le mot de passe. Je laisse cochée l'option demandant le mot de passe à l'ouverture de session ; la case Active Directory reste décochée, puisqu'il n'y a pas de domaine dans cet environnement.

![figure-24](https://hackmd.io/_uploads/HkPVGnCufg.png)

### 4.11 – Fuseau horaire

Je sélectionne **Europe/Zurich**. Un fuseau correct est important pour l'horodatage des fichiers, la validité des certificats et la lecture des journaux système.

![figure-25](https://hackmd.io/_uploads/ByWHf30_Ml.png)

### 4.12 – Récapitulatif et lancement

Le dernier écran résume tous les choix effectués : effacement du disque, disque cible VMware Virtual S (`sda`), installation par défaut, aucun chiffrement, aucun logiciel propriétaire, et une partition `sda2` formatée en ext4 montée sur la racine `/`.

C'est le dernier moment pour revenir en arrière. Une fois la vérification faite, je clique sur **Installer**.

![figure-26](https://hackmd.io/_uploads/S1hrG3AOzg.png)

### 4.13 – Copie des fichiers

L'installation se lance. La barre de progression indique la copie des fichiers, opération qui dure une dizaine de minutes selon les performances de la machine hôte. Il ne faut ni interrompre le processus ni éteindre la machine virtuelle pendant cette phase.

![figure-27](https://hackmd.io/_uploads/HkSIG3Rufl.png)

---

### Bilan de l'installation

À la fin de la copie, l'installateur demande de redémarrer la machine puis de retirer le support d'installation. Dans VMware, il suffit d'appuyer sur Entrée : le lecteur CD/DVD virtuel est démonté automatiquement.

Ubuntu 26.04 est alors installé et pleinement fonctionnel. Il reste toutefois à le mettre à jour, puisque l'installation a volontairement été réalisée hors ligne : c'est l'objet de la partie suivante.

> [!TIP]
> **Récapitulatif des choix orientés « rapidité »**
> - Pas de connexion Internet pendant l'installation.
> - Mise à jour de l'installateur ignorée.
> - Installation par défaut plutôt que complète.
> - Aucun logiciel propriétaire ni codec supplémentaire.
> - Aucun chiffrement du disque.
>
> Ces choix sont adaptés à une machine virtuelle de test. Sur une machine physique destinée à un usage quotidien, il serait pertinent de revenir sur les pilotes propriétaires, les codecs et le chiffrement.

---

## Partie 5 – Mise à jour du système et vérification du réseau

> **Premières commandes dans le terminal Ubuntu**

Une fois Ubuntu installé et démarré, la première chose à faire est de mettre le système à jour. C'est indispensable ici, puisque l'installation a volontairement été réalisée sans connexion Internet : la machine tourne donc avec les paquets figés de l'image ISO, dont certains présentent déjà des correctifs de sécurité en attente.

Cette partie se déroule intégralement en ligne de commande, dans le terminal.

---

### 5.1 – Ouvrir le terminal

Le terminal se lance depuis l'icône présente dans la barre latérale, ou plus rapidement avec le raccourci clavier **Ctrl + Alt + T**.

![figure-01](https://hackmd.io/_uploads/SyJrUn0Oze.png)

La ligne affichée s'appelle l'invite de commande (le « prompt »). Elle se décompose ainsi :

```
qrbr@qrbr-VMware-Virtual-Platform:~$
```

- `qrbr` : le nom de l'utilisateur connecté.
- `qrbr-VMware-Virtual-Platform` : le nom de la machine sur le réseau, défini pendant l'installation.
- `~` : le dossier courant. Le tilde désigne le dossier personnel, soit `/home/qrbr`.
- `$` : indique une session utilisateur normale. Un `#` à cet endroit signifierait que l'on travaille en tant que root.

---

### 5.2 – Rafraîchir la liste des paquets

La commande `sudo apt update` interroge les dépôts Ubuntu et met à jour le catalogue local des paquets disponibles.

```bash
sudo apt update
```

Le préfixe `sudo` exécute la commande avec les droits d'administrateur. Le mot de passe de session est alors demandé : rien ne s'affiche à l'écran pendant la saisie, pas même des astérisques. C'est normal, il faut taper le mot de passe puis valider avec Entrée.

![figure-02](https://hackmd.io/_uploads/rJarL3ROzl.png)

Les quatre lignes « Atteint » correspondent aux dépôts consultés :

- `resolute` : le dépôt principal, « resolute » étant le nom de code d'Ubuntu 26.04.
- `resolute-updates` : les mises à jour courantes publiées après la sortie de la version.
- `resolute-backports` : des versions plus récentes de certains logiciels, rétroportées.
- `resolute-security` : les correctifs de sécurité, hébergés sur un serveur distinct.

L'adresse `ch.archive.ubuntu.com` indique que le miroir suisse est utilisé, ce qui est cohérent avec le fuseau horaire choisi à l'installation.

> [!NOTE]
> **Détail visible sur la capture**
>
> La première commande saisie est `sudo apt upgarde` : le mot *upgrade* est mal orthographié, ce qui provoque le message « L'opération upgarde n'est pas valable ».
>
> Le terminal n'interprète que des commandes exactes. Une lettre inversée suffit à faire échouer la ligne, sans aucune conséquence sur le système. Il suffit de retaper la commande correctement.
>
> La touche **Tab** permet d'éviter ce type d'erreur : elle complète automatiquement le nom de la commande.

---

### 5.3 – Appliquer les mises à jour

À la fin de l'opération, apt annonce que **125 paquets peuvent être mis à jour** et propose la commande permettant d'en afficher le détail.

```bash
apt list --upgradable
```

![figure-03](https://hackmd.io/_uploads/HkuOI2COGl.png)

> [!WARNING]
> **Point important : `update` et `upgrade` ne font pas la même chose**
>
> - `sudo apt update` ne fait que **rafraîchir le catalogue** des paquets. Aucun logiciel n'est installé ni modifié à ce stade.
> - `sudo apt upgrade` **télécharge et installe** réellement les nouvelles versions.
>
> Sur la capture ci-dessus, la commande saisie est `sudo apt update -y` : elle relance donc simplement la lecture des dépôts. Pour appliquer effectivement les 125 mises à jour, il faut enchaîner avec `upgrade`.
>
> L'option `-y` répond automatiquement « oui » à la demande de confirmation, ce qui évite d'avoir à valider manuellement.

La commande complète à exécuter est donc la suivante :

```bash
sudo apt update && sudo apt upgrade -y
```

Le double esperluette `&&` enchaîne les deux commandes : la seconde ne s'exécute que si la première s'est terminée sans erreur. L'opération dure quelques minutes selon le nombre de paquets et le débit disponible.

## Partie 6 – Configuration initiale et sécurité de base

Cette partie résume les étapes suivies pour préparer une machine Ubuntu fraîchement installée : mise à jour des paquets, configuration du clavier, vérification de la connexion réseau, puis activation du pare-feu et contrôle des services lancés au démarrage. Chaque étape est accompagnée d'une courte explication et d'une capture d'écran illustrant le résultat obtenu dans le terminal ou dans les paramètres système.

---

### 6.1 – Mise à jour du système

#### Mise à jour des paquets installés

La première étape consiste à mettre à jour la liste des paquets ainsi que tous les logiciels déjà installés, afin de bénéficier des derniers correctifs de sécurité et des dernières corrections de bugs. On utilise pour cela la commande suivante :

```bash
sudo apt upgrade
```

![01-sudo-apt-upgrade](https://hackmd.io/_uploads/SJrlOY-Yzg.png)

*Figure 1 — Lancement de la commande `sudo apt upgrade` dans le terminal.*

![02-lecture-des-paquets](https://hackmd.io/_uploads/HkSZ_KbKMl.png)

*Figure 2 — Le système lit la liste des paquets disponibles (ici 41 %) avant de proposer les mises à jour à installer.*

#### Nettoyage des paquets inutiles

Une fois la mise à jour terminée, la commande `sudo apt autoremove` permet de supprimer les paquets qui ont été installés automatiquement comme dépendances mais qui ne sont plus utilisés par aucun logiciel. Cela permet de garder le système propre et de libérer de l'espace disque.

```bash
sudo apt autoremove
```

Résultat de la commande : aucun paquet à retirer, le système était déjà propre.

---

### 6.2 – Configuration du clavier

Par défaut, la disposition du clavier n'était pas correcte. Il faut donc l'ajouter manuellement depuis les paramètres système, en suivant le chemin **Paramètres > Clavier > Sources de saisie**.

#### Ouverture des paramètres système

On ouvre d'abord l'application Paramètres, qui s'affiche par défaut sur la page « Réseau ».

![05-parametres-menu-clavier](https://hackmd.io/_uploads/r17UOtbtfe.png)

*Figure 4 — Fenêtre des paramètres système, page Réseau affichée par défaut.*

#### Accès à la rubrique Clavier

Dans le menu de gauche, on descend jusqu'à trouver l'entrée « Keyboard » (Clavier), mise en évidence ci-dessous, puis on clique dessus.

![05-parametres-menu-clavier](https://hackmd.io/_uploads/HygcdY-Kzg.png)

*Figure 5 — Le menu latéral des paramètres, avec l'entrée Clavier repérée.*

#### Ajout de la disposition French (Switzerland)

Dans la rubrique « Input Sources », on ajoute la disposition French (Switzerland), qui correspond au clavier romand utilisé sur ce poste.

![06-clavier-french-switzerland](https://hackmd.io/_uploads/H18o_tWYzl.png)

*Figure 6 — La disposition French (Switzerland) est bien ajoutée comme source de saisie.*

---

### 6.3 – Vérification du réseau

#### État des interfaces réseau

On vérifie ensuite que le réseau fonctionne correctement. La commande `nmcli device status` affiche la liste des interfaces réseau de la machine ainsi que leur état de connexion.

```bash
nmcli device status
```

![07-nmcli-device-status](https://hackmd.io/_uploads/BJmhdKbKMe.png)

*Figure 7 — L'interface filaire ens33 est bien connectée (état « connected »).*

#### Test de connectivité vers Internet

Pour confirmer que la connexion fonctionne réellement, on envoie quatre requêtes ping vers google.com. Cette commande teste à la fois la résolution DNS et l'accès effectif à Internet.

```bash
ping -c 4 google.com
```

![08-ping-google](https://hackmd.io/_uploads/HJa6dYWFfl.png)

*Figure 8 — Les 4 paquets envoyés ont bien reçu une réponse (0 % de perte), la connexion Internet fonctionne.*

---

### 6.4 – Activation du pare-feu (UFW)

Afin de sécuriser un minimum la machine, on active le pare-feu UFW (*Uncomplicated Firewall*), qui va bloquer par défaut les connexions entrantes non autorisées.

```bash
sudo ufw enable
```

![09-sudo-ufw-enable](https://hackmd.io/_uploads/HkRCuYZYzl.png)

*Figure 9 — Le pare-feu est actif et sera automatiquement relancé à chaque démarrage du système.*

---

### 6.5 – Vérification des services au démarrage

Enfin, on contrôle quels services sont lancés automatiquement au démarrage du système grâce à la commande `service --status-all`. Le symbole `[ + ]` indique un service actif, et `[ - ]` un service inactif.

```bash
service --status-all
```

![10-service-status-all](https://hackmd.io/_uploads/By3JKKZtGg.png)

*Figure 10 — Extrait de la liste des services système et de leur état actuel.*

---

### 6.6 – Vérifier la configuration IP

La commande `ip a` (abréviation de `ip address`) affiche toutes les interfaces réseau de la machine ainsi que les adresses qui leur sont attribuées. Elle remplace l'ancienne commande `ifconfig`, aujourd'hui obsolète.

```bash
ip a
```

![figure-04](https://hackmd.io/_uploads/ByiwUhROGx.png)

Deux interfaces apparaissent :

- `lo` : l'interface de bouclage (loopback), adresse `127.0.0.1`. Elle permet à la machine de communiquer avec elle-même et existe toujours, même sans réseau.
- `ens33` : la carte réseau virtuelle fournie par VMware. La mention `state UP` confirme qu'elle est active.

Les informations utiles concernant cette carte sont les suivantes :

- **Adresse IP** : `192.168.136.133/24`. Le suffixe /24 correspond au masque 255.255.255.0, soit un réseau pouvant accueillir 254 machines.
- **Adresse de diffusion** : `192.168.136.255`.
- **Adresse MAC** : `00:0c:29:86:4d:56`. Le préfixe `00:0c:29` est réservé à VMware, ce qui confirme qu'il s'agit bien d'une carte virtuelle.
- La mention `dynamic` et le compteur `valid_lft` indiquent que l'adresse a été obtenue par **DHCP** et qu'elle est louée pour une durée limitée, renouvelée automatiquement.

Cette adresse est celle du réseau NAT de VMware : elle n'est visible que depuis la machine hôte, et non depuis le réseau local physique. C'est le comportement attendu avec la carte configurée en mode NAT à la partie 2.

---

## Récapitulatif des commandes

| Commande | Rôle |
| --- | --- |
| `sudo apt update` | Rafraîchit la liste des paquets disponibles. N'installe rien. |
| `apt list --upgradable` | Affiche le détail des paquets pouvant être mis à jour. |
| `sudo apt upgrade -y` | Télécharge et installe réellement les mises à jour. |
| `sudo apt autoremove` | Supprime les paquets devenus inutiles après la mise à jour. |
| `ip a` | Affiche les interfaces réseau et leurs adresses IP. |
| `ping -c 4 8.8.8.8` | Vérifie que la VM atteint bien Internet. |

À l'issue de cette partie, le système est à jour et sa connectivité réseau est vérifiée.

---

## Conclusion

La machine virtuelle est désormais opérationnelle : Ubuntu 26.04 est installé, les 125 paquets en attente ont été appliqués et l'interface réseau répond correctement.

Trois opérations restent recommandées avant de commencer à travailler dessus :

- Installer les VMware Tools (`open-vm-tools-desktop`) pour bénéficier du redimensionnement automatique de l'écran, du presse-papiers partagé et du glisser-déposer entre l'hôte et la machine virtuelle.
- Lancer `sudo apt autoremove` afin de supprimer les paquets devenus inutiles après la mise à jour.
- Créer un instantané (snapshot) de la machine propre, ce qui permet de revenir à cet état en une seule opération en cas de mauvaise manipulation.

L'ensemble de la procédure aura demandé environ une heure, dont la moitié pour la copie des fichiers et les mises à jour. Le principal gain de temps vient des choix faits pendant l'installation : pas de connexion Internet, pas de logiciels propriétaires et pas de chiffrement.

