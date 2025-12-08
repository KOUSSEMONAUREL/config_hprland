#!/usr/bin/env python3
"""Gestionnaire auto-hide ultra-léger pour Waybar"""
import time
import subprocess
import os
import logging

# Config
THRESHOLD_Y = 20
SHOW_DELAY = 1.0
HIDE_DELAY = 2.0
POLL_INTERVAL = 0.5  # Optimisé pour consommation minimale

# Logging minimal
logging.basicConfig(filename="/tmp/waybar_manager.log", level=logging.WARNING, 
                    format='%(asctime)s - %(message)s')

def get_cursor_y():
    """Récupère seulement la position Y de la souris"""
    try:
        result = subprocess.check_output(["hyprctl", "cursorpos"], text=True).strip()
        return int(result.split(',')[1])
    except:
        return 1000  # Position safe en bas si erreur

def toggle():
    os.system("pkill -SIGUSR1 waybar")

# État
visible = False
hover_start = 0
leave_time = 0

time.sleep(1)  # Pause initiale

while True:
    y = get_cursor_y()
    now = time.time()
    
    if y <= THRESHOLD_Y:
        if hover_start == 0:
            hover_start = now
        leave_time = now
        
        if not visible and (now - hover_start) >= SHOW_DELAY:
            toggle()
            visible = True
    else:
        hover_start = 0
        
        if visible and (now - leave_time) >= HIDE_DELAY:
            toggle()
            visible = False
    
    time.sleep(POLL_INTERVAL)
