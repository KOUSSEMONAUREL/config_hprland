#!/bin/bash
# gamemode_end.sh - Exécuté quand un jeu quitte

# Réactiver hypridle si pas déjà lancé
if ! pgrep -x "hypridle" > /dev/null; then
    hypridle &
fi

# Signaler Waybar pour mise à jour immédiate
pkill -SIGRTMIN+1 waybar

# Notification
notify-send "💤 Game Mode OFF" "Veille réactivée" -i preferences-desktop-screensaver
