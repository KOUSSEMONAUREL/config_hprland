#!/bin/bash
# Script de toggle centralisé avec gestion d'état

STATE_FILE="/tmp/waybar_visible"

# Si le fichier n'existe pas, on assume que la barre est cachée (start_hidden: true)
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" == "1" ]; then
    # Elle est visible -> On la cache
    pkill -SIGUSR1 waybar
    echo "0" > "$STATE_FILE"
    # echo "Hidden"
else
    # Elle est cachée -> On la montre
    pkill -SIGUSR1 waybar
    echo "1" > "$STATE_FILE"
    # echo "Visible"
fi
