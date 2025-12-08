#!/usr/bin/env python3
import os
import shutil
import subprocess
import random

# Config
RESOLUTION = "1080p"
ICON_THEME = "color"
GRUB_THEMES_DIR = "/boot/grub/themes/"
LINK_NAME = "dedsec-random"
LINK_PATH = os.path.join(GRUB_THEMES_DIR, LINK_NAME)

styles = {
    "compact": "compact",
    "hackerden": "hackerden",
    "legion": "legion",
    "unite": "unite",
    "wrench": "wrench",
    "brainwash": "brainwash",
    "firewall": "firewall",
    "lovetrap": "lovetrap",
    "redskull": "redskull",
    "spam": "spam",
    "spyware": "spyware",
    "strike": "strike",
    "wannaCry": "wannaCry",
    "tremor": "tremor",
    "stalker": "stalker",
    "mashup": "mashup",
    "fuckery": "fuckery",
    "reaper": "reaper",
    "comments": "comments",
    "sitedown": "sitedown",
    "trolls": "trolls",
}

def check_root():
    if os.geteuid() != 0:
        print("Please run as root (sudo).")
        exit(1)

def install_themes():
    print(f"Installing all themes for {RESOLUTION}...")
    if not os.path.exists(GRUB_THEMES_DIR):
        os.makedirs(GRUB_THEMES_DIR)

    for style_code, style_name in styles.items():
        theme_dir = os.path.join(GRUB_THEMES_DIR, f"dedsec-{style_name}")
        # print(f"  - Installing {style_name} to {theme_dir}...")
        
        if os.path.exists(theme_dir):
            shutil.rmtree(theme_dir)
        os.makedirs(theme_dir)

        # Assets paths (relative to where script is run, inside dedsec-theme dir)
        bg_path = f"assets/backgrounds/{style_name.lower()}-{RESOLUTION}.png"
        icons_path = f"assets/icons-{RESOLUTION}/{ICON_THEME}/"
        fonts_path = f"assets/fonts/{RESOLUTION}/"
        base_path = f"base/{RESOLUTION}/"

        shutil.copy(bg_path, os.path.join(theme_dir, "background.png"))
        shutil.copytree(icons_path, os.path.join(theme_dir, "icons"))
        shutil.copytree(fonts_path, theme_dir, dirs_exist_ok=True)
        shutil.copytree(base_path, theme_dir, dirs_exist_ok=True)

    print("All themes installed.")

def setup_initial_theme():
    print("Setting up initial theme directory (Copying because FAT32 usually doesn't support symlinks)...")
    first_style = random.choice(list(styles.values()))
    target = os.path.join(GRUB_THEMES_DIR, f"dedsec-{first_style}")
    
    # Remove if exists (it might be a broken symlink from previous run or a dir)
    if os.path.islink(LINK_PATH):
        os.unlink(LINK_PATH)
    elif os.path.exists(LINK_PATH):
        shutil.rmtree(LINK_PATH)
            
    shutil.copytree(target, LINK_PATH)
    print(f"Current theme directory created from: {target}")

def install_rotator_script():
    print("Installing rotator script...")
    script_content = f'''#!/bin/bash
# Select a random dedsec theme folder
THEMES_DIR="{GRUB_THEMES_DIR}"
LINK_NAME="{LINK_NAME}"
LINK_PATH="{LINK_PATH}"

# Find all dedsec-* folders (excluding the target dir itself and other themes)
# We assume folders are named dedsec-*
THEMES=($(find "$THEMES_DIR" -maxdepth 1 -type d -name "dedsec-*" ! -name "$LINK_NAME"))

if [ ${{#THEMES[@]}} -eq 0 ]; then
    echo "No themes found."
    exit 1
fi

# Pick random index
RANDOM_INDEX=$((RANDOM % ${{#THEMES[@]}}))
SELECTED="${{THEMES[$RANDOM_INDEX]}}"

echo "Rotating GRUB theme to: $(basename "$SELECTED")"

# Remove old content
rm -rf "$LINK_PATH"
# Copy new content
cp -r "$SELECTED" "$LINK_PATH"
'''
    rotator_path = "/usr/local/bin/grub-theme-rotator"
    with open(rotator_path, "w") as f:
        f.write(script_content)
    os.chmod(rotator_path, 0o755)
    print(f"Rotator script installed to {rotator_path}")

def install_service():
    print("Installing systemd service...")
    service_content = '''[Unit]
Description=Rotate GRUB Theme on Boot
Before=shutdown.target reboot.target halt.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/grub-theme-rotator

[Install]
WantedBy=multi-user.target
'''
    service_path = "/etc/systemd/system/grub-theme-rotator.service"
    with open(service_path, "w") as f:
        f.write(service_content)
    
    # Reload daemon and enable
    subprocess.run("systemctl daemon-reload", shell=True, check=True)
    subprocess.run("systemctl enable grub-theme-rotator.service", shell=True, check=True)
    print("Service installed and enabled.")

def update_grub_config():
    print("Updating /etc/default/grub...")
    grub_file_path = "/etc/default/grub"
    theme_setting = f'GRUB_THEME="{LINK_PATH}/theme.txt"'
    
    with open(grub_file_path, "r") as f:
        lines = f.readlines()
    
    new_lines = []
    found = False
    for line in lines:
        if line.strip().startswith("GRUB_THEME="):
            new_lines.append(f'{theme_setting}\n')
            found = True
        else:
            new_lines.append(line)
    
    if not found:
        new_lines.append(f'{theme_setting}\n')
    
    with open(grub_file_path, "w") as f:
        f.writelines(new_lines)
    
    print("Running grub-mkconfig...")
    subprocess.run("grub-mkconfig -o /boot/grub/grub.cfg", shell=True, check=True)

if __name__ == "__main__":
    check_root()
    install_themes()
    setup_initial_theme()
    install_rotator_script()
    install_service()
    update_grub_config()
    print("\nSUCCESS! Random theme configured.")
