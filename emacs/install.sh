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

mkdir -p "$TARGET_DIR"

for file in init.el early-init.el; do
    SRC="$SOURCE_DIR/$file"
    DST="$TARGET_DIR/$file"

    if [[ -f "$SRC" ]]; then
        ln -snf "$SRC" "$DST"
        echo "Enlace creado: $DST -> $SRC"
    else
        echo "No existe: $SRC"
    fi
done

emacs &
