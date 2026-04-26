#!/bin/bash

###################################################################
# Script Name: INSTALL.SH
# Description: Crea enlaces simbólicos para init.el y early-init.el
# Args: N/A
# Creation/Update: 20260426/20260426
# Author: www.sherblog.es
# Email: sherlockes@gmail.com
###################################################################

#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.emacs.d"
TARGET_DIR="$HOME/.emacs.d"

if [[ ! -f "$SOURCE_DIR/init.el" ]]; then
    echo "ERROR: No existe $SOURCE_DIR/init.el"
    exit 1
fi

if [[ ! -f "$SOURCE_DIR/early-init.el" ]]; then
    echo "ERROR: No existe $SOURCE_DIR/early-init.el"
    exit 1
fi

if [[ -e "$TARGET_DIR" || -L "$TARGET_DIR" ]]; then
    BACKUP_DIR="$HOME/.emacs.d.backup.$(date +%Y%m%d-%H%M%S)"
    echo "Creando copia de seguridad: $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
fi

mkdir -p "$TARGET_DIR"

ln -s "$SOURCE_DIR/init.el" "$TARGET_DIR/init.el"
ln -s "$SOURCE_DIR/early-init.el" "$TARGET_DIR/early-init.el"

echo "Enlace creado: $TARGET_DIR/init.el -> $SOURCE_DIR/init.el"
echo "Enlace creado: $TARGET_DIR/early-init.el -> $SOURCE_DIR/early-init.el"

echo "Arrancando Emacs..."
emacs &
