#!/bin/bash

###################################################################
# Script Name: Radares
# Description: Descarga de radares y copia a Google Drive
# Creation/Update: 20191112/20250306
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
###################################################################

# ----------------------------------
# Definición de variables
# ----------------------------------
carpeta=~/radares
log_telegram=""

# Cargar script de notificaciones a Telegram
source ~/SherloScripts/bash/telegram_V2.sh

# ----------------------------------
# Función para comprobar ejecución
# ----------------------------------
comprobar(){
    "$1"  # Ejecuta la función pasada como argumento
    if [ $? -eq 0 ]; then
        log_telegram+="✅ $1: OK\n"
    else
        log_telegram+="❌ $1: ERROR\n"
        tele_msg_resul "KO"
        exit 1
    fi
}

# ----------------------------------
# Crear carpeta local
# ----------------------------------
[ -d "$carpeta" ] && rm -rf "$carpeta"/*
mkdir -p "$carpeta"

download(){
    tele_msg_instr "Downloading files"
    curl -L "https://www.todo-poi.es/radar/GARMIN_RADARES/garminvelocidad%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip" -o "$carpeta/radares_1.zip"
    curl -L "https://www.todo-poi.es/radar/GARMIN_RADARES/garmintipo%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip" -o "$carpeta/radares_2.zip"
}

unzip_all(){
    tele_msg_instr "Unzipping files"
    unzip -o -j "$carpeta"/*.zip -d "$carpeta"
    find "$carpeta" -type f ! -name "*.csv" -delete
}

join(){
    tele_msg_instr "Joining files"
    find "$carpeta" -type f \( -name "*[0-9].csv" -o -name "*variable.csv" \) -delete
    cat "$carpeta"/*_tramo*.csv "$carpeta"/*_tunel*.csv > "$carpeta/R_BBS_tramo.csv"
    find "$carpeta" -type f \( -name "*_tramo_*.csv" -o -name "*_tunel*.csv" \) -delete
    cat "$carpeta/R_BBS_curvas_peligrosas.csv" "$carpeta/R_BBS_puntos_negros.csv" > "$carpeta/03_cajas.csv"
    rm -f "$carpeta/R_BBS_curvas_peligrosas.csv" "$carpeta/R_BBS_puntos_negros.csv" "$carpeta/R_BBS_Alcoholemia.csv"
}

rename(){
    tele_msg_instr "Renaming files"
    declare -A renames=(
        ["R_BBS_fijos_total.csv"]="01_fijos.csv"
        ["R_BBS_camu_total.csv"]="02_moviles.csv"
        ["R_BBS_Foto.csv"]="04_camaras.csv"
        ["R_BBS_tramo.csv"]="05_tramo.csv"
        ["R_BBS_semaforos.csv"]="06_semaforos.csv"
        ["R_BBS_APR.csv"]="07_restringido.csv"
    )
    for old in "${!renames[@]}"; do
        [ -f "$carpeta/$old" ] && mv "$carpeta/$old" "$carpeta/${renames[$old]}"
    done
}

sync(){
    tele_msg_instr "Syncing files"
    rclone sync "$carpeta" Sherlockes78_GD:radares
}

clear(){
    tele_msg_instr "Clearing files"
    rm -rf "$carpeta"
}

#### Script principal ####
comprobar download
comprobar unzip_all
comprobar join
comprobar rename
comprobar sync
comprobar clear

# Enviar mensaje final con el resultado del script a Telegram
tele_msg_resul "$log_telegram"
tele_end
