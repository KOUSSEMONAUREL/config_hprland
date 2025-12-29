#!/bin/bash
# gamemode_start.sh - Exécuté quand un jeu démarre

# Désactiver hypridle (gestionnaire de veille)
killall hypridle

# Signaler Waybar pour mise à jour immédiate
pkill -SIGRTMIN+1 waybar

# Notification
notify-send "🎮 Game Mode ON" "Optimisations activées & Veille désactivée" -i input-gaming
