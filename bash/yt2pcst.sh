#!/bin/bash

###################################################################
#Script Name: yt2pcst.sh
#Description: Generación de un poscast a partir de canales de youtube
#Args: N/A
#Creation/Update: 20240411/20240411
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################


# Ruta al archivo de canales
archivo_canales="$HOME/yt2pcst/canales.txt"


################################
####      Dependencias      ####
################################

dependencias(){
    # yt-dlp
    if command -v yt-dlp >/dev/null 2>&1 ; then
	echo "Versión de yt-dlp: $(yt-dlp --version)"
	sudo yt-dlp -U
    else
	echo "ATENCION: yt-dlp no está disponible"
	sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
	sudo chmod a+rx /usr/local/bin/yt-dlp
    fi

    # id3v2
    if command -v id3v2 >/dev/null 2>&1 ; then
	echo "Versión de id3v2: $(id3v2 --version | head -n 1)"
    else
	echo "ATENCION: id3v2 no está disponible"
    fi

    # ffmpeg
    if command -v ffmpeg >/dev/null 2>&1 ; then
	echo "Versión de ffmpeg: $(ffmpeg -version | grep 'ffmpeg version' | sed 's/ffmpeg version \([-0-9.]*\).*/\1/')"
    else
	echo "ATENCION: ffmpeg no está disponible"
    fi
}


################################
####       Funciones        ####
################################

#----------------------------------------------------------#
#                   Comprobar la salida                    #
#----------------------------------------------------------#
comprobar(){

    if [ $1 -eq 0 ]; then
	mensaje+=$'OK'
    else
	mensaje+=$'ERROR'
    fi
    mensaje+=$'\n'
}

#----------------------------------------------------------#
#   Buscar los últimos vídeos de un canal no descargados   #
#----------------------------------------------------------#

buscar_ultimos_yt(){
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    local videos
    local id
    local duracion

    # Obtiene el json de los ultimos vídeos.
    mensaje+=$'Obteniendo últimos vídeos . . . . . . . . . . . . .'
    echo "- Buscando últimos vídeos de $canal"
}

################################
####    Script principal    ####
################################

# Comprobar dependencias
dependencias

# Leer nombres y URLs de los canales de YouTube desde el archivo de texto
while IFS= read -r linea; do
    nombre=$(echo "$linea" | cut -d ',' -f 1)
    url=$(echo "$linea" | cut -d ',' -f 2)
    #echo "Nombre del canal: $nombre"
    #echo "URL del canal: $url"
    buscar_ultimos_yt $nombre
done < "$archivo_canales"
