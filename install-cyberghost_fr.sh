#!/bin/bash
# ════════════════════════════════════════════════════════════
# Script: CyberGhost VPN Manager - Installateur Automatique
# Auteur: DThrawn
# Date: 14/01/2026
# Version: 2.0
# ════════════════════════════════════════════════════════════
#
# Installation complete avec protection DNS anti-fuite
# Gestionnaire interactif pour 100 pays
#
# UTILISATION:
#   bash install-cyberghost.sh
#
# ════════════════════════════════════════════════════════════
set -e


VPN_DIR="$HOME/vpn"

print_header() {
    echo "╔════════════════════════════════════════════════════════════╗"
    printf "║   %-56s ║\n" "$1"
    echo "╚════════════════════════════════════════════════════════════╝"
}

# Ecran de bienvenue
clear
print_header "INSTALLATION CYBERGHOST VPN MANAGER"
cat << 'EOF'

Ce script va installer :
  - OpenVPN + protection DNS anti-fuite
  - Un gestionnaire interactif pour 100 pays
  - Des raccourcis clavier (vpn, monip, vpnoff)

PREREQUIS :
  Vous devez avoir telecharge vos fichiers CyberGhost depuis :
  https://my.cyberghostvpn.com/fr/download-hub/vpn
  (Si ce n'est pas fait, le script vous guidera)

EOF
read -p "Appuyez sur Entree pour continuer..."

# 1. Installation des dependances
clear
print_header "ETAPE 1/5 : INSTALLATION DES DEPENDANCES"
cat << 'EOF'

Installation de : openvpn, curl, openvpn-systemd-resolved

EOF
sudo apt update -qq
sudo apt install -y openvpn curl openvpn-systemd-resolved
echo ""
echo "Installation terminee avec succes !"
sleep 2

# 2. Creation du dossier VPN
clear
print_header "ETAPE 2/5 : CREATION DU DOSSIER ~/vpn"
echo ""
mkdir -p "$VPN_DIR"
echo "Dossier ~/vpn cree"
sleep 1

# 3. Creation du script principal
clear
print_header "ETAPE 3/5 : CREATION DU GESTIONNAIRE VPN"
echo ""
cat > "$VPN_DIR/cyberghost-vpn-manager.sh" << 'MAINSCRIPT'
#!/bin/bash
################################################################################
#
#  CYBERGHOST VPN MANAGER - GESTIONNAIRE INTERACTIF
#
#  Connexion simplifiee a 100 pays via CyberGhost
#  Protection DNS anti-fuite integree
#
################################################################################

VPN_DIR="$HOME/vpn"
OVPN_FILE="$VPN_DIR/openvpn.ovpn"
AUTH_FILE="$VPN_DIR/auth.txt"
COUNTRIES_FILE="$VPN_DIR/countries.conf"

print_header() {
    echo "╔════════════════════════════════════════════════════════════╗"
    printf "║   %-56s ║\n" "$1"
    echo "╚════════════════════════════════════════════════════════════╝"
}

check_dependencies() {
    local packages_missing=()

    command -v openvpn &> /dev/null || packages_missing+=("openvpn")
    command -v curl &> /dev/null || packages_missing+=("curl")
    dpkg -l | grep -q "openvpn-systemd-resolved" || packages_missing+=("openvpn-systemd-resolved")

    [ ${#packages_missing[@]} -eq 0 ] && return 0

    clear
    print_header "INSTALLATION DES DEPENDANCES NECESSAIRES"
    cat << EOF

Packages manquants:
$(printf '   - %s\n' "${packages_missing[@]}")

EOF
    read -p "Installer maintenant ? (o/n) : " install_choice

    if [[ "$install_choice" =~ ^[oOyY]$ ]]; then
        echo "Installation en cours..."
        sudo apt update && sudo apt install -y "${packages_missing[@]}"
        echo "Installation terminee !"
        sleep 2
    else
        echo "Installation annulee."
        exit 1
    fi
}

first_time_setup() {
    local flag="$VPN_DIR/.installed"
    [ -f "$flag" ] && return 0

    clear
    print_header "CONFIGURATION DES RACCOURCIS"
    cat << 'EOF'

Voulez-vous installer les raccourcis suivants ?

  vpn      - Ouvre le menu VPN
  monip    - Affiche votre IP actuelle
  vpnoff   - Deconnecte le VPN rapidement

EOF
    read -p "Installer les raccourcis ? (o/n) : " alias_choice
    
    if [[ "$alias_choice" =~ ^[oOyY]$ ]] && ! grep -q "alias vpn=" ~/.bashrc; then
        cat >> ~/.bashrc << 'ALIASES'

# Alias VPN CyberGhost
alias vpn='bash ~/vpn/cyberghost-vpn-manager.sh'
alias monip='curl -s ifconfig.me && echo'
alias vpnoff='sudo killall openvpn && echo "VPN deconnecte"'
ALIASES
        cat << 'EOF'

RACCOURCIS INSTALLES !

A partir du PROCHAIN terminal, tapez simplement :

  vpn        - Pour vous connecter
  monip      - Pour voir votre IP
  vpnoff     - Pour deconnecter

Dans CE terminal actuel, tapez : source ~/.bashrc

EOF
        read -p "Appuyez sur Entree pour continuer..."
    fi
    
    touch "$flag"
}

check_and_setup_files() {
    local files_needed=("openvpn.ovpn" "ca.crt" "client.crt" "client.key")
    local files_missing=()
    
    for file in "${files_needed[@]}"; do
        [ ! -f "$VPN_DIR/$file" ] && files_missing+=("$file")
    done
    
    [ ${#files_missing[@]} -eq 0 ] && return 0

    clear
    print_header "FICHIERS CYBERGHOST MANQUANTS"
    cat << EOF

Fichiers introuvables :
$(printf '   - %s\n' "${files_missing[@]}")

EOF
    
    read -p "Avez-vous deja cree un routeur OpenVPN sur CyberGhost ? (o/n) : " router_existe
    
    if [[ ! "$router_existe" =~ ^[oOyY]$ ]]; then
        clear
        cat << 'EOF'
════════════════════════════════════════════════════════════
 GUIDE COMPLET - CREATION DU ROUTEUR CYBERGHOST
════════════════════════════════════════════════════════════

ETAPE 1 : Creer votre routeur OpenVPN
─────────────────────────────────────
1. Allez sur :
https://my.cyberghostvpn.com/fr/download-hub/vpn

2. Cliquez sur : "Routeurs ou autres appareils"

3. Cliquez sur : "Creer une nouvelle configuration"

4. Remplissez le formulaire :
   - PROTOCOLE : Selectionnez "OpenVPN"
   - PAYS : Choisissez n'importe lequel (ex: France)
   - GROUPE DE SERVEURS : Selectionnez un groupe
   - NOM : Tapez "Linux" (ou autre nom)

5. Cliquez sur : "Telecharger la configuration"
   - Un fichier .zip sera telecharge

ETAPE 2 : Preparer les fichiers
────────────────────────────────
6. Allez dans ~/Telechargements/

7. Faites clic droit sur le fichier .zip
   - "Extraire ici"

- Un dossier *_openvpn/ apparait avec 4 fichiers :
   + xxxxx.ovpn
   + ca.crt
   + client.crt
   + client.key

Le script va maintenant les detecter automatiquement !

EOF
        read -p "Appuyez sur Entree quand vous avez termine..."
    else
        cat << 'EOF'

Assurez-vous d'avoir dezippe les fichiers dans :
  ~/Telechargements/ ou ~/Telechargements/*_openvpn/

EOF
        read -p "Appuyez sur Entree pour lancer la recherche automatique..."
    fi

    clear
    echo "Recherche automatique des fichiers..."
    echo ""
    local search_base="$HOME/Telechargements"
    local search_dirs=("$search_base")
    
    for dir in "$search_base"/*_openvpn; do
        [ -d "$dir" ] && search_dirs+=("$dir")
    done

    local found_files=0
    for file in "${files_missing[@]}"; do
        for search_dir in "${search_dirs[@]}"; do
            local found_file
            [ "$file" = "openvpn.ovpn" ] && found_file=$(find "$search_dir" -maxdepth 1 -name "*.ovpn" 2>/dev/null | head -1) || found_file=$(find "$search_dir" -maxdepth 1 -name "$file" 2>/dev/null | head -1)

            if [ -n "$found_file" ] && [ -f "$found_file" ]; then
                [ "$file" = "openvpn.ovpn" ] && cp "$found_file" "$VPN_DIR/openvpn.ovpn" || cp "$found_file" "$VPN_DIR/"
                echo "$file trouve et copie"
                ((found_files++))
                break
            fi
        done
    done

    echo ""
    if [ $found_files -lt ${#files_missing[@]} ]; then
        echo "Fichiers manquants. Copiez-les manuellement dans ~/vpn/"
        echo "puis relancez le script."
        exit 1
    fi
    
    echo "Tous les fichiers sont prets !"
    sleep 2
}

setup_credentials() {
    [ -f "$AUTH_FILE" ] && [ -s "$AUTH_FILE" ] && return 0

    clear
    print_header "CONFIGURATION DES IDENTIFIANTS"
    cat << 'EOF'

Pour obtenir vos identifiants, allez sur :
https://my.cyberghostvpn.com/fr/settings/manage-devices

EOF
    
    read -p "Username CyberGhost: " username
    read -sp "Password: " password
    echo ""
    
    printf '%s\n%s\n' "$username" "$password" > "$AUTH_FILE"
    chmod 600 "$AUTH_FILE"
    
    echo ""
    echo "Identifiants sauvegardes"
    sleep 1
}
connect_to_country() {
    local country_code=$1
    local country_name=$2

    sudo killall openvpn 2>/dev/null
    sleep 1

    sudo sed -i "s/^remote .*/remote 87-1-${country_code}.cg-dialup.net 443/" "$OVPN_FILE"

    echo "Connexion a $country_name..."

    grep -q "auth-user-pass.*auth.txt" "$OVPN_FILE" || \
        sudo sed -i "s|auth-user-pass.*|auth-user-pass $AUTH_FILE|" "$OVPN_FILE"

    sudo sed -i '/# Protection DNS/d; /script-security/d; /update-systemd-resolved/d; /down-pre/d; /dhcp-option DOMAIN-ROUTE/d' "$OVPN_FILE"

    cat >> "$OVPN_FILE" << 'EOL'

# Protection DNS - Empeche les fuites
script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .
EOL

    cd "$VPN_DIR" && sudo openvpn --config "$OVPN_FILE" --daemon
    
    # Attendre que l'interface tun0 soit active
    echo "Etablissement du tunnel VPN..."
    local count=0
    while [ $count -lt 15 ]; do
        if ip link show tun0 &>/dev/null; then
            break
        fi
        sleep 1
        ((count++))
    done
    
    # Attendre encore que le routage soit etabli (important !)
    sleep 5

    clear
    echo "VPN $country_name connecte !"
    echo "Protection DNS activee"
}

check_vpn() {
    echo ""
    echo "Verification de la connexion..."
    
    local current_ip
    current_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    
    if [ -z "$current_ip" ]; then
        echo "Impossible de recuperer l'IP"
    else
        echo "IP actuelle : $current_ip"
        
        local country
        country=$(curl -s --max-time 5 "https://ipapi.co/${current_ip}/country_name/" 2>/dev/null)
        
        [ -n "$country" ] && echo "Pays detecte : $country"
    fi
    
    echo ""
}

load_countries() {
    [ ! -f "$COUNTRIES_FILE" ] && { echo "countries.conf manquant !"; exit 1; }
    
    declare -gA COUNTRY_CODE COUNTRY_NAME COUNTRY_CONTINENT
    
    while IFS='|' read -r num code name continent; do
        [[ "$num" =~ ^#.*$ ]] || [ -z "$num" ] && continue
        
        COUNTRY_CODE[$num]="$code"
        COUNTRY_NAME[$num]="$name"
        COUNTRY_CONTINENT[$num]="$continent"
    done < "$COUNTRIES_FILE"
}

show_menu() {
    clear
    local total_countries=$(grep -c '^[0-9]' "$COUNTRIES_FILE" 2>/dev/null || echo "100")
    
    echo "╔════════════════════════════════════════════════════════════╗"
    printf "║     CYBERGHOST VPN MANAGER - %-2d PAYS                     ║\n" "$total_countries"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    local current_continent=""
    local max_num
    max_num=$(printf '%s\n' "${!COUNTRY_CODE[@]}" | sort -n | tail -1)
    local line_counter=0
    
    for i in $(seq 1 "$max_num"); do
        [ -z "${COUNTRY_CODE[$i]}" ] && continue
        
        if [ "$current_continent" != "${COUNTRY_CONTINENT[$i]}" ]; then
            current_continent="${COUNTRY_CONTINENT[$i]}"
            [ $line_counter -ne 0 ] && echo ""
            echo ""
            echo "=== $current_continent ==="
            line_counter=0
        fi
        
        printf "  %3d) %-28s" "$i" "${COUNTRY_NAME[$i]}"
        ((line_counter++))
        
        if [ $((line_counter % 2)) -eq 0 ]; then
            echo ""
            line_counter=0
        else
            echo -n "   "
        fi
    done
    
    echo ""
    echo ""
    echo "   0) Deconnecter VPN et quitter"
    echo ""
    echo "════════════════════════════════════════════════════════════"
}

main_loop() {
    load_countries
    
    while true; do
        show_menu
        read -p "Choisissez un pays (0-100) : " choice
        
        [ "$choice" = "0" ] && { sudo killall openvpn 2>/dev/null; echo ""; echo "VPN deconnecte ! Au revoir."; exit 0; }
        
        if [ -n "${COUNTRY_CODE[$choice]}" ]; then
            connect_to_country "${COUNTRY_CODE[$choice]}" "${COUNTRY_NAME[$choice]}"
            check_vpn
            
            echo "════════════════════════════════════════════════════════════"
            echo "  1) Changer de localisation"
            echo "  2) Deconnecter VPN et quitter"
            echo "════════════════════════════════════════════════════════════"
            read -p "Votre choix : " next_action
            
            case $next_action in
                1) continue ;;
                2) sudo killall openvpn 2>/dev/null; echo "Au revoir."; exit 0 ;;
                *) continue ;;
            esac
        else
            echo "Choix invalide !"
            sleep 2
        fi
    done
}

check_dependencies
first_time_setup
check_and_setup_files
setup_credentials
main_loop
MAINSCRIPT

chmod +x "$VPN_DIR/cyberghost-vpn-manager.sh"
echo "Gestionnaire VPN cree"
sleep 1

# 4. Creation de la base de donnees des pays
clear
print_header "ETAPE 4/5 : BASE DE DONNEES DES PAYS"
echo ""
cat > "$VPN_DIR/countries.conf" << 'EOF'
# Format: numero|code_pays|nom_pays|continent
# Source officielle: https://www.cyberghostvpn.com/vpn-server
# EUROPE (1-47)
1|de|Allemagne|Europe
2|al|Albanie|Europe
3|ad|Andorre|Europe
4|at|Autriche|Europe
5|by|Bielorussie|Europe
6|be|Belgique|Europe
7|ba|Bosnie-Herzegovine|Europe
8|bg|Bulgarie|Europe
9|hr|Croatie|Europe
10|cy|Chypre|Europe
11|cz|Republique Tcheque|Europe
12|dk|Danemark|Europe
13|ee|Estonie|Europe
14|fi|Finlande|Europe
15|fr|France|Europe
16|ge|Georgie|Europe
17|gr|Grece|Europe
18|gl|Groenland|Europe
19|hu|Hongrie|Europe
20|is|Islande|Europe
21|ie|Irlande|Europe
22|im|Ile de Man|Europe
23|it|Italie|Europe
24|lv|Lettonie|Europe
25|li|Liechtenstein|Europe
26|lt|Lituanie|Europe
27|lu|Luxembourg|Europe
28|mt|Malte|Europe
29|md|Moldavie|Europe
30|mc|Monaco|Europe
31|me|Montenegro|Europe
32|mk|Macedoine du Nord|Europe
33|nl|Pays-Bas|Europe
34|no|Norvege|Europe
35|pl|Pologne|Europe
36|pt|Portugal|Europe
37|ro|Roumanie|Europe
38|ru|Russie|Europe
39|rs|Serbie|Europe
40|sk|Slovaquie|Europe
41|si|Slovenie|Europe
42|es|Espagne|Europe
43|se|Suede|Europe
44|ch|Suisse|Europe
45|tr|Turquie|Europe
46|ua|Ukraine|Europe
47|gb|Royaume-Uni|Europe
# AFRIQUE & MOYEN-ORIENT (48-57)
48|dz|Algerie|Afrique & Moyen-Orient
49|eg|Egypte|Afrique & Moyen-Orient
50|ke|Kenya|Afrique & Moyen-Orient
51|ma|Maroc|Afrique & Moyen-Orient
52|ng|Nigeria|Afrique & Moyen-Orient
53|za|Afrique du Sud|Afrique & Moyen-Orient
54|ae|Emirats Arabes Unis|Afrique & Moyen-Orient
55|il|Israel|Afrique & Moyen-Orient
56|qa|Qatar|Afrique & Moyen-Orient
57|sa|Arabie Saoudite|Afrique & Moyen-Orient
# AMERIQUE (58-74)
58|ar|Argentine|Amerique
59|bs|Bahamas|Amerique
60|bo|Bolivie|Amerique
61|br|Bresil|Amerique
62|ca|Canada|Amerique
63|cl|Chili|Amerique
64|co|Colombie|Amerique
65|cr|Costa Rica|Amerique
66|do|Republique Dominicaine|Amerique
67|ec|Equateur|Amerique
68|gt|Guatemala|Amerique
69|mx|Mexique|Amerique
70|pa|Panama|Amerique
71|pe|Perou|Amerique
72|us|Etats-Unis|Amerique
73|uy|Uruguay|Amerique
74|ve|Venezuela|Amerique
# ASIE (75-98)
75|am|Armenie|Asie
76|bd|Bangladesh|Asie
77|kh|Cambodge|Asie
78|cn|Chine|Asie
79|hk|Hong Kong|Asie
80|in|Inde|Asie
81|id|Indonesie|Asie
82|ir|Iran|Asie
83|jp|Japon|Asie
84|kz|Kazakhstan|Asie
85|kr|Coree du Sud|Asie
86|la|Laos|Asie
87|mo|Macao|Asie
88|my|Malaisie|Asie
89|mn|Mongolie|Asie
90|mm|Myanmar|Asie
91|np|Nepal|Asie
92|pk|Pakistan|Asie
93|ph|Philippines|Asie
94|sg|Singapour|Asie
95|lk|Sri Lanka|Asie
96|tw|Taiwan|Asie
97|th|Thailande|Asie
98|vn|Viet Nam|Asie
# OCEANIE (99-100)
99|au|Australie|Oceanie
100|nz|Nouvelle-Zelande|Oceanie
EOF
echo "Base de donnees creee (100 pays)"
sleep 1

# 5. Finalisation

clear
print_header "INSTALLATION TERMINEE !"
echo ""

if grep -q "alias vpn=" ~/.bashrc; then
    cat << 'EOF'
RACCOURCIS CREES (disponibles apres redemarrage du terminal) :
   - vpn      - Ouvre le menu VPN
   - monip    - Affiche votre IP actuelle
   - vpnoff   - Deconnecte le VPN rapidement

EOF
    # Creer le flag pour eviter de redemander
    touch "$VPN_DIR/.installed"
fi

cat << 'EOF'
Fichiers crees :
   ~/vpn/cyberghost-vpn-manager.sh
   ~/vpn/countries.conf (100 pays)

════════════════════════════════════════════════════════════
Que voulez-vous faire maintenant ?

  1) Lancer le gestionnaire VPN maintenant
  2) Quitter (vous pourrez lancer avec: vpn)

EOF
read -p "Votre choix (1-2) : " final_choice

case $final_choice in
    1)
        echo ""
        echo "Lancement du gestionnaire VPN..."
        sleep 1
        bash "$VPN_DIR/cyberghost-vpn-manager.sh"
        ;;
    2)
        cat << 'EOF'

Installation terminee !

Pour lancer le VPN plus tard, tapez : vpn
(ou: bash ~/vpn/cyberghost-vpn-manager.sh)

EOF
        ;;
    *)
        echo ""
        echo "Pour lancer le VPN, tapez : vpn"
        echo ""
        ;;
esac
