#!/bin/bash
set -e
VPN_DIR="$HOME/vpn"
print_header() {
    echo "╔════════════════════════════════════════════════════════════╗"
    printf "║   %-56s ║\n" "$1"
    echo "╚════════════════════════════════════════════════════════════╝"
}
clear
print_header "CYBERGHOST VPN MANAGER INSTALLATION"
cat << 'EOF'
This script will install:
  - OpenVPN + DNS leak protection
  - Interactive manager for 100 countries
  - Keyboard shortcuts (vpn, myip, vpnoff)
PREREQUISITES:
  You must download your CyberGhost files from:
  https://my.cyberghostvpn.com/en/download-hub/vpn
  (If not done yet, the script will guide you)
EOF
read -p "Press Enter to continue..."
clear
print_header "STEP 1/5: INSTALLING DEPENDENCIES"
cat << 'EOF'
Installing: openvpn, curl, openvpn-systemd-resolved
EOF
sudo apt update -qq
sudo apt install -y openvpn curl openvpn-systemd-resolved
echo ""
echo "Installation completed successfully!"
sleep 2
clear
print_header "STEP 2/5: CREATING ~/vpn FOLDER"
echo ""
mkdir -p "$VPN_DIR"
echo "Folder ~/vpn created"
sleep 1
clear
print_header "STEP 3/5: CREATING VPN MANAGER"
echo ""
cat > "$VPN_DIR/cyberghost-vpn-manager.sh" << 'MAINSCRIPT'
#!/bin/bash
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
    print_header "INSTALLING REQUIRED DEPENDENCIES"
    cat << EOF
