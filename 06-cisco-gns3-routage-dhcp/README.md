# Routeurs Cisco sous GNS3 — Adressage, DHCP et routage statique

> Mise en place sous GNS3 de deux réseaux locaux reliés par deux routeurs Cisco 7200 : configuration des interfaces en CLI Cisco IOS, serveur DHCP sur chaque routeur, liaison inter-routeurs et routage statique, avec une phase de dépannage méthodique.

**Contexte :** Projet d'école — Geneva Institute of Technology, 1ère année · septembre 2026 · projet individuel

**Technologies :** GNS3 · Cisco IOS 15.2 (routeurs 7200) · VPCS · DHCP · routage statique

### Compétences mises en œuvre

- Configuration de routeurs Cisco en ligne de commande (`hostname`, interfaces, `no shutdown`, `write memory`)
- Adressage IPv4 et découpage en réseaux (2 LAN + 1 réseau de liaison)
- Serveur DHCP sur routeur : pool, exclusion d'adresses, passerelle, DNS, durée de bail
- Dépannage réseau méthodique : interface, câblage, trafic reçu (`show ip interface brief`, `show interfaces`)
- Interconnexion de routeurs et routage statique (`ip route`)
- Regard critique sur sa propre configuration : erreurs identifiées et corrections documentées

---

> Dans ce projet, je monte sous GNS3 une petite infrastructure de deux réseaux locaux reliés par deux routeurs Cisco. Je configure les interfaces, un serveur DHCP sur chaque routeur, puis le routage statique entre les deux réseaux.

| Élément | Configuration |
|---|---|
| Logiciel de simulation | GNS3 2.2.61 (Windows) |
| Routeurs | 2 × Cisco 7200 (IOS 15.2) — `routeur01` et `routeur02` |
| Switchs | 2 × Ethernet switch GNS3 (Switch1, Switch2) |
| Postes | 6 × VPCS (PC1 à PC6) |
| LAN 1 (routeur01) | 192.168.33.0/24 — routeur01 en 192.168.33.4 (Gi1/0) |
| LAN 2 (routeur02) | 192.168.32.0/24 — routeur02 en 192.168.32.1 (Gi1/0) |
| Liaison entre routeurs | 192.168.22.0/24 — routeur01 en .3, routeur02 en .1 (Gi2/0) |
| Services | DHCP sur chaque routeur, routes statiques |

---

## 1. Introduction et objectifs

L'objectif est de construire un réseau d'entreprise simplifié : deux sites (ou deux services), chacun avec son propre réseau local, qui doivent pouvoir communiquer entre eux. C'est le rôle du routeur : relier des réseaux différents et faire passer les paquets de l'un à l'autre.

Je travaille dans **GNS3**, un simulateur réseau qui fait tourner de vraies images de routeurs Cisco. Ça me permet de tester toute la configuration sans matériel physique, de casser et recommencer autant que je veux, et de voir exactement ce qui se passe sur chaque équipement.

Les étapes à réaliser :

- créer le projet et placer les équipements dans GNS3 ;
- nommer le routeur et configurer son interface côté réseau local ;
- câbler le routeur, le switch et les postes ;
- mettre en place un serveur DHCP sur le routeur ;
- diagnostiquer et corriger les problèmes de connectivité ;
- reproduire la configuration sur le deuxième routeur ;
- relier les deux routeurs et configurer le routage statique ;
- tester la communication.

---

## 2. Création du projet dans GNS3

Je lance GNS3 et je crée un nouveau projet. Le nom du projet sert aussi de nom au dossier où GNS3 enregistre toutes les configurations, donc je choisis un nom explicite.

