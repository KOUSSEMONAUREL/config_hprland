#!/usr/bin/env python3
import subprocess
import sys

def run_command(command):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.DEVNULL)
        return output.decode('utf-8').strip()
    except:
        return ""

def rofi_menu(options, prompt="Bluetooth"):
    option_str = "\n".join(options)
    command = f"echo -e '{option_str}' | rofi -dmenu -p '{prompt}' -i"
    try:
        output = subprocess.check_output(command, shell=True)
        return output.decode('utf-8').strip()
    except:
        return None

def notify(title, message):
    subprocess.run(f"notify-send '{title}' '{message}'", shell=True)

def get_devices():
    devices_output = run_command("bluetoothctl devices")
    paired_output = run_command("bluetoothctl paired-devices")
    
    devices = []
    if devices_output:
        for line in devices_output.split('\n'):
            parts = line.split(' ', 2)
            if len(parts) >= 3:
                mac = parts[1]
                name = parts[2]
                
                # Simple check for connection/pairing
                is_paired = mac in paired_output
                info = run_command(f"bluetoothctl info {mac}")
                is_connected = "Connected: yes" in info
                
                status = ""
                if is_connected:
                    status = "<span color='green'>(Connected)</span>"
                elif is_paired:
                    status = "<span color='blue'>(Paired)</span>"
                
                display = f"{name} <span color='gray'>{mac}</span> {status}"
                devices.append({'display': display, 'mac': mac, 'connected': is_connected, 'paired': is_paired})
    return devices

def main():
    # Simple state check
    show_out = run_command("bluetoothctl show")
    is_on = "Powered: yes" in show_out
    
    menu_options = []
    
    # Always show basic controls as requested
    menu_options.append("ENABLE Bluetooth")
    menu_options.append("DISABLE Bluetooth")
    menu_options.append("SCAN for devices")
    
    devices = get_devices()
    if devices:
        menu_options.append("--- Devices ---")
        for dev in devices:
            menu_options.append(dev['display'])
            
    selected = rofi_menu(menu_options)
    
    if not selected:
        return

    if selected == "ENABLE Bluetooth":
        run_command("bluetoothctl power on")
        notify("Bluetooth", "Attempting to enable...")
    elif selected == "DISABLE Bluetooth":
        run_command("bluetoothctl power off")
        notify("Bluetooth", "Bluetooth disabled")
    elif selected == "SCAN for devices":
        notify("Bluetooth", "Scanning for 10 seconds...")
        subprocess.Popen("bluetoothctl scan on", shell=True)
        import time
        time.sleep(10)
        run_command("bluetoothctl scan off")
        notify("Bluetooth", "Scan complete")
    elif selected == "--- Devices ---":
        pass
    else:
        # Device action
        target_dev = None
        for dev in devices:
            if dev['display'] == selected:
                target_dev = dev
                break
        
        if target_dev:
            actions = ["Connect", "Disconnect", "Pair", "Remove/Unpair"]
            action = rofi_menu(actions, prompt=f"Device: {target_dev['mac']}")
            
            if action == "Connect":
                run_command(f"bluetoothctl connect {target_dev['mac']}")
                notify("Bluetooth", f"Connecting to {target_dev['mac']}")
            elif action == "Disconnect":
                run_command(f"bluetoothctl disconnect {target_dev['mac']}")
                notify("Bluetooth", f"Disconnected {target_dev['mac']}")
            elif action == "Pair":
                run_command(f"bluetoothctl pair {target_dev['mac']}")
                notify("Bluetooth", f"Pairing with {target_dev['mac']}")
            elif action == "Remove/Unpair":
                run_command(f"bluetoothctl remove {target_dev['mac']}")
                notify("Bluetooth", f"Removed {target_dev['mac']}")

if __name__ == "__main__":
    main()
