# Patch pour Elan Microelectronics Corp. fingerprint reader (04f3:0c8e)

Ce dossier contient les fichiers sources modifiés pour faire fonctionner le lecteur d'empreintes Elan 0c8e sous Linux.

## Fichiers modifiés

- `elanmoc2.h`:
    - Ajout de l'ID device `0x0c8e`.
    - Augmentation de `ELANMOC2_CMD_MAX_LEN` à 16.
    - Modification de `cmd_identify` pour envoyer 4 bytes (avec l'index 0).
    - Modification des `in_len` pour éviter les erreurs "Device sent more data".

- `elanmoc2.c`:
    - Ajout du saut vers `ENROLL_WIPE_SENSOR` au début de l'enrollment.
    - Fix du byte `0x02` fixe dans la commande enroll.
    - Fix de la gestion des erreurs d'index.

## Installation manuelle

Pour utiliser ces fichiers :
1. Cloner le repo `libfprint` ou `libfprint-elanmoc2`.
2. Remplacer les fichiers dans `libfprint/drivers/elanmoc2/`.
3. Compiler avec `meson`.
4. Installer la librairie.

Un script d'installation automatique est fourni à la racine de ce dépôt : `scripts/install_fingerprint.sh`.