![Figure 1](https://hackmd.io/_uploads/H1OcdIYcMg.png)
*Figure 1 — Fenêtre « New project » de GNS3 au lancement*

Je place ensuite les équipements dont j'ai besoin : deux routeurs (R1 et R2), deux switchs et six postes VPCS, trois par réseau. Les VPCS sont des postes très légers intégrés à GNS3 : ils suffisent pour tester l'adressage IP, le DHCP et les pings.

![Figure 2](https://hackmd.io/_uploads/Bkcc_LYqMe.png)
*Figure 2 — Les équipements placés dans l'espace de travail, pas encore câblés*

---

## 3. Configuration de base du routeur 1

### 3.1 Accès à la console et nom du routeur

J'ouvre la console du routeur R1. Au démarrage, on voit l'IOS Cisco se charger et toutes les interfaces passer en état *administratively down* : sur un routeur Cisco, les interfaces sont désactivées par défaut.

![Figure 3](https://hackmd.io/_uploads/H1jq_LFcGg.png)
*Figure 3 — Console de R1 au démarrage (Cisco IOS 7200, version 15.2)*

Je commence par donner un nom au routeur. Ça paraît anodin, mais dès qu'il y a plusieurs équipements, un nom clair dans l'invite de commande évite de taper une configuration sur le mauvais routeur.

J'entre d'abord en mode de configuration globale :

```cisco
conf t
```

`conf t` est le raccourci de `configure terminal`. Puis je définis le nom :

```cisco
hostname routeur01
```

![Figure 4](https://hackmd.io/_uploads/r1s5_Lt5zg.png)
*Figure 4 — L'invite passe de `R1#` à `routeur01#`*

### 3.2 Configuration de l'interface côté LAN

Avant de configurer une interface, je liste celles du routeur pour savoir lesquelles sont disponibles et dans quel état elles sont :

```cisco
show ip interface brief
```

![Figure 5](https://hackmd.io/_uploads/Byhqu8K9ze.png)
*Figure 5 — Toutes les interfaces sont sans adresse IP et désactivées*

Je choisis l'interface **GigabitEthernet1/0** pour la relier au switch du réseau local. Je lui donne l'adresse 192.168.33.4 avec un masque /24 :

```cisco
conf t
interface giga1/0
ip address 192.168.33.4 255.255.255.0
no shutdown
exit
```

- `interface giga1/0` : je sélectionne l'interface à configurer ;
- `ip address` : je lui donne son adresse et son masque ;
- `no shutdown` : j'active l'interface, sinon elle reste désactivée malgré l'adresse IP ;
- `exit` : je reviens en configuration globale.

![Figure 6](https://hackmd.io/_uploads/Hypq_LKqzg.png)
*Figure 6 — Configuration de Gi1/0 : l'interface et son protocole passent à « up »*

Je vérifie que la configuration a bien été prise :

```cisco
show ip interface brief
```

![Figure 7](https://hackmd.io/_uploads/rJAqOUtcGe.png)
*Figure 7 — GigabitEthernet1/0 a l'adresse 192.168.33.4, en état up/up*

### 3.3 Câblage du premier réseau

Je relie le port g1/0 du routeur à Switch1, puis les trois postes au switch. Je fais attention à brancher chaque câble sur le bon port : le routeur doit être sur g1/0, puisque c'est la seule interface configurée.

![Figure 8](https://hackmd.io/_uploads/SkJodUKqfg.png)
*Figure 8 — PC1, PC2 et PC3 reliés à Switch1, lui-même relié à R1*

---

## 4. Mise en place du DHCP sur le routeur 1

Plutôt que de configurer l'adresse IP de chaque poste à la main, je fais du routeur un serveur DHCP : les postes reçoivent automatiquement une adresse, un masque, une passerelle et un DNS. Ça évite les erreurs de saisie et les doublons d'adresses.

```cisco
conf t
ip dhcp excluded-address 192.168.33.4
ip dhcp pool LAN
network 192.168.33.0 255.255.255.0
default-router 192.168.33.4
dns-server 8.8.8.8
exit
end
wr
```

- `ip dhcp excluded-address 192.168.33.4` : j'exclus l'adresse du routeur pour qu'elle ne soit jamais distribuée à un poste, ce qui créerait un conflit d'adresses.
- `ip dhcp pool LAN` : je crée un *pool* DHCP, c'est-à-dire une fiche qui regroupe tout ce que le routeur va distribuer aux clients.
- `network 192.168.33.0 255.255.255.0` : j'indique la plage à distribuer. J'écris l'adresse du **réseau** (qui finit par .0), pas celle d'une machine.
- `default-router 192.168.33.4` : la passerelle par défaut donnée aux postes, c'est-à-dire le routeur. Sans elle, un poste ne peut pas sortir de son réseau.
- `dns-server 8.8.8.8` : le serveur DNS donné aux postes (ici celui de Google).
- `wr` (raccourci de `write memory`) : j'enregistre la configuration pour qu'elle survive à un redémarrage.

Sur la capture, on voit que je fais quelques fautes de frappe (`ip pool`, `default-routeur`, `dns-serveur`) : l'IOS répond `% Invalid input detected` avec un `^` sous l'erreur. Je retape la bonne commande juste en dessous, et elle passe.

![Figure 9](https://hackmd.io/_uploads/rkxod8K9fe.png)
*Figure 9 — Création du pool DHCP « LAN » puis enregistrement avec `wr`*

---

## 5. Tests et dépannage

### 5.1 Premier test : échec

Pour tester, je donne d'abord une adresse fixe à PC1 :

```cisco
ip 192.168.33.2
```

![Figure 10](https://hackmd.io/_uploads/BJWsO8t9Gx.png)
*Figure 10 — PC1 configuré en 192.168.33.2/24*

Puis j'essaie de joindre le routeur :

```cisco
ping 192.168.33.4
```

![Figure 11](https://hackmd.io/_uploads/BJGsuLt9fx.png)
*Figure 11 — Le ping vers le routeur échoue : « host not reachable »*

Le ping ne passe pas, il faut trouver pourquoi. J'affiche la configuration IP de PC1 :

```cisco
show ip
```

![Figure 12](https://hackmd.io/_uploads/BkmiO8tcGx.png)
*Figure 12 — PC1 n'a pas de passerelle (GATEWAY 0.0.0.0)*

On voit que PC1 n'a pas de passerelle.

> ⚠️ **Correction :** l'absence de passerelle n'explique pas cet échec. PC1 (192.168.33.2) et le routeur (192.168.33.4) sont dans le **même réseau** : pour se joindre, ils n'ont pas besoin de passerelle. La passerelle ne sert que pour joindre une machine d'un **autre** réseau. La cause est ailleurs (voir la suite).

J'essaie alors d'obtenir une adresse en DHCP :

```cisco
ip dhcp
```

![Figure 13](https://hackmd.io/_uploads/B1VsO8tcMx.png)
*Figure 13 — « Can't find dhcp server » : le DHCP ne répond pas non plus*

Le DHCP ne fonctionne pas non plus. Comme ni le ping ni le DHCP ne passent, le problème est plus bas : la communication entre le poste et le routeur elle-même.

### 5.2 Vérifications méthodiques

Je vérifie les points dans l'ordre, du routeur vers le câblage.

**L'interface du routeur :**

```cisco
show ip int brief
```

![Figure 14](https://hackmd.io/_uploads/r1rou8Kcfx.png)
*Figure 14 — Gi1/0 est toujours en 192.168.33.4, up/up : la configuration du routeur est bonne*

**Le câblage :** je contrôle dans GNS3 que chaque câble est sur le bon port.

![Figure 15](https://hackmd.io/_uploads/rkIj_ItcGl.png)
*Figure 15 — Câblage avec les ports affichés : PC sur e0, Switch1 relié à R1 sur g1/0*

Le câblage est correct. **Le trafic reçu par l'interface :** je regarde si le routeur reçoit quelque chose sur g1/0.

```cisco
show interfaces gi1/0
```

![Figure 16](https://hackmd.io/_uploads/HkPsd8F9Gx.png)
*Figure 16 — Détail de Gi1/0 : seulement 2 paquets reçus (2 broadcasts), aucune erreur*

L'interface est up et sans erreur, mais ne reçoit presque rien : les pings de PC1 n'arrivent pas jusqu'au routeur. Toute la configuration étant correcte, le problème vient probablement de GNS3 lui-même, qui peut parfois bloquer une liaison après des modifications à chaud.

### 5.3 Résolution

Je décide donc de tout arrêter, déconnecter, reconnecter et redémarrer (*reload*). En relisant ma configuration, je vois aussi que mon DHCP est mal fait, alors je le désactive complètement avant le redémarrage pour repartir sur une base propre :

```cisco
conf t
no service dhcp
end
wr
```

Après le redémarrage, le ping passe.

![Figure 17](https://hackmd.io/_uploads/ryujdUY9Mg.png)
*Figure 17 — PC1 joint enfin le routeur 192.168.33.4 (5 réponses sur 5)*

> ⚠️ **Correction :** c'est le redémarrage de GNS3 qui a réglé le ping. La commande `no service dhcp` coupe seulement le service DHCP ; elle n'a aucun effet sur un ping.

---

## 6. Reconfiguration propre du DHCP

Je réactive le service DHCP et je recrée un pool propre, nommé `client-windows` :

```cisco
service dhcp
ip dhcp pool client-windows
network 192.168.33.0 255.255.255.0
domain-name mondomaine.fr
dns-server 192.168.3.4
lease 0 8
exit
```

- `service dhcp` : je réactive le service désactivé à l'étape précédente ;
- `domain-name mondomaine.fr` : le nom de domaine transmis aux postes ;
- `lease 0 8` : la durée du bail, 0 jour et 8 heures. Au bout de ce temps, le poste doit renouveler son adresse, ce qui libère les adresses des postes qui ne sont plus là.

Je vérifie ensuite les adresses distribuées avec :

```cisco
show ip dhcp binding
```

![Figure 18](https://hackmd.io/_uploads/SJKs_LY9fg.png)
*Figure 18 — Nouveau pool « client-windows » ; une adresse (192.168.33.1) est déjà attribuée automatiquement*

> ⚠️ **Correction — la passerelle a été oubliée :** ce nouveau pool n'a **pas** de ligne `default-router`. Les postes reçoivent une adresse mais pas de passerelle (on le voit figure 19 : `GATEWAY 0.0.0.0`). Ils peuvent parler à leur propre réseau, mais pas au réseau de l'autre routeur. Il faut ajouter :
>
> ```cisco
> conf t
> ip dhcp pool client-windows
> default-router 192.168.33.4
> end
> wr
> ```
>
> Autre point à vérifier : le DNS `192.168.3.4` ne correspond à aucun équipement du projet. C'est sans doute une faute de frappe pour `192.168.33.4`, ou il faut remettre `8.8.8.8` comme dans le premier pool.

Je teste le DHCP depuis PC2 :

```cisco
ip dhcp
```

![Figure 19](https://hackmd.io/_uploads/HyqsuLt5ze.png)
*Figure 19 — PC2 obtient 192.168.33.2/24, le DNS, le domaine mondomaine.fr et un bail de 8 h (28 800 s)*

La séquence `DDORA` montre l'échange DHCP complet : **D**iscover (le poste cherche un serveur), **O**ffer (le routeur propose une adresse), **R**equest (le poste la demande), **A**ck (le routeur confirme).

Je teste ensuite la communication dans le réseau. PC1 joint PC2 :

![Figure 20](https://hackmd.io/_uploads/HkosdUFqMg.png)
*Figure 20 — Ping de PC1 vers PC2 (192.168.33.2) : 5 réponses sur 5*

Et PC1 joint le routeur :

![Figure 21](https://hackmd.io/_uploads/HJ2id8Y9Gg.png)
*Figure 21 — Ping de PC1 vers le routeur (192.168.33.4) : 5 réponses sur 5*

Le premier réseau est fonctionnel.

---

## 7. Configuration du routeur 2

Je refais exactement les mêmes étapes sur le deuxième routeur : nom `routeur02`, interface Gi1/0, DHCP, câblage de Switch2 et des postes PC4 à PC6. Seuls les noms et les adresses changent : le réseau du routeur 2 est le **192.168.32.0/24**, avec le routeur en 192.168.32.1. Je ne redétaille pas ces étapes, les commandes étant identiques à celles des sections 3 à 6.

---

## 8. Interconnexion des deux routeurs

### 8.1 Réseau de liaison

Pour relier les deux routeurs, j'utilise une deuxième interface sur chacun : **GigabitEthernet2/0**. Les deux extrémités d'un même câble doivent être dans le **même réseau**, sinon les routeurs ne peuvent pas se parler. Je crée donc un petit réseau dédié à la liaison, le 192.168.22.0/24 :

- routeur02 : 192.168.22.1
- routeur01 : 192.168.22.3

Sur routeur02 :

```cisco
conf t
interface giga2/0
ip address 192.168.22.1 255.255.255.0
no shutdown
exit
```

![Figure 22](https://hackmd.io/_uploads/BkTs_UKqGe.png)
*Figure 22 — Configuration de Gi2/0 sur routeur02 en 192.168.22.1*

![Figure 23](https://hackmd.io/_uploads/SyCs_LFqGx.png)
*Figure 23 — routeur02 : Gi1/0 en 192.168.32.1 et Gi2/0 en 192.168.22.1, toutes les deux up*

Même chose sur routeur01, avec l'adresse 192.168.22.3 :

```cisco
conf t
interface giga2/0
ip address 192.168.22.3 255.255.255.0
no shutdown
exit
```

![Figure 24](https://hackmd.io/_uploads/Skk2dIK5ze.png)
*Figure 24 — routeur01 : Gi2/0 en 192.168.22.3, up/up*

Je relie ensuite les deux routeurs par leur port g2/0.

![Figure 25](https://hackmd.io/_uploads/B1-3dUt9Me.png)
*Figure 25 — Topologie complète : R1 et R2 reliés par g2/0, chaque routeur relié à son switch par g1/0*

### 8.2 Routage statique

Un routeur connaît automatiquement les réseaux branchés directement sur ses interfaces, mais pas ceux qui sont derrière un autre routeur. Il faut donc lui indiquer le chemin avec une **route statique** : « pour aller vers tel réseau, envoie les paquets à tel routeur voisin ».

La syntaxe est :

```cisco
ip route <réseau de destination> <masque> <adresse du routeur voisin>
```

Sur routeur01, j'ai entré :

```cisco
ip route 192.168.22.0 255.255.255.0 192.168.22.1
```

![Figure 26](https://hackmd.io/_uploads/rkbn_LFqze.png)
*Figure 26 — Route statique entrée sur routeur01, puis `write memory`*

Et sur routeur02 (après une faute de frappe `ip root` corrigée juste en dessous) :

```cisco
ip route 192.168.22.0 255.255.255.0 192.168.22.3
```

![Figure 27](https://hackmd.io/_uploads/B1zndItczg.png)
*Figure 27 — Route statique entrée sur routeur02, puis `write memory`*

> ⚠️ **Correction — les routes pointent vers le mauvais réseau :** ces deux routes visent le 192.168.22.0, c'est-à-dire le réseau de liaison. Or ce réseau est **déjà directement connecté** aux deux routeurs : la route ne sert à rien. Ce qu'il faut, c'est indiquer à chaque routeur le **LAN de l'autre** :
>
> Sur routeur01 (pour joindre le LAN 2) :
> ```cisco
> conf t
> ip route 192.168.32.0 255.255.255.0 192.168.22.1
> end
> wr
> ```
>
> Sur routeur02 (pour joindre le LAN 1) :
> ```cisco
> conf t
> ip route 192.168.33.0 255.255.255.0 192.168.22.3
> end
> wr
> ```
>
> Et supprimer les anciennes routes inutiles en ajoutant `no` devant (`no ip route 192.168.22.0 255.255.255.0 192.168.22.1` sur routeur01, idem avec `.3` sur routeur02).

### 8.3 Test entre les routeurs

Je teste la liaison depuis routeur01 :

```cisco
ping 192.168.22.1
```

![Figure 28](https://hackmd.io/_uploads/Hy73OUY9zx.png)
*Figure 28 — routeur01 joint routeur02 (192.168.22.1) : 100 % de réussite (5/5)*

La liaison entre les deux routeurs fonctionne.

![Figure 29](https://hackmd.io/_uploads/SyVhdLKqMe.png)
*Figure 29 — Infrastructure finale : deux LAN de trois postes reliés par deux routeurs*

> ⚠️ **Correction — le test ne prouve pas encore que tout communique :** ce ping part d'un routeur vers l'autre, sur le réseau de liaison qui leur est directement connecté. Il valide le câble et l'adressage de la liaison, mais pas le routage entre les deux LAN. Pour prouver que « toutes les machines se pingent », il faut, **après** avoir corrigé les routes et ajouté la passerelle dans le DHCP, faire un ping d'un PC du LAN 1 vers un PC du LAN 2 (par exemple de PC1 vers PC4) et en faire une capture.

---

## 9. Récapitulatif

| Élément | Configuration retenue |
|---|---|
| routeur01 — Gi1/0 (LAN 1) | 192.168.33.4 /24 |
| routeur01 — Gi2/0 (liaison) | 192.168.22.3 /24 |
| routeur02 — Gi1/0 (LAN 2) | 192.168.32.1 /24 |
| routeur02 — Gi2/0 (liaison) | 192.168.22.1 /24 |
| DHCP routeur01 | pool `client-windows`, réseau 192.168.33.0/24, domaine mondomaine.fr, bail 8 h |
| Adresse exclue du DHCP | 192.168.33.4 (le routeur) |
| Postes LAN 1 | PC1, PC2, PC3 — adresses en DHCP |
| Postes LAN 2 | PC4, PC5, PC6 |
| Routage | statique (à corriger, voir section 8.2) |

Commandes Cisco utilisées :

| Commande | Rôle |
|---|---|
| `conf t` | entrer en mode configuration |
| `hostname` | nommer le routeur |
| `show ip interface brief` | résumé des interfaces, de leur IP et de leur état |
| `show interfaces gi1/0` | détail d'une interface (trafic, erreurs) |
| `interface` / `ip address` / `no shutdown` | configurer et activer une interface |
| `ip dhcp pool` / `network` / `default-router` / `dns-server` / `lease` | configurer le DHCP |
| `ip dhcp excluded-address` | réserver une adresse hors DHCP |
| `show ip dhcp binding` | voir les adresses distribuées |
| `ip route` | ajouter une route statique |
| `wr` | enregistrer la configuration |

---

## 10. Conclusion

J'ai monté sous GNS3 une infrastructure de deux réseaux locaux reliés par deux routeurs Cisco. Chaque routeur a son interface LAN configurée et distribue les adresses de son réseau en DHCP, et la liaison entre les deux routeurs fonctionne.

Ce projet m'a surtout appris à **dépanner avec méthode** : quand le ping et le DHCP ne marchaient pas, j'ai vérifié les couches une par une (configuration de l'interface, câblage, trafic reçu) avant de conclure à un problème du simulateur. J'ai aussi compris l'intérêt des commandes de vérification (`show ip interface brief`, `show ip dhcp binding`) après chaque changement, et comment lire les messages d'erreur de l'IOS pour corriger une faute de frappe.

Améliorations avant une mise en production réelle :

- corriger les routes statiques pour qu'elles pointent vers les LAN distants (section 8.2) et valider par un ping PC1 → PC4 ;
- ajouter `default-router` dans le pool DHCP et vérifier l'adresse du serveur DNS ;
- vérifier avec `show running-config` qu'il ne reste qu'un seul pool DHCP par réseau ;
- protéger l'accès aux routeurs par un mot de passe (`enable secret`) et sécuriser l'accès console ;
- ajouter une description sur chaque interface (`description`) pour faciliter la maintenance ;
- sur un réseau plus grand, utiliser un protocole de routage dynamique (OSPF par exemple) plutôt que des routes statiques à maintenir à la main.
