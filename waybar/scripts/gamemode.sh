#!/bin/bash
if pgrep -x "hypridle" > /dev/null
then
    killall hypridle
    notify-send "🎮 Game Mode ON" "Veille désactivée" -i input-gaming
else
    hypridle &
    notify-send "💤 Game Mode OFF" "Veille réactivée" -i preferences-desktop-screensaver
fi
