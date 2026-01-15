## CyberGhost VPN Manager (OpenVPN)

Gestionnaire interactif (-13KB), dans le terminal, pour se connecter rapidement à CyberGhost VPN via OpenVPN, avec une configuration orientée simplicité.
Alternative a l'application CyberGhost CLI Linux officielle .

## Fonctionnalités

- Installation automatique des dépendances OpenVPN.
- Import assisté des fichiers CyberGhost (`.ovpn` + certificats).
- Menu interactif par pays (100 entrées).
- Raccourcis optionnels : `vpn`, `monip`, `vpnoff`.
- Protection DNS anti-fuite (via `systemd-resolved`) si disponible sur la distro.

## Compatibilité

- Testé uniquement sur `Pop!_OS`.
- Devrait fonctionner sur `Ubuntu` (et dérivés `Debian`) tant que `apt` est disponible.

## Prérequis CyberGhost

Avant la première connexion, **Le script vous guidera pas à pas lors de l'installation**, il faudra télécharger une configuration OpenVPN depuis l’espace client CyberGhost :
- `Download Hub` → `Routeurs ou autres appareils` → `créer/télécharger` la configuration `OpenVPN`
- Extraire le `.zip` : on obtient un fichier `.ovpn` + `ca.crt` + `client.crt` + `client.key`

Il saura ensuite détecter ces fichiers (dans `~/Téléchargements/`) et les copier dans `~/vpn/`.

## Installation

Télécharger le fichier `install-cyberghost.sh`

Ouvrir le terminal dans les téléchargements

```bash
bash install-cyberghost.sh
```

**ou**

Cloner le dépôt :
```bash
git clone https://github.com/DThrawn/Cyberghost-manager-linux.git && cd Cyberghost-manager-linux && bash install-cyberghost.sh
```


 **ou**
 
 Via Curl
```bash
curl -L https://raw.githubusercontent.com/DThrawn/Cyberghost-manager-linux/main/install-cyberghost.sh | bash
```


**Le script crée :**
- `~/vpn`
- `~/vpn/cyberghost-vpn-manager.sh`
- `~/vpn/countries.conf`
- `~/vpn/auth.txt`

## Utilisation

Ouvrir un nouveau terminal (si vous avez choisi d’installer les alias), puis :

- Lancer le menu :
```bash
vpn
```

- Afficher l’IP publique :
```bash
monip
  ```


- Couper la connexion OpenVPN (arrêt du processus) :
```bash
vpnoff
```


- Sans alias, lancer directement :
```bash
bash ~/vpn/cyberghost-vpn-manager.sh
```


## Notes importantes

- Ce script n’est pas officiel et n’est pas affilié à CyberGhost.
- Les identifiants OpenVPN CyberGhost sont demandés au premier lancement et sauvegardés localement dans `~/vpn/auth.txt` (droits restreints).
- Pas de Kill Switch

## À propos

Ce script a été créé pour remplacer l'application CyberGhost CLI Linux officielle disponible sur le site, qui présente des bugs récurrents dans mon cas d'usage.

Développé initialement pour un usage personnel sur Pop!_OS (dérivé Ubuntu), je le partage tel quel pour dépanner d'autres utilisateurs. 

Premier partage public : vos retours sont bienvenus, restez bienveillant. La configuration reste volontairement simple et la mise en forme est gérée automatiquement par le script d'installation.

## Soutien
Si ce projet vous est utile, vous pouvez m'offrir un café :

<a href='https://ko-fi.com/C1C41SAOT6' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Licence

MIT License - Libre d'utilisation et de modification.
