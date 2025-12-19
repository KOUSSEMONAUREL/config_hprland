#!/bin/bash

# COULEURS
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== INSTALLATION LECTEUR EMPREINTE ELAN 04f3:0c8e ===${NC}"

# 1. DEPENDANCES
echo "Installation des dépendances..."
sudo pacman -S --needed base-devel meson ninja libusb glib2 systemd git python-gobject libfprint fprintd

# 2. PREPARATION SOURCE
WORK_DIR="/tmp/elan_install"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "Clonage du driver de base..."
# On utilise une version connue qui fonctionne comme base
git clone https://gitlab.freedesktop.org/libfprint/libfprint.git
cd libfprint

# 3. INJECTION DU PATCH
echo "Injection des fichiers patchés..."
REPO_ROOT=$(dirname $(dirname $(readlink -f $0)))
PATCH_SRC="$REPO_ROOT/patches/libfprint-elanmoc2/src"

if [ ! -d "$PATCH_SRC" ]; then
    echo -e "${RED}ERREUR: Dossier de patch non trouvé: $PATCH_SRC${NC}"
    exit 1
fi

cp "$PATCH_SRC/elanmoc2.c" libfprint/drivers/elanmoc2/
cp "$PATCH_SRC/elanmoc2.h" libfprint/drivers/elanmoc2/

# 4. COMPILATION
echo "Compilation..."
meson setup build
meson compile -C build

# 5. INSTALLATION
echo "Installation..."
sudo cp build/libfprint/libfprint-2.so.2.0.0 /usr/lib/
sudo systemctl restart fprintd

# 6. CONFIG PAM
echo "Configuration PAM..."
PAM_FILE="/etc/pam.d/system-auth"
if ! grep -q "pam_fprintd.so" "$PAM_FILE"; then
    echo "Ajout de pam_fprintd.so à $PAM_FILE"
    # Backup
    sudo cp "$PAM_FILE" "${PAM_FILE}.bak"
    
    # Insertion après pam_faillock preauth
    sudo sed -i '/auth       required                    pam_faillock.so      preauth/a auth       sufficient                  pam_fprintd.so' "$PAM_FILE"
else
    echo "PAM déjà configuré."
fi

echo -e "${GREEN}=== INSTALLATION TERMINEE ===${NC}"
echo "Testez avec: fprintd-enroll"
