#!/bin/sh

# This script is designed to be run by Hyprland on startup.
# It launches three kitty terminals in a specific order with delays
# to ensure they are tiled correctly.

# 1. Launch the main terminal on the left. This will take the whole screen initially.
kitty &
sleep 1

# 2. Launch the top-right terminal (fastfetch).
# This will split the screen, placing this terminal on the right.
kitty -e zsh -c "fastfetch; zsh" &
sleep 1

# 3. Launch the bottom-right terminal (gemini).
# This will split the right-hand container, placing this terminal below fastfetch.
kitty -e gemini &
