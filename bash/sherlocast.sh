#!/bin/bash

###################################################################
#Script Name: sherlocast.sh
#Description: Creación de un feed de podcast a partir de una lista
#             de canales de Youtube y Twitch
#Args: N/A
#Creation/Update: 20250221/20250221
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

PATH="/home/pi/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Número de vídeos a comprobar de cada canal
num_videos=5

# Número de vídeos máximo a descargar en total
num_max_descargas=2
num_descargas=0

# Carpeta para guardar los archivos y comprobación de su existencia
sherlocast_dir="$HOME/sherlocast"

################################
####      Dependencias      ####
################################



################################
####       Funciones        ####
################################

# Función para detectar si es una URL de Twitch
is_twitch_url() {
    local url="$1"
    if [[ $url == *"twitch.tv"* ]]; then
        return 0
    else
        return 1
    fi
}

# Función para obtener IDs de los últimos 5 videos
get_latest_video_ids() {
    local channel_url="$1"
    local temp_file=$(mktemp)
    
    if is_twitch_url "$channel_url"; then
        # Para Twitch, limitamos a los últimos 5 videos
        yt-dlp --flat-playlist --playlist-items 1-5 --get-id "$channel_url" > "$temp_file" 2>/dev/null
    else
        # Para YouTube, limitamos a los últimos 5 videos
        yt-dlp --flat-playlist --playlist-end 5 --get-id "$channel_url" > "$temp_file" 2>/dev/null
    fi
    
    cat "$temp_file"
    rm "$temp_file"
}

################################
####    Script principal    ####
################################


