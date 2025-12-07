# Hyprland Configuration 🌌

Ma configuration personnelle pour Hyprland sur Arch Linux.
Focus sur l'esthétique, la performance et l'ergonomie.

![Hyprland Screen](https://raw.githubusercontent.com/KOUSSEMONAUREL/config_hprland/main/waybar/.github/assets/catppuccin-mocha.png)

## ✨ Fonctionnalités

- **Hyprland** : Gestionnaire de fenêtres dynamique (Dwindle layout)
- **Waybar** : Barre d'état complète avec thèmes Catppuccin
- **Fonds d'écran** : 
  - Images statiques sur Workspace 1
  - **Vidéos animées** sur les autres workspaces (mpvpaper)
  - Optimisé pour la batterie (arrêt auto des vidéos)
- **Transparence** : Fenêtres actives (0.9) / Inactives (0.8) + Blur
- **Veille** : Gestion automatique (Verrouillage 5min / Écran 10min / Veille 15min)
- **Outils** :
  - `Rofi` : Lanceur d'applications
  - `Kitty` : Terminal
  - `Power Menu` : Menu d'arrêt complet
- **Administration Système** :
  - `nwg-look` : Apparence (GTK, Icônes, Curseurs)
  - `nwg-displays` : Gestion des écrans
  - `pavucontrol` : Mixeur audio
  - `gnome-disks` : Gestion des disques
  - `blueman` : Bluetooth

## 🚀 Installation Rapide

```bash
git clone https://github.com/KOUSSEMONAUREL/config_hprland.git
cd config_hprland
chmod +x install.sh
./install.sh
```

Le script se chargera d'installer toutes les dépendances (Pacman + AUR) et de copier les fichiers de configuration.

## ⌨️ Raccourcis Principaux

| Touches | Action |
|info|---|
| `Super + Q` | Terminal (Kitty) |
| `Super + C` | Fermer fenêtre |
| `Super + E` | Gestionnaire de fichiers |
| `Super + V` | Toggle fenêtre flottante |
| `Super + R` | Lanceur d'applications (Rofi) |
| `Super + J` | Toggler Split |
| `Super + P` | Pseudo Tiling |
| `Super + D` | Minimiser fenêtre (Space Special) |
| `Shift + Super + D` | Restaurer fenêtres minimisées |

**Waybar** :
- **Logo Arch** : Voir fenêtres minimisées
- **Bouton Oeil (/)** : Activer/Désactiver transparence
- **Bouton Power** : Menu d'extinction complet

## 🔧 Dépendances Manuelles

Si le script d'installation ne fonctionne pas pour vous :

**Pacman :**
`hyprland waybar kitty rofi wofi swaybg hypridle jq socat fzf wl-clipboard cliphist brightnessctl bluez bluez-utils blueman network-manager-applet pavucontrol playerctl ttf-font-awesome ttf-jetbrains-mono-nerd`

**AUR :**
`mpvpaper sddm-git`

## 🎨 Thème SDDM (Connexion)

Pour l'écran de connexion, je recommande le thème **Catppuccin Mocha** pour SDDM :
```bash
yay -S sddm-catppuccin-git
```
Configurez le dans `/etc/sddm.conf`.
