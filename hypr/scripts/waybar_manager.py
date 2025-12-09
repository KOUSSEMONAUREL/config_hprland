#!/usr/bin/env python3
"""
Daemon d'auto-hide pour Waybar - Version corrigée
Comportement:
- Waybar cachée par défaut au démarrage
- S'affiche quand la souris va en haut de l'écran
- Reste visible tant que la souris est sur la barre
- Se cache 2s après que la souris quitte la barre
"""
import time
import subprocess
import os
import signal

# Configuration
TRIGGER_ZONE = 15        # Zone pour déclencher l'apparition (pixels depuis le haut)
WAYBAR_HEIGHT = 40       # Hauteur de la waybar + marge
SHOW_DELAY = 0.2         # Délai avant d'afficher
HIDE_DELAY = 2.0         # Délai avant de cacher
POLL_INTERVAL = 0.15     # Intervalle de vérification
STATE_FILE = "/tmp/waybar_visible"

# État interne (source de vérité)
is_visible = False

def log(msg):
    """Log simple vers fichier"""
    with open("/tmp/waybar_debug.log", "a") as f:
        f.write(f"{time.strftime('%H:%M:%S')} {msg}\n")

def get_cursor_y():
    """Récupère la position Y de la souris"""
    try:
        res = subprocess.check_output(["hyprctl", "cursorpos"], text=True, stderr=subprocess.DEVNULL).strip()
        return int(res.split(',')[1].strip())
    except:
        return 500

def send_signal_to_waybar():
    """Envoie SIGUSR1 à waybar pour toggle"""
    subprocess.run(["pkill", "-SIGUSR1", "waybar"], capture_output=True)

def show_waybar():
    """Affiche la waybar"""
    global is_visible
    if not is_visible:
        log(">>> SHOW waybar")
        send_signal_to_waybar()
        is_visible = True
        with open(STATE_FILE, "w") as f:
            f.write("1")

def hide_waybar():
    """Cache la waybar"""
    global is_visible
    if is_visible:
        log(">>> HIDE waybar")
        send_signal_to_waybar()
        is_visible = False
        with open(STATE_FILE, "w") as f:
            f.write("0")

def init():
    """Initialise waybar en état caché"""
    global is_visible
    log("=== Démarrage daemon v2 ===")
    
    # Lire l'état actuel depuis le fichier (pour gérer les restarts)
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            is_visible = f.read().strip() == "1"
    
    # Si visible, on la cache
    if is_visible:
        log("Waybar visible au démarrage, on la cache")
        send_signal_to_waybar()
        is_visible = False
    
    with open(STATE_FILE, "w") as f:
        f.write("0")
    
    log("Init complete, waybar cachée")

# Variables de timing
hover_start = 0
leave_start = 0

# Lancement
init()

while True:
    try:
        y = get_cursor_y()
        now = time.time()
        
        # Zones
        in_trigger = y <= TRIGGER_ZONE
        on_bar = y <= WAYBAR_HEIGHT
        
        if is_visible:
            # === BARRE VISIBLE ===
            if on_bar:
                # Souris sur la barre -> reset le timer de disparition
                leave_start = 0
            else:
                # Souris a quitté la barre
                if leave_start == 0:
                    leave_start = now
                    log(f"Souris quitte barre (y={y}), timer 2s")
                elif (now - leave_start) >= HIDE_DELAY:
                    hide_waybar()
                    leave_start = 0
                    hover_start = 0
        else:
            # === BARRE CACHÉE ===
            if in_trigger:
                # Souris en zone haute
                if hover_start == 0:
                    hover_start = now
                elif (now - hover_start) >= SHOW_DELAY:
                    show_waybar()
                    hover_start = 0
                    leave_start = 0
            else:
                # Souris ailleurs -> reset
                hover_start = 0
        
        time.sleep(POLL_INTERVAL)
        
    except KeyboardInterrupt:
        log("=== Arrêt daemon ===")
        break
    except Exception as e:
        log(f"Erreur: {e}")
        time.sleep(1)
