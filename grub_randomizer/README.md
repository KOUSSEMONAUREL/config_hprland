# GRUB DedSec Theme Randomizer

Ce dossier contient les scripts pour installer et configurer un thème GRUB "DedSec" aléatoire à chaque démarrage.

## Contenu
*   `install_randomizer.py` : Script principal d'installation (Python). Adapté pour FAT32.
*   `grub-theme-rotator` : Script shell utilisé par systemd pour changer le thème.
*   `grub-theme-rotator.service` : Service systemd pour l'automatisation.

## Installation / Restauration

Ces scripts ne contiennent PAS les images du thème (trop lourdes).

1.  Clonez le thème complet :
    ```bash
    git clone https://github.com/KOUSSEMONAUREL/dedsec-grub2-theme.git ~/dedsec-theme
    ```
    *(Ou utilisez le dépôt officiel `VandalByte/dedsec-grub2-theme`)*

2.  Copiez le script d'installation dedans :
    ```bash
    cp install_randomizer.py ~/dedsec-theme/
    ```

3.  Lancez l'installation :
    ```bash
    cd ~/dedsec-theme
    sudo python3 install_randomizer.py
    ```

Cela réinstallera tout (thèmes, service, config GRUB).
