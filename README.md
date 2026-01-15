# CyberGhost VPN Manager (OpenVPN) — script perso

Petit gestionnaire interactif pour se connecter rapidement à CyberGhost VPN via OpenVPN, avec une configuration orientée simplicité (installation en une commande, utilisation via un menu).
Je l'ai créé, à l’origine, pour remplacer l'appli CLI Linux officiel du site CyberGhost, qui pour moi est tout le temps bugé. Codé pour mon usage personnel sur `Pop!_OS`un derivé de `Ubuntu`, et je le partage tel quel pour dépanner. 
Premier partage : retours bienvenus, mais le périmètre reste volontairement simple.

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

Avant la première connexion, il faut télécharger une configuration OpenVPN depuis l’espace client CyberGhost :
- Download Hub → “Routeurs ou autres appareils” → `créer/télécharger` la configuration `OpenVPN`
- Extraire le `.zip` : on obtient un fichier `.ovpn` + `ca.crt` + `client.crt` + `client.key`

Le script sait ensuite détecter ces fichiers (ex: dans `~/Téléchargements/`) et les copier dans `~/vpn/`.

## Installation

Télécharger le fichier `install-cyberghost.sh`
Ouvrir le terminal dans les téléchargements puis :
`bash install-cyberghost.sh`

Cloner le dépôt :
`git clone https://github.com/DThrawn/Cyberghost-manager-linux.git` 
- Aller dans le dossier :
`cd Cyberghost-manager-linux | bash install-cyberghost.sh`

 ou
 
`curl -L https://raw.githubusercontent.com/DThrawn/Cyberghost-manager-linux/main/install-cyberghost.sh | bash`

Le script crée :
- `~/vpn`
- `~/vpn/cyberghost-vpn-manager.sh`
- `~/vpn/countries.conf`

## Utilisation

Ouvrir un nouveau terminal (si vous avez choisi d’installer les alias), puis :

- Lancer le menu :
  `vpn`

- Afficher l’IP publique :
  `monip`


- Couper la connexion OpenVPN (arrêt du processus) :
  `vpnoff`


- Sans alias, lancer directement :
  `bash ~/vpn/cyberghost-vpn-manager.sh`


## Notes importantes

- Ce script n’est pas officiel et n’est pas affilié à CyberGhost.
- Les identifiants OpenVPN CyberGhost sont demandés au premier lancement et sauvegardés localement dans `~/vpn/auth.txt` (droits restreints).

## Licence

À définir si besoin (sinon, considérer “tous droits réservés”).
