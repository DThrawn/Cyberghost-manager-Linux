
## CyberGhost VPN Manager (OpenVPN)

Interactive terminal-based manager (-13KB) for quickly connecting to CyberGhost VPN via OpenVPN. Simplicity-oriented configuration.

Alternative to the official CyberGhost CLI Linux application.

[Lisezmoi version francaise](https://github.com/DThrawn/Cyberghost-manager-Linux/blob/main/Lisezmoi.md)

<a href='https://ko-fi.com/C1C41SAOT6' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Features

- Automatic installation of OpenVPN dependencies.
- Guided import of CyberGhost files (`.ovpn` + certificates).
- Interactive menu by country (100 entries).
- Optional shortcuts: `vpn`, `monip`, `vpnoff`.
- DNS leak protection (via `systemd-resolved`) if available on the distro.

## Compatibility

- Tested only on `Pop!_OS`.
- Should work on `Ubuntu` (and `Debian` derivatives) as long as `apt` is available.

## CyberGhost Requirements

Before the first connection, **The script will guide you step by step during installation**, you will need to download an OpenVPN configuration from the CyberGhost customer area:
- `Download Hub` → `Routers or other devices` → `create/download` the `OpenVPN` configuration
- Extract the `.zip`: you get a `.ovpn` file + `ca.crt` + `client.crt` + `client.key`

It will then detect these files (in `~/Downloads/`) and copy them to `~/vpn/`.

## Installation

Download the [install-cyberghost_en.sh](https://github.com/DThrawn/Cyberghost-manager-Linux/blob/d8f13552cc60f8b574736196a939ced2dcdba813/install-cyberghost_en.sh) file

Open terminal in downloads folder

```bash
bash install-cyberghost_en.sh
```

**or**

Clone the repository:
```bash
git clone https://github.com/DThrawn/Cyberghost-manager-linux.git && cd Cyberghost-manager-linux && bash install-cyberghost_en.sh
```

**or**

Via Curl
```bash
curl -L https://raw.githubusercontent.com/DThrawn/Cyberghost-manager-linux/main/install-cyberghost_en.sh | bash
```

**The script creates:**
- `~/vpn`
- `~/vpn/cyberghost-vpn-manager.sh`
- `~/vpn/countries.conf`
- `~/vpn/auth.txt`

## Usage

Open a new terminal (if you chose to install aliases), then:

- Launch the menu:
```bash
vpn
```

- Display public IP:
```bash
monip
```

- Disconnect OpenVPN connection (stop process):
```bash
vpnoff
```

- Without aliases, run directly:
```bash
bash ~/vpn/cyberghost-vpn-manager.sh
```

## Uninstall

Just deletes the folder: `~/vpn`

**To completely uninstall CyberGhost VPN Manager:**
```bash
sudo apt remove --purge openvpn openvpn-systemd-resolved && rm -rf ~/vpn && sed -i '/# CyberGhost VPN Aliases/,+3d' ~/.bashrc && sudo killall openvpn 2>/dev/null
```

**What the command does**

1. Removes packages: `openvpn` and `openvpn-systemd-resolved`
2. Deletes the folder: `~/vpn` and all its contents
3. Removes aliases from `.bashrc` file

## Important Notes

- This script is unofficial and is not affiliated with CyberGhost.
- CyberGhost OpenVPN credentials are requested at first launch and saved locally in `~/vpn/auth.txt` (restricted permissions).
- No Kill Switch

## About

This script was created to replace the official CyberGhost CLI Linux application available on the website, which has recurring bugs in my use case.

Initially developed for personal use on Pop!_OS (Ubuntu derivative), I'm sharing it as-is to help other users.

First public release: your feedback is welcome, please be kind. The configuration remains intentionally simple and formatting is handled automatically by the installation script.

## Support
If this project is useful to you, you can buy me a coffee:

<a href='https://ko-fi.com/C1C41SAOT6' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## License

MIT License - Free to use and modify.
