#!/bin/bash

# Configuration
MAX_ITEMS=200
STYLE_FILE="$HOME/.config/wofi/clipboard-style.css"
TEMP_MAP="/tmp/cliphist_map_$$"

# Nettoyage à la sortie
cleanup() { rm -f "$TEMP_MAP"; }
trap cleanup EXIT

# Vérification du service wl-paste
if ! pgrep -x "wl-paste" > /dev/null; then
    notify-send "⚠️ Presse-papier" "Service arrêté, redémarrage..."
    wl-paste -t text --watch cliphist -max-items 200 store &
    sleep 0.5
fi

# Récupérer l'historique
raw_history=$(cliphist list)

if [ -z "$raw_history" ]; then
    raw_history="0	(Historique vide)"
fi

# Compter et formater
total_items=$(echo "$raw_history" | wc -l)
formatted_list=""
echo "" > "$TEMP_MAP"

counter=$total_items
while IFS=$'\t' read -r id content; do
    echo "$counter|$id|$content" >> "$TEMP_MAP"
    if [ -n "$formatted_list" ]; then
        formatted_list="${formatted_list}\n${counter}. ${content}"
    else
        formatted_list="${counter}. ${content}"
    fi
    ((counter--))
done <<< "$raw_history"

# Menu simple : items en premier, puis actions
# On utilise --sort-order=default pour garder l'ordre
full_menu="${formatted_list}\n─────────────\n🗑️ Tout supprimer"

selection=$(echo -e "$full_menu" | wofi --dmenu \
    --prompt "📋 Presse-papier" \
    --style "$STYLE_FILE" \
    --width 550 \
    --height 400 \
    --sort-order=default \
    --allow-markup)

[ -z "$selection" ] && exit 0

# Traitement
if [[ "$selection" == "🗑️ Tout supprimer" ]]; then
    # Confirmation avec même style
    confirm=$(echo -e "❌ Annuler\n✅ Confirmer" | wofi --dmenu \
        --style "$HOME/.config/wofi/action-style.css" \
        --width 280 \
        --height 150 \
        --sort-order=default \
        --allow-markup \
        --hide-search)
    
    [[ "$confirm" == "✅ Confirmer" ]] && cliphist wipe && notify-send "🗑️" "Historique effacé"

elif [[ "$selection" =~ ^([0-9]+)\. ]]; then
    # Item sélectionné - afficher actions
    selected_num="${BASH_REMATCH[1]}"
    original_line=$(grep "^${selected_num}|" "$TEMP_MAP" | cut -d'|' -f2-)
    
    if [ -n "$original_line" ]; then
        selected_id=$(echo "$original_line" | cut -d'|' -f1)
        selected_content=$(echo "$original_line" | cut -d'|' -f2-)
        
        # Menu d'action avec boutons grands
        action=$(echo -e "📋 Copier\n🗑️ Supprimer" | wofi --dmenu \
            --style "$HOME/.config/wofi/action-style.css" \
            --width 300 \
            --height 180 \
            --sort-order=default \
            --allow-markup \
            --hide-search)
        
        case "$action" in
            "📋 Copier")
                echo -e "${selected_id}\t${selected_content}" | cliphist decode | wl-copy
                notify-send "📋" "Copié!"
                ;;
            "🗑️ Supprimer")
                echo -e "${selected_id}\t${selected_content}" | cliphist delete
                notify-send "🗑️" "Supprimé"
                ;;
        esac
    fi
fi
