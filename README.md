# CyberGhost VPN Manager (OpenVPN) — script perso

Petit gestionnaire interactif pour se connecter rapidement à CyberGhost via OpenVPN, avec une configuration orientée simplicité (installation en une commande, utilisation via un menu).

Ce projet a été créé à l’origine pour mon usage personnel (Pop!_OS), et je le partage tel quel pour dépanner. 
Premier partage : retours bienvenus, mais le périmètre reste volontairement simple.

## Fonctionnalités

- Installation automatique des dépendances OpenVPN.
- Import assisté des fichiers CyberGhost (.ovpn + certificats).
- Menu interactif par pays (100 entrées).
- Raccourcis optionnels : `vpn`, `monip`, `vpnoff`.
- Protection DNS anti-fuite (via systemd-resolved) si disponible sur la distro.

## Compatibilité

- Testé uniquement sur Pop!_OS.
- Devrait fonctionner sur Ubuntu (et dérivés Debian) tant que `apt` est disponible.

## Prérequis CyberGhost

Avant la première connexion, il faut télécharger une configuration OpenVPN depuis l’espace client CyberGhost :
- Download Hub → “Routeurs ou autres appareils” → créer/télécharger la configuration OpenVPN
- Extraire le .zip : on obtient un fichier `.ovpn` + `ca.crt` + `client.crt` + `client.key`

Le script sait ensuite détecter ces fichiers (ex: dans `~/Téléchargements/`) et les copier dans `~/vpn/`.

## Installation

bash install-cyberghost.sh

Le script crée :
- `~/vpn
- `~/vpn/cyberghost-vpn-manager.sh`
- `~/vpn/countries.conf`

## Utilisation

Ouvrir un nouveau terminal (si vous avez choisi d’installer les alias), puis :

- Lancer le menu :
  vpn

- Afficher l’IP publique :
  monip


- Couper la connexion OpenVPN (arrêt du processus) :
  vpnoff


- Sans alias, lancer directement :
  bash ~/vpn/cyberghost-vpn-manager.sh


## Notes importantes

- Ce script n’est pas officiel et n’est pas affilié à CyberGhost.
- Les identifiants OpenVPN CyberGhost sont demandés au premier lancement et sauvegardés localement dans `~/vpn/auth.txt` (droits restreints).

## Licence

À définir si besoin (sinon, considérer “tous droits réservés”).
