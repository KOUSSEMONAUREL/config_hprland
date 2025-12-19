#!/bin/bash

# Script d'installation groupée de tous les outils de hacking
kitty -e bash -c "
echo '═══════════════════════════════════════════════'
echo '  Installation des Hack Tools'
echo '═══════════════════════════════════════════════'
echo ''
echo 'Outils CLI :'
echo '  • Nmap - Scanner réseau'
echo '  • Metasploit - Framework d exploitation'
echo '  • Aircrack-ng - Sécurité WiFi'
echo '  • John the Ripper - Cracking de mots de passe'
echo '  • Hydra - Brute force'
echo '  • SQLMap - Injection SQL'
echo '  • Nikto - Scanner web'
echo '  • Hashcat - Cracking GPU'
echo '  • TCPDump - Capture de paquets'
echo ''
echo 'Outils GUI :'
echo '  • Wireshark - Analyse de paquets (GUI)'
echo '  • Zenmap - Interface Nmap (GUI)'
echo '  • OWASP ZAP - Proxy web (GUI)'
echo '  • Ettercap GTK - MITM (GUI)'
echo '  • Ghidra - Reverse Engineering (GUI)'
echo ''
echo '═══════════════════════════════════════════════'
echo ''

sudo pacman -S nmap wireshark-qt metasploit aircrack-ng john hydra sqlmap nikto hashcat tcpdump zenmap zaproxy ettercap-gtk ghidra --noconfirm

echo ''
echo '═══════════════════════════════════════════════'
echo '  Installation terminée !'
echo '═══════════════════════════════════════════════'
echo ''
echo 'Appuyez sur Entrée pour quitter...'
read
"
