#!/bin/bash

# Définition des options
OPTIONS="  WiFi\n  Bluetooth\n  Audio\n  Apparence\n  Affichage\n  Disques"

# Affichage du menu avec Rofi
SELECTED=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Paramètres" -theme-str 'window {width: 400px;}')

# Action selon le choix
case $SELECTED in
    *"WiFi")
        nm-connection-editor
        ;;
    *"Bluetooth")
        blueman-manager
        ;;
    *"Audio")
        pavucontrol
        ;;
    *"Apparence")
        nwg-look
        ;;
    *"Affichage")
        nwg-displays
        ;;
    *"Disques")
        gnome-disks
        ;;
esac
