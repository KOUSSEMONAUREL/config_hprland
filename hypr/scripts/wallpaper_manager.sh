#!/bin/bash

# --- Configuration ---
STATIC_WALLPAPER_DIR="/usr/share/hypr/"
VIDEO_DIR="/home/aurel/BACK_ALL/"
LOG_FILE="/home/aurel/wallpaper_manager.log"
MONITOR="eDP-1"

# --- Fichiers temporaires et de verrouillage ---
CURRENT_VIDEO_PATH_FILE="/tmp/hypr_current_video.path"
LOCK_FILE="/tmp/wallpaper_manager.lock"
CURRENT_WORKSPACE_FILE="/tmp/hypr_current_workspace"

# --- Prévention des instances multiples ---
if [ -e "$LOCK_FILE" ] && kill -0 "$(cat "$LOCK_FILE")" 2>/dev/null; then
    echo "[$(date)] Erreur : Le script est déjà en cours d'exécution (PID $(cat "$LOCK_FILE")). Sortie." >> "$LOG_FILE"
    exit 1
fi
echo $$ > "$LOCK_FILE"

# --- Initialisation ---
echo "--- Script démarré le $(date) ---" > "$LOG_FILE"

# Sélectionne un fond d'écran statique UNIQUEMENT parmi les wall*.png
STATIC_WALLPAPER_PATH=$(find "$STATIC_WALLPAPER_DIR" -type f -name "wall*.png" 2>/dev/null | shuf -n 1)
if [[ -z "$STATIC_WALLPAPER_PATH" ]]; then
    STATIC_WALLPAPER_PATH="/usr/share/hypr/wall0.png"
fi
echo "Fond d'écran statique pour cette session : $STATIC_WALLPAPER_PATH" >> "$LOG_FILE"

# --- Fonctions ---

kill_mpvpaper() {
    pkill -f "mpvpaper" 2>/dev/null
    sleep 0.2
}

kill_swaybg() {
    pkill -f "swaybg" 2>/dev/null
    sleep 0.2
}

set_static_wallpaper() {
    # Ne rien faire si swaybg tourne déjà (évite de relancer l'image)
    if pgrep -x "swaybg" > /dev/null; then
        echo "swaybg déjà actif, pas de changement" >> "$LOG_FILE"
        return
    fi
    kill_mpvpaper
    echo "Action : Fond d'écran statique : $STATIC_WALLPAPER_PATH" >> "$LOG_FILE"
    swaybg -i "$STATIC_WALLPAPER_PATH" -m fill &
}

set_animated_wallpaper() {
    local video_path="$1"
    kill_swaybg
    kill_mpvpaper
    echo "Action : Fond d'écran animé : $video_path" >> "$LOG_FILE"
    mpvpaper -f -o "no-audio loop" "$MONITOR" "$video_path" &
}

select_random_video() {
    local new_video
    new_video=$(find "$VIDEO_DIR" -type f \( -name "*.mp4" -o -name "*.gif" -o -name "*.webm" \) 2>/dev/null | shuf -n 1)
    if [[ -n "$new_video" ]]; then
        echo "$new_video" > "$CURRENT_VIDEO_PATH_FILE"
        echo "Vidéo sélectionnée : $new_video" >> "$LOG_FILE"
    fi
}

rotate_videos_background() {
    while true; do
        sleep 600 # 10 minutes
        echo "Rotation : changement de vidéo." >> "$LOG_FILE"
        select_random_video
        # Appliquer seulement si on est sur un workspace != 1
        local current_ws
        current_ws=$(cat "$CURRENT_WORKSPACE_FILE" 2>/dev/null)
        if [[ "$current_ws" != "1" && -n "$current_ws" ]]; then
            local video
            video=$(cat "$CURRENT_VIDEO_PATH_FILE" 2>/dev/null)
            if [[ -n "$video" && -f "$video" ]]; then
                set_animated_wallpaper "$video"
            fi
        fi
    done
}

set_wallpaper_for_workspace() {
    local workspace_id=$1
    local previous_ws
    previous_ws=$(cat "$CURRENT_WORKSPACE_FILE" 2>/dev/null)
    
    # Sauvegarder le workspace actuel
    echo "$workspace_id" > "$CURRENT_WORKSPACE_FILE"
    
    # Éviter les actions redondantes si on reste sur le même workspace
    if [[ "$workspace_id" == "$previous_ws" ]]; then
        return
    fi
    
    echo "Changement : workspace $previous_ws -> $workspace_id" >> "$LOG_FILE"

    if [[ "$workspace_id" == "1" ]]; then
        # On va sur workspace 1 : fond statique
        set_static_wallpaper
    else
        # On va sur workspace != 1
        if [[ "$previous_ws" == "1" || -z "$previous_ws" ]]; then
            # On vient du workspace 1 (ou démarrage) : lancer la vidéo
            local current_video
            current_video=$(cat "$CURRENT_VIDEO_PATH_FILE" 2>/dev/null)
            if [[ -n "$current_video" && -f "$current_video" ]]; then
                set_animated_wallpaper "$current_video"
            fi
        else
            # On passe d'un workspace !=1 à un autre !=1 : ne rien faire
            echo "Pas de changement de fond (on reste sur vidéo)" >> "$LOG_FILE"
        fi
    fi
}

# --- Logique principale ---

if ! command -v mpvpaper &> /dev/null || ! command -v swaybg &> /dev/null; then
    echo "Erreur : 'mpvpaper' et 'swaybg' doivent être installés." >> "$LOG_FILE"
    exit 1
fi

if ! command -v jq &> /dev/null || ! command -v socat &> /dev/null; then
    echo "Erreur : 'jq' et 'socat' doivent être installés." >> "$LOG_FILE"
    exit 1
fi

sleep 2

# Lancer la rotation en arrière-plan
rotate_videos_background &
ROTATOR_PID=$!
echo "Rotation démarrée avec PID : $ROTATOR_PID" >> "$LOG_FILE"

# Nettoyage à la sortie
trap "kill $ROTATOR_PID 2>/dev/null; kill_mpvpaper; kill_swaybg; rm -f '$LOCK_FILE' '$CURRENT_VIDEO_PATH_FILE' '$CURRENT_WORKSPACE_FILE'; exit" SIGINT SIGTERM EXIT

# Sélectionner une vidéo (mais ne pas la lancer tout de suite)
select_random_video

# Appliquer le fond selon le workspace initial
initial_ws=$(hyprctl activeworkspace -j | jq -r ".id")
echo "Workspace initial : $initial_ws" >> "$LOG_FILE"
echo "$initial_ws" > "$CURRENT_WORKSPACE_FILE"

if [[ "$initial_ws" == "1" ]]; then
    set_static_wallpaper
else
    local_video=$(cat "$CURRENT_VIDEO_PATH_FILE" 2>/dev/null)
    if [[ -n "$local_video" && -f "$local_video" ]]; then
        set_animated_wallpaper "$local_video"
    fi
fi

# Écouter les changements de workspace
echo "Écoute des événements..." >> "$LOG_FILE"
SOCKET_PATH="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
socat -u "UNIX-CONNECT:$SOCKET_PATH" - | while read -r line; do
    if [[ $line == "workspace>>"* ]]; then
        workspace_id=$(echo "$line" | sed 's/workspace>>//')
        set_wallpaper_for_workspace "$workspace_id"
    fi
done
