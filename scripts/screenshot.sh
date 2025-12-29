#!/bin/bash

# Dossier pour sauvegarder les captures
SCREENSHOT_DIR=~/Pictures/Screenshots
mkdir -p "$SCREENSHOT_DIR"

# Nom de fichier unique avec timestamp
FILENAME="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

# Fonction de capture et notification
capture() {
  local image=$1
  wl-copy < "$image"
  notify-send "Capture d'écran" "Copiée dans le presse-papiers et sauvegardée."
}

# Menu principal avec Wofi
CHOICE=$(printf " Rectangle\n Fenêtre\n🖥 Plein écran" | wofi -d -p "Outil de capture")

case "$CHOICE" in
  " Rectangle")
    # Sélectionne une région et capture
    GEOMETRY=$(slurp)
    if [ -n "$GEOMETRY" ]; then
      grim -g "$GEOMETRY" "$FILENAME"
      capture "$FILENAME"
    else
      notify-send "Capture d'écran" "Action annulée."
    fi
    ;;

  " Fenêtre")
    # Sélectionne une fenêtre et capture
    # Récupère les informations des fenêtres via hyprctl et jq
    WINDOWS=$(hyprctl -j clients | jq -r '.[] | select(.pid != -1) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])  |  \(.class): \(.title)" ')
    if [ -z "$WINDOWS" ]; then
        notify-send "Capture d'écran" "Aucune fenêtre à capturer."
        exit 1
    fi

    # Affiche la liste des fenêtres avec wofi
    SELECTED_WINDOW=$(echo "$WINDOWS" | wofi -d -p "Choisir une fenêtre")

    if [ -n "$SELECTED_WINDOW" ]; then
      # Extrait la géométrie de la ligne sélectionnée
      GEOMETRY=$(echo "$SELECTED_WINDOW" | sed 's/  |.*//')
      grim -g "$GEOMETRY" "$FILENAME"
      capture "$FILENAME"
    else
      notify-send "Capture d'écran" "Action annulée."
    fi
    ;;

  "🖥 Plein écran")
    # Capture l'écran entier
    grim "$FILENAME"
    capture "$FILENAME"
    ;;
  *)
    notify-send "Capture d'écran" "Action annulée."
    ;;
esac