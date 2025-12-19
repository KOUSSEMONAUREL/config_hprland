#!/bin/bash
# Script de toggle manuel pour Waybar
if pgrep -x "hypridle" > /dev/null
then
    # Si veille active, on force le mode jeu
    killall hypridle
    notify-send "🎮 Game Mode ON" "Veille désactivée manuellement" -i input-gaming
else
    # Si mode jeu actif, on force la veille
    hypridle &
    notify-send "💤 Game Mode OFF" "Veille réactivée manuellement" -i preferences-desktop-screensaver
fi
pkill -SIGRTMIN+1 waybar
