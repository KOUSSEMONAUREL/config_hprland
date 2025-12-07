#!/bin/bash
MINIMIZED_WORKSPACE="special:minimized"
CURRENT_WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl clients -j | jq -r --argjson current_ws_id "$CURRENT_WORKSPACE_ID" '[.[] | select(.workspace.id == $current_ws_id)] | .[].address' | while read -r window_address; do
    hyprctl dispatch movetoworkspacesilent "$MINIMIZED_WORKSPACE,address:$window_address"
done