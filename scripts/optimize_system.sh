#!/bin/bash
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Optimisation du système ===${NC}"

# 1. Disable Coredumps
echo "Désactivation des Coredumps (évite les freeze CPU lors des crashs)..."
if [ -f "../system/etc/systemd/coredump.conf" ]; then
    sudo cp "../system/etc/systemd/coredump.conf" "/etc/systemd/coredump.conf"
    sudo systemctl daemon-reload
    echo "Configuration appliquée."
else
    echo "Fichier de configuration non trouvé."
fi
