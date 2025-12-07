#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Installation Configuration Hyprland ===${NC}"

# Vérifier Yay
if ! command -v yay &> /dev/null; then
    echo "Yay n'est pas installé. Installation de Yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
else
    echo -e "${GREEN}Yay est déjà installé.${NC}"
fi

# 1. Installation des paquets officiels
echo -e "${BLUE}Installation des paquets officiels...${NC}"
PACKAGES=(
    "hyprland"
    "waybar"
    "kitty"
    "rofi"
    "wofi"
    "swaybg"
    "hypridle"
    "jq"
    "socat"
    "fzf"
    "wl-clipboard"
    "cliphist"
    "brightnessctl"
    "bluez"
    "bluez-utils"
    "blueman"
    "network-manager-applet"
    "pavucntrol"
    "playerctl"
    "ttf-font-awesome"
    "ttf-jetbrains-mono-nerd"
    "noto-fonts-emoji"
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# 2. Installation des paquets AUR
echo -e "${BLUE}Installation des paquets AUR (mpvpaper...)${NC}"
yay -S --needed --noconfirm mpvpaper sddm-git hyprshot

# 3. Copie des fichiers de configuration
echo -e "${BLUE}Copie des configurations...${NC}"
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/kitty ~/.config/rofi ~/.config/wofi

cp -r hypr/* ~/.config/hypr/
cp -r waybar/* ~/.config/waybar/
cp -r kitty/* ~/.config/kitty/
cp -r rofi/* ~/.config/rofi/
cp -r wofi/* ~/.config/wofi/

# Rendre exécutables les scripts
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh

# 4. Activation des services
echo -e "${BLUE}Activation des services...${NC}"
sudo systemctl enable --now bluetooth
# sudo systemctl enable --now sddm # Désactivé par sécurité, à activer manuellement

echo -e "${GREEN}=== Installation Terminée ! ===${NC}"
echo "Veuillez redémarrer votre session Hyprland."
echo "Pour activer SDDM (écran de connexion), lancez : sudo systemctl enable --now sddm"
