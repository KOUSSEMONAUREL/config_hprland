#!/bin/bash
STATE_FILE="/tmp/transparency_state"

# Initialiser l'état (1 = transparent par défaut)
if [[ ! -f "$STATE_FILE" ]]; then echo "1" > "$STATE_FILE"; fi

# Action (toggle ou status)
ACTION=$1

if [[ "$ACTION" == "toggle" ]]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
    if [[ "$CURRENT_STATE" == "1" ]]; then
        # Passer en OPAQUE
        hyprctl keyword decoration:active_opacity 1.0
        hyprctl keyword decoration:inactive_opacity 1.0
        echo "0" > "$STATE_FILE"
    else
        # Passer en TRANSPARENT
        hyprctl keyword decoration:active_opacity 0.9
        hyprctl keyword decoration:inactive_opacity 0.8
        echo "1" > "$STATE_FILE"
    fi
    # Rafraîchir waybar via signal (si nécessaire)
    pkill -RTMIN+10 waybar
fi

# Renvoyer le statut JSON pour Waybar
CURRENT_STATE=$(cat "$STATE_FILE")
if [[ "$CURRENT_STATE" == "1" ]]; then
    echo '{"text": "", "tooltip": "Transparence: ACTIVÉE (Clic pour désactiver)", "class": "enabled", "alt": "enabled"}'
else
    echo '{"text": "", "tooltip": "Transparence: DÉSACTIVÉE (Clic pour activer)", "class": "disabled", "alt": "disabled"}'
fi
