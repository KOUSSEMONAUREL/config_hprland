#!/bin/bash
MINIMIZED_WORKSPACE_NAME="special:minimized"
CURRENT_WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized") | .address' | while read -r window_address; do
    hyprctl dispatch movetoworkspacesilent "$CURRENT_WORKSPACE_ID,address:$window_address"
done
