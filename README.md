**Alternative fonctionnelle au CLI CyberGhost officiel défectueux sous Linux.**

Menu interactif terminal pour gérer facilement vos connexions VPN CyberGhost avec protection DNS anti-fuite intégrée. Accédez à 100 pays en quelques secondes sans configuration manuelle.

---

## Table des matières

- [Le problème](#le-problème)
- [La solution](#la-solution)
- [Fonctionnalités](#fonctionnalités)
- [Captures d'écran](#captures-décran)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Configuration avancée](#configuration-avancée)
- [Dépannage](#dépannage)
- [Contribution](#contribution)
- [Licence](#licence)
- [Auteur](#auteur)

---

## Le problème

Le CLI officiel CyberGhost pour Linux (`cyberghostvpn-cli`) est **notoirement défaillant** :
- Connexions qui échouent aléatoirement
- Fuites DNS non gérées
- Interface peu intuitive
- Bugs non corrigés depuis des années
- Support technique inexistant

## La solution

Ce script remplace **complètement** le CLI officiel et offre :
- Connexion fiable à 100% via OpenVPN natif
- Protection DNS anti-fuite automatique (`openvpn-systemd-resolved`)
- Menu interactif par pays et continents
- Installation guidée étape par étape
- Raccourcis terminal pratiques
- Connexion en moins de 10 secondes

---

## Fonctionnalités

### Interface utilisateur
- **Menu interactif** organisé par continents (Europe, Asie, Amérique, Afrique, Océanie)
- **100 pays disponibles** avec codes serveurs à jour
- **Vérification d'IP** intégrée après connexion
- **Navigation intuitive** par numéros

### Sécurité
- **Protection DNS garantie** via `openvpn-systemd-resolved`
- **Kill switch** automatique lors du changement de serveur
- **Credentials chiffrés** dans `~/vpn/auth.txt` (chmod 600)
- **Détection de fuites** avec vérification IP/pays

### Installation
- **Assistant d'installation** pas à pas
- **Détection automatique** des fichiers CyberGhost
- **Configuration zéro** : tout est automatisé
- **Guide intégré** pour créer votre routeur OpenVPN

### Raccourcis
Trois alias pratiques ajoutés à votre `.bashrc` :
```bash
vpn       # Lance le menu VPN
monip     # Affiche votre IP publique actuelle
vpnoff    # Déconnecte le VPN instantanément


╔════════════════════════════════════════════════════════════╗
║     CYBERGHOST VPN MANAGER - 100 PAYS                      ║
╚════════════════════════════════════════════════════════════╝

=== Europe ===
  1) Allemagne                    2) Albanie
  3) Andorre                      4) Autriche
  [...]

=== Asie ===
  75) Arménie                     76) Bangladesh
  [...]

  0) Deconnecter VPN et quitter
════════════════════════════════════════════════════════════
Choisissez un pays (0-100) : _
