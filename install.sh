#!/bin/bash

# COULEURS
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

REPO_DIR=$(dirname $(readlink -f $0))

echo -e "${BLUE}=== INSTALLATION DOTFILES HYPRLAND ===${NC}"
echo "Dossier source: $REPO_DIR"

# 1. INSTALLATION DES PAQUETS
echo -e "\n${BLUE}[1/4] Installation des paquets nécessaires...${NC}"
# Liste des paquets de base détectés dans ta config
PACKAGES="hyprland waybar rofi wofi kitty dunst hyprlock hypridle waypaper swww zsh neofetch starship"
# Ajoute ici d'autres paquets si nécessaire

if command -v pacman &> /dev/null; then
    sudo pacman -S --needed $PACKAGES
else
    echo -e "${RED}Pacman non trouvé. Installation manuelle des paquets requise.${NC}"
fi

# 2. CREATION DES LIENS SYMBOLIQUES
echo -e "\n${BLUE}[2/4] Création des liens symboliques...${NC}"

link_config() {
    SRC="$REPO_DIR/.config/$1"
    DEST="$HOME/.config/$1"
    
    if [ -d "$SRC" ]; then
        if [ -d "$DEST" ] && [ ! -L "$DEST" ]; then
            echo "Backup de $DEST vers ${DEST}.bak"
            mv "$DEST" "${DEST}.bak"
        fi
        
        echo "Lien: $SRC -> $DEST"
        ln -sf "$SRC" "$DEST"
    fi
}

# Liste des configs à lier
link_config "hypr"
link_config "waybar"
link_config "kitty"
link_config "rofi"
link_config "wofi"
link_config "gtk-3.0"
link_config "gtk-4.0"

# Shell
echo "Lien .zshrc"
ln -sf "$REPO_DIR/home/.zshrc" "$HOME/.zshrc"

# 3. LECTEUR D'EMPREINTES (OPTIONNEL)
echo -e "\n${BLUE}[3/4] Installation du lecteur d'empreintes ? (o/n)${NC}"
read -r response
if [[ "$response" =~ ^([oO][uU][iI]|[oO])+$ ]]; then
    bash "$REPO_DIR/scripts/install_fingerprint.sh"
fi

# 4. EXTRAS (SDDM, GRUB, etc.)
echo -e "\n${BLUE}[4/4] Installation des extras ? (GRUB randomizer, SDDM theme) (o/n)${NC}"
read -r response
if [[ "$response" =~ ^([oO][uU][iI]|[oO])+$ ]]; then
    # SDDM
    if [ -d "$REPO_DIR/sddm/themes" ]; then
        echo "Installation thème SDDM..."
        sudo cp -r "$REPO_DIR/sddm/themes/"* /usr/share/sddm/themes/
        echo "Activez le thème dans /etc/sddm.conf"
    fi
    
    # GRUB
    if [ -d "$REPO_DIR/grub_randomizer" ]; then
        echo "Pour GRUB randomizer, voir le dossier grub_randomizer/README.md"
    fi
fi

echo -e "\n${GREEN}=== TERMINE ! ===${NC}"
echo "Redémarrez Hyprland pour appliquer les changements."
