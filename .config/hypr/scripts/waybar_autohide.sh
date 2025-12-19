#!/bin/bash

# Configuration
THRESHOLD_Y=10           # Zone de déclenchement en haut (pixels)
HIDE_DELAY=5             # Secondes avant de cacher
POLL_INTERVAL=0.2        # Intervalle de vérification (secondes)

# Variables d'état
VISIBLE=false
LAST_HOVER_TIME=0

# S'assurer que Waybar démarre caché (si configuré comme tel)
# On n'envoie PAS de signal initial car waybar est configurée avec "start_hidden": true
# pkill -SIGUSR1 waybar 2>/dev/null

while true; do
    # Récupérer la position Y de la souris
    # hyprctl cursorpos retourne "123, 456"
    Y=$(hyprctl cursorpos | cut -d, -f2 | tr -d ' ')
    
    # Vérifier si on est en haut de l'écran
    if [ "$Y" -le "$THRESHOLD_Y" ]; then
        LAST_HOVER_TIME=$(date +%s)
        
        if [ "$VISIBLE" = false ]; then
            # Montrer la barre
            pkill -SIGUSR1 waybar
            VISIBLE=true
        fi
    else
        # Si la barre est visible, vérifier depuis combien de temps on a quitté la zone
        if [ "$VISIBLE" = true ]; then
            CURRENT_TIME=$(date +%s)
            ELAPSED=$((CURRENT_TIME - LAST_HOVER_TIME))
            
            if [ "$ELAPSED" -ge "$HIDE_DELAY" ]; then
                # Cacher la barre
                pkill -SIGUSR1 waybar
                VISIBLE=false
            fi
        fi
    fi
    
    sleep "$POLL_INTERVAL"
done
