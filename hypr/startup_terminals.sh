#!/bin/sh

# This script is designed to be run by Hyprland on startup.
# It launches three kitty terminals in a specific order with delays
# to ensure they are tiled correctly.

TOGGLE_FILE="/tmp/hypr_automations_toggle"

# Vérification du toggle automatismes
# Quitter si le fichier existe et contient "false", ou s'il n'existe pas (comportement par défaut)
# Note: selon la demande user, désactivé par défaut.
if [ ! -f "$TOGGLE_FILE" ] || grep -q "false" "$TOGGLE_FILE"; then
    echo "Automatismes désactivés - Pas de lancement des terminaux"
    exit 0
fi
kitty &
sleep 1

# 2. Launch the top-right terminal (fastfetch).
# This will split the screen, placing this terminal on the right.
kitty -e zsh -c "fastfetch; zsh" &
sleep 1

# 3. Launch the bottom-right terminal (gemini).
# This will split the right-hand container, placing this terminal below fastfetch.
kitty -e gemini &
