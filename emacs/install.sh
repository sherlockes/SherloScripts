#!/bin/bash

###################################################################
# Script Name: INSTALL.SH
# Description: Crea enlaces simbólicos para init.el y early-init.el
# Args: N/A
# Creation/Update: 20260426/20260426
# Author: www.sherblog.es
# Email: sherlockes@gmail.com
###################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.emacs.d"
TARGET_DIR="$HOME/.emacs.d"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: No existe $SOURCE_DIR"
    exit 1
fi

echo "Origen:  $SOURCE_DIR"
echo "Destino: $TARGET_DIR"

# Si ~/.emacs.d es un enlace simbólico, lo elimina
if [[ -L "$TARGET_DIR" ]]; then
    echo "Eliminando enlace existente: $TARGET_DIR"
    rm "$TARGET_DIR"

# Si ~/.emacs.d es una carpeta real, la guarda como backup
elif [[ -d "$TARGET_DIR" ]]; then
    BACKUP_DIR="$HOME/.emacs.d.backup.$(date +%Y%m%d-%H%M%S)"
    echo "Moviendo carpeta existente a: $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"

# Si existe como archivo raro, lo guarda también
elif [[ -e "$TARGET_DIR" ]]; then
    BACKUP_FILE="$HOME/.emacs.d.backup.$(date +%Y%m%d-%H%M%S)"
    echo "Moviendo archivo existente a: $BACKUP_FILE"
    mv "$TARGET_DIR" "$BACKUP_FILE"
fi

# Crea el enlace simbólico completo
ln -s "$SOURCE_DIR" "$TARGET_DIR"

echo "Enlace creado:"
echo "$TARGET_DIR -> $SOURCE_DIR"

echo "Arrancando Emacs..."

emacs &