Missing packages:
$(printf '   - %s\n' "${packages_missing[@]}")
EOF
    read -p "Install now? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[yY]$ ]]; then
        echo "Installing..."
        sudo apt update && sudo apt install -y "${packages_missing[@]}"
        echo "Installation complete!"
        sleep 2
    else
        echo "Installation cancelled."
        exit 1
    fi
}
first_time_setup() {
    local flag="$VPN_DIR/.installed"
    [ -f "$flag" ] && return 0
    clear
    print_header "SHORTCUTS CONFIGURATION"
    cat << 'EOF'
Do you want to install the following shortcuts?
  vpn      - Opens VPN menu
  myip     - Shows your current IP
  vpnoff   - Disconnects VPN quickly
EOF
    read -p "Install shortcuts? (y/n): " alias_choice
    if [[ "$alias_choice" =~ ^[yY]$ ]] && ! grep -q "alias vpn=" ~/.bashrc; then
        cat >> ~/.bashrc << 'ALIASES'
alias vpn='bash ~/vpn/cyberghost-vpn-manager.sh'
alias myip='curl -s ifconfig.me && echo'
alias vpnoff='sudo killall openvpn && echo "VPN disconnected"'
ALIASES
        cat << 'EOF'
SHORTCUTS INSTALLED!
From the NEXT terminal, simply type:
  vpn        - To connect
  myip       - To see your IP
  vpnoff     - To disconnect
In THIS current terminal, type: source ~/.bashrc
EOF
        read -p "Press Enter to continue..."
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
    print_header "MISSING CYBERGHOST FILES"
    cat << EOF
Missing files:
$(printf '   - %s\n' "${files_missing[@]}")
EOF
    read -p "Have you already created an OpenVPN router on CyberGhost? (y/n): " router_existe
    if [[ ! "$router_existe" =~ ^[yY]$ ]]; then
        clear
        cat << 'EOF'
════════════════════════════════════════════════════════════
 COMPLETE GUIDE - CREATING CYBERGHOST ROUTER
════════════════════════════════════════════════════════════
STEP 1: Create your OpenVPN router
───────────────────────────────────
1. Go to: https://my.cyberghostvpn.com/en/download-hub/vpn
2. Click on: "Routers or other devices"
3. Click on: "Create a new configuration"
4. Fill the form:
   - PROTOCOL: Select "OpenVPN"
   - COUNTRY: Choose any (ex: France)
   - SERVER GROUP: Select a group
   - NAME: Type "Linux" (or other name)
5. Click on: "Download configuration"
   - A .zip file will be downloaded
STEP 2: Prepare the files
──────────────────────────
6. Go to ~/Downloads/
7. Right-click on the .zip file
   - "Extract here"
- A folder *_openvpn/ appears with 4 files:
   + xxxxx.ovpn
   + ca.crt
   + client.crt
   + client.key
The script will now detect them automatically!
EOF
        read -p "Press Enter when done..."
    else
        cat << 'EOF'
Make sure you unzipped the files in:
  ~/Downloads/ or ~/Downloads/*_openvpn/
EOF
        read -p "Press Enter to launch automatic search..."
    fi
    clear
    echo "Automatic file search..."
    echo ""
    local search_base="$HOME/Downloads"
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
                echo "$file found and copied"
                ((found_files++))
                break
            fi
        done
    done
    echo ""
    if [ $found_files -lt ${#files_missing[@]} ]; then
        echo "Missing files. Copy them manually to ~/vpn/"
        echo "then restart the script."
        exit 1
    fi
    echo "All files are ready!"
    sleep 2
}
setup_credentials() {
    [ -f "$AUTH_FILE" ] && [ -s "$AUTH_FILE" ] && return 0
    clear
    print_header "CREDENTIALS CONFIGURATION"
    cat << 'EOF'
To get your credentials, go to:
https://my.cyberghostvpn.com/en/settings/manage-devices
EOF
    read -p "CyberGhost Username: " username
    read -sp "Password: " password
    echo ""
    printf '%s\n%s\n' "$username" "$password" > "$AUTH_FILE"
    chmod 600 "$AUTH_FILE"
    echo ""
    echo "Credentials saved"
    sleep 1
}
connect_to_country() {
    local country_code=$1
    local country_name=$2
    sudo killall openvpn 2>/dev/null
    sleep 1
    sudo sed -i "s/^remote .*/remote 87-1-${country_code}.cg-dialup.net 443/" "$OVPN_FILE"
    echo "Connecting to $country_name..."
    grep -q "auth-user-pass.*auth.txt" "$OVPN_FILE" || sudo sed -i "s|auth-user-pass.*|auth-user-pass $AUTH_FILE|" "$OVPN_FILE"
    sudo sed -i '/# Protection DNS/d; /script-security/d; /update-systemd-resolved/d; /down-pre/d; /dhcp-option DOMAIN-ROUTE/d' "$OVPN_FILE"
    cat >> "$OVPN_FILE" << 'EOL'
script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .
EOL
    cd "$VPN_DIR" && sudo openvpn --config "$OVPN_FILE" --daemon
    echo "Establishing VPN tunnel..."
    local count=0
    while [ $count -lt 15 ]; do
        if ip link show tun0 &>/dev/null; then
            break
        fi
        sleep 1
        ((count++))
    done
    sleep 5
    clear
    echo "VPN $country_name connected!"
    echo "DNS protection enabled"
}
check_vpn() {
    echo ""
    echo "Checking connection..."
    local current_ip
    current_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    if [ -z "$current_ip" ]; then
        echo "Unable to retrieve IP"
    else
        echo "Current IP: $current_ip"
        local country
        country=$(curl -s --max-time 5 "https://ipapi.co/${current_ip}/country_name/" 2>/dev/null)
        [ -n "$country" ] && echo "Detected country: $country"
    fi
    echo ""
}
load_countries() {
    [ ! -f "$COUNTRIES_FILE" ] && { echo "countries.conf missing!"; exit 1; }
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
    printf "║     CYBERGHOST VPN MANAGER - %-2d COUNTRIES               ║\n" "$total_countries"
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
    echo "   0) Disconnect VPN and quit"
    echo ""
    echo "════════════════════════════════════════════════════════════"
}
main_loop() {
    load_countries
    while true; do
        show_menu
        read -p "Choose a country (0-100): " choice
        [ "$choice" = "0" ] && { sudo killall openvpn 2>/dev/null; echo ""; echo "VPN disconnected! Goodbye."; exit 0; }
        if [ -n "${COUNTRY_CODE[$choice]}" ]; then
            connect_to_country "${COUNTRY_CODE[$choice]}" "${COUNTRY_NAME[$choice]}"
            check_vpn
            echo "════════════════════════════════════════════════════════════"
            echo "  1) Change location"
            echo "  2) Disconnect VPN and quit"
            echo "════════════════════════════════════════════════════════════"
            read -p "Your choice: " next_action
            case $next_action in
                1) continue ;;
                2) sudo killall openvpn 2>/dev/null; echo "Goodbye."; exit 0 ;;
                *) continue ;;
            esac
        else
            echo "Invalid choice!"
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
echo "VPN manager created"
sleep 1
clear
print_header "STEP 4/5: COUNTRIES DATABASE"
echo ""
cat > "$VPN_DIR/countries.conf" << 'EOF'
1|de|Germany|Europe
2|al|Albania|Europe
3|ad|Andorra|Europe
4|at|Austria|Europe
5|by|Belarus|Europe
6|be|Belgium|Europe
7|ba|Bosnia and Herzegovina|Europe
8|bg|Bulgaria|Europe
9|hr|Croatia|Europe
10|cy|Cyprus|Europe
11|cz|Czech Republic|Europe
12|dk|Denmark|Europe
13|ee|Estonia|Europe
14|fi|Finland|Europe
15|fr|France|Europe
16|ge|Georgia|Europe
17|gr|Greece|Europe
18|gl|Greenland|Europe
19|hu|Hungary|Europe
20|is|Iceland|Europe
21|ie|Ireland|Europe
22|im|Isle of Man|Europe
23|it|Italy|Europe
24|lv|Latvia|Europe
25|li|Liechtenstein|Europe
26|lt|Lithuania|Europe
27|lu|Luxembourg|Europe
28|mt|Malta|Europe
29|md|Moldova|Europe
30|mc|Monaco|Europe
31|me|Montenegro|Europe
32|mk|North Macedonia|Europe
33|nl|Netherlands|Europe
34|no|Norway|Europe
35|pl|Poland|Europe
36|pt|Portugal|Europe
37|ro|Romania|Europe
38|ru|Russia|Europe
39|rs|Serbia|Europe
40|sk|Slovakia|Europe
41|si|Slovenia|Europe
42|es|Spain|Europe
43|se|Sweden|Europe
44|ch|Switzerland|Europe
45|tr|Turkey|Europe
46|ua|Ukraine|Europe
47|gb|United Kingdom|Europe
48|dz|Algeria|Africa & Middle East
49|eg|Egypt|Africa & Middle East
50|ke|Kenya|Africa & Middle East
51|ma|Morocco|Africa & Middle East
52|ng|Nigeria|Africa & Middle East
53|za|South Africa|Africa & Middle East
54|ae|United Arab Emirates|Africa & Middle East
55|il|Israel|Africa & Middle East
56|qa|Qatar|Africa & Middle East
57|sa|Saudi Arabia|Africa & Middle East
58|ar|Argentina|America
59|bs|Bahamas|America
60|bo|Bolivia|America
61|br|Brazil|America
62|ca|Canada|America
63|cl|Chile|America
64|co|Colombia|America
65|cr|Costa Rica|America
66|do|Dominican Republic|America
67|ec|Ecuador|America
68|gt|Guatemala|America
69|mx|Mexico|America
70|pa|Panama|America
71|pe|Peru|America
72|us|United States|America
73|uy|Uruguay|America
74|ve|Venezuela|America
75|am|Armenia|Asia
76|bd|Bangladesh|Asia
77|kh|Cambodia|Asia
78|cn|China|Asia
79|hk|Hong Kong|Asia
80|in|India|Asia
81|id|Indonesia|Asia
82|ir|Iran|Asia
83|jp|Japan|Asia
84|kz|Kazakhstan|Asia
85|kr|South Korea|Asia
86|la|Laos|Asia
87|mo|Macau|Asia
88|my|Malaysia|Asia
89|mn|Mongolia|Asia
90|mm|Myanmar|Asia
91|np|Nepal|Asia
92|pk|Pakistan|Asia
93|ph|Philippines|Asia
94|sg|Singapore|Asia
95|lk|Sri Lanka|Asia
96|tw|Taiwan|Asia
97|th|Thailand|Asia
98|vn|Vietnam|Asia
99|au|Australia|Oceania
100|nz|New Zealand|Oceania
EOF
echo "Database created (100 countries)"
sleep 1
clear
print_header "INSTALLATION COMPLETE!"
echo ""
if grep -q "alias vpn=" ~/.bashrc; then
    cat << 'EOF'
SHORTCUTS CREATED (available after terminal restart):
   - vpn      - Opens VPN menu
   - myip     - Shows your current IP
   - vpnoff   - Disconnects VPN quickly
EOF
    touch "$VPN_DIR/.installed"
fi
cat << 'EOF'
Created files:
   ~/vpn/cyberghost-vpn-manager.sh
   ~/vpn/countries.conf (100 countries)
════════════════════════════════════════════════════════════
What do you want to do now?
  1) Launch VPN manager now
  2) Quit (you can launch later with: vpn)
EOF
read -p "Your choice (1-2): " final_choice
case $final_choice in
    1)
        echo ""
        echo "Launching VPN manager..."
        sleep 1
        bash "$VPN_DIR/cyberghost-vpn-manager.sh"
        ;;
    2)
        cat << 'EOF'
Installation complete!
To launch VPN later, type: vpn
(or: bash ~/vpn/cyberghost-vpn-manager.sh)
EOF
        ;;
    *)
        echo ""
        echo "To launch VPN, type: vpn"
        echo ""
        ;;
esac
