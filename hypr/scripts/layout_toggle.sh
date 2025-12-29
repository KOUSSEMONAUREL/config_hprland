#!/bin/bash

LOG_FILE="/tmp/hypr_layout_toggle.log"
echo "---" >> "$LOG_FILE"
echo "Script v6 started at $(date)" >> "$LOG_FILE"

if [ "$1" = "init" ]; then
    echo "Initializing dwindle layout bindings" >> "$LOG_FILE"
    hyprctl --batch \
        "keyword general:layout dwindle;\
        keyword bind SUPER,left,movefocus,l;\
        keyword bind SUPER,right,movefocus,r;\
        keyword bind SUPER,up,movefocus,u;\
        keyword bind SUPER,down,movefocus,d;\
        keyword bind SUPER SHIFT,left,movewindoworgroup,l;\
        keyword bind SUPER SHIFT,right,movewindoworgroup,r;\
        keyword bind SUPER SHIFT,up,movewindoworgroup,u;\
        keyword bind SUPER SHIFT,down,movewindoworgroup,d"
    hyprctl notify -1 2000 "rgb(2E9AFA)" "Layout: dwindle (initialized)"
    echo "Script finished (init) at $(date)" >> "$LOG_FILE"
    exit 0
fi

# Get current layout
CURRENT_LAYOUT=$(hyprctl getoption general:layout | grep 'str:' | awk '{print $2}')
echo "Detected layout: [$CURRENT_LAYOUT]" >> "$LOG_FILE"

if [ "$CURRENT_LAYOUT" = "dwindle" ]; then
    echo "Switching to hy3" >> "$LOG_FILE"
    hyprctl --batch \
        "keyword general:layout hy3;\
        keyword bind SUPER,left,hy3:movefocus,l;\
        keyword bind SUPER,right,hy3:movefocus,r;\
        keyword bind SUPER,up,hy3:movefocus,u;\
        keyword bind SUPER,down,hy3:movefocus,d;\
        keyword bind SUPER SHIFT,left,hy3:movewindow,l;\
        keyword bind SUPER SHIFT,right,hy3:movewindow,r;\
        keyword bind SUPER SHIFT,up,hy3:movewindow,u;\
        keyword bind SUPER SHIFT,down,hy3:movewindow,d"
    hyprctl notify -1 2000 "rgb(2E9AFA)" "Layout: hy3"
else
    echo "Switching to dwindle" >> "$LOG_FILE"
    hyprctl --batch \
        "keyword general:layout dwindle;\
        keyword bind SUPER,left,movefocus,l;\
        keyword bind SUPER,right,movefocus,r;\
        keyword bind SUPER,up,movefocus,u;\
        keyword bind SUPER,down,movefocus,d;\
        keyword bind SUPER SHIFT,left,movewindoworgroup,l;\
        keyword bind SUPER SHIFT,right,movewindoworgroup,r;\
        keyword bind SUPER SHIFT,up,movewindoworgroup,u;\
        keyword bind SUPER SHIFT,down,movewindoworgroup,d"
    hyprctl notify -1 2000 "rgb(2E9AFA)" "Layout: dwindle"
fi

echo "Script finished at $(date)" >> "$LOG_FILE"