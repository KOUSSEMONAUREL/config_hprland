#!/usr/bin/env python3
import subprocess
import sys
import os
import time
import re

# Log file for debugging
LOG_FILE = "/tmp/waybar_wifi.log"

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}\n")

def run_cmd(cmd_list):
    """Run command safely without shell=True"""
    try:
        log(f"Running: {' '.join(cmd_list)}")
        result = subprocess.run(cmd_list, capture_output=True, text=True, timeout=20)
        if result.returncode != 0:
            log(f"Error ({result.returncode}): {result.stderr.strip()}")
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except Exception as e:
        log(f"Exception: {str(e)}")
        return "", str(e), 1

def notify(title, message):
    log(f"Notify: {title} - {message}")
    subprocess.run(["notify-send", title, message])

def rofi_menu(options, prompt="Network"):
    option_str = "\n".join(options)
    try:
        # Use Popen to pipe options to rofi
        proc = subprocess.Popen(["rofi", "-dmenu", "-p", prompt, "-i"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        stdout, _ = proc.communicate(input=option_str)
        return stdout.strip() if proc.returncode == 0 else None
    except:
        return None

def rofi_password(prompt="Password"):
    try:
        proc = subprocess.Popen(["rofi", "-dmenu", "-p", prompt, "-password", "-lines", "0"], stdout=subprocess.PIPE, text=True)
        stdout, _ = proc.communicate()
        return stdout.strip() if proc.returncode == 0 else None
    except:
        return None

def get_active_ssid():
    stdout, _, _ = run_cmd(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"])
    for line in stdout.split('\n'):
        if '802-11-wireless' in line:
            return line.split(':')[0]
    return None

def list_wifi_networks():
    # Background rescan
    subprocess.Popen(["nmcli", "device", "wifi", "rescan"])
    time.sleep(1)
    
    stdout, _, _ = run_cmd(["nmcli", "-t", "-f", "SSID,BARS,SECURITY,IN-USE", "device", "wifi", "list"])
    networks = []
    seen = set()
    
    for line in stdout.split('\n'):
        if not line: continue
        parts = re.split(r'(?<!\\):', line) # Split by colon not preceded by backslash
        if len(parts) >= 4:
            ssid = parts[0].replace('\\:', ':')
            bars = parts[1]
            security = parts[2]
            in_use = parts[3]
            
            if not ssid or ssid in seen: continue
            seen.add(ssid)
            
            display = f"{ssid} ({bars}) {security}"
            if in_use == "*":
                display = f"<b>{ssid}</b> <span color='green'>(Connected)</span>"
            
            networks.append({'ssid': ssid, 'display': display, 'security': security})
    return networks

def connect(ssid, security):
    notify("Wi-Fi", f"Tentative: {ssid}")
    
    # 1. Try connecting with existing profile
    _, stderr, code = run_cmd(["nmcli", "connection", "up", "id", ssid])
    if code == 0:
        notify("Wi-Fi", f"Connecté à {ssid}")
        return True
    
    # 2. Ask for password if connection up failed
    password = rofi_password(f"Password for {ssid}")
    if password is None: return False
    
    # 3. Use 'device wifi connect' which is more robust for creating/updating profiles
    cmd = ["nmcli", "device", "wifi", "connect", ssid]
    if password:
        cmd += ["password", password]
    
    stdout, stderr, code = run_cmd(cmd)
    
    if code == 0:
        notify("Wi-Fi", f"Connecté à {ssid}")
        return True
    
    # 4. Fallback for HUAWEI/Property issues
    if "property is missing" in stderr or "secrets" in stderr.lower():
        notify("Wi-Fi", "Mode secours: Forçage WPA2...")
        run_cmd(["nmcli", "connection", "delete", "id", ssid])
        
        # Add manually
        run_cmd(["nmcli", "connection", "add", "type", "wifi", "con-name", ssid, "ifname", "wlan0", "ssid", ssid])
        if password:
            run_cmd(["nmcli", "connection", "modify", ssid, "wifi-sec.key-mgmt", "wpa-psk", "wifi-sec.psk", password])
        
        _, stderr, code = run_cmd(["nmcli", "connection", "up", "id", ssid])
        if code == 0:
            notify("Wi-Fi", f"Connecté à {ssid} (Mode manuel)")
            return True

    notify("Wi-Fi", f"Échec: {stderr or 'Erreur inconnue'}")
    return False

def main():
    log("--- Waybar Network Menu Started ---")
    active = get_active_ssid()
    networks = list_wifi_networks()
    
    wifi_on, _, _ = run_cmd(["nmcli", "radio", "wifi"])
    wifi_on = wifi_on.strip() == "enabled"
    
    options = []
    options.append("OFF: Disable Wi-Fi" if wifi_on else "ON: Enable Wi-Fi")
    if active:
        options.append(f"DISCONNECT: {active}")
    
    options.append("--- Networks ---")
    for n in networks:
        options.append(n['display'])
        
    selected = rofi_menu(options)
    if not selected: return

    if "Disable Wi-Fi" in selected:
        run_cmd(["nmcli", "radio", "wifi", "off"])
        notify("Wi-Fi", "Désactivé")
    elif "Enable Wi-Fi" in selected:
        run_cmd(["nmcli", "radio", "wifi", "on"])
        notify("Wi-Fi", "Activé")
    elif selected.startswith("DISCONNECT:"):
        run_cmd(["nmcli", "connection", "down", "id", active])
        notify("Wi-Fi", f"Déconnecté de {active}")
    elif selected == "--- Networks ---":
        pass
    else:
        # Match selection to ssid
        # Selection might contain HTML tags or just ssid
        target = None
        for n in networks:
            if n['display'] == selected:
                target = n
                break
        
        if target:
            connect(target['ssid'], target['security'])

if __name__ == "__main__":
    main()
