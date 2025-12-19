#!/bin/bash

# Définir le chemin vers nos outils de hack isolés
export XDG_DATA_DIRS="$HOME/.local/share/hack-tools:$XDG_DATA_DIRS:/usr/share"

# Afficher uniquement les applications de catégorie HackTools avec Rofi
# en mode drun (affiche les vraies applications avec leurs icônes)
rofi -show drun -show-icons -drun-categories HackTools -config ~/.config/rofi/config.rasi
