#!/bin/bash

###################################################################
#Script Name: ctx.sh
#Description: Lanzador para el generador de contexto
#Args: N/A
#Creation/Update: 20260408/20260408
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

REMOTE_URL="https://raw.githubusercontent.com/sherlockes/SherloScripts/refs/heads/master/bash/context-engine.sh"

if command -v curl >/dev/null 2>&1; then
    curl -sSL "$REMOTE_URL" | bash
elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$REMOTE_URL" | bash
else
    echo "Error: Se requiere curl o wget para ejecutar este script."
    exit 1
fi
