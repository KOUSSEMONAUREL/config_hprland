#!/bin/bash

# Get clipboard history
selection=$(cliphist list | wofi --dmenu)

# If nothing is selected, exit
[ -z "$selection" ] && exit

# Choose action
action=$(echo -e "Copy\nDelete" | wofi --dmenu)

# Perform action
case $action in
    Copy)
        echo "$selection" | cliphist decode | wl-copy
        ;;
    Delete)
        echo "$selection" | cliphist delete
        ;;
esac
