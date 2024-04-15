#!/bin/bash

###################################################################
#Script Name: yt2pcst.sh
#Description: Generación de un poscast a partir de canales de youtube
#Args: N/A
#Creation/Update: 20240411/20240415
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

# Carpeta para guardar los archivos
yt2pcst_dir="$HOME/yt2pcst"

# Ruta al archivo de canales
archivo_canales="$yt2pcst_dir/canales.txt"

# Episodios ya descargados
DESCARGADOS="$yt2pcst_dir/descargados_yt.txt"


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
    local nombre=${1:?Falta el nombre del canal}
    local url=${2:?Falta el nombre del canal}
    local videos
    local id
    local duracion

    # Obtiene el json de los ultimos vídeos.
    mensaje+=$'Obteniendo últimos vídeos . . . . . . . . . . . . .'
    echo "- Buscando últimos vídeos de $nombre en $url"

    mapfile -t videos < <( yt-dlp --flat-playlist --print "%(id)s/%(duration)s" --playlist-end 10 $CANAL_YT )

    comprobar $?


    for video in ${videos[@]}
    do
	id=$( echo "$video" |cut -d\/ -f1 )
	duracion=$( echo "$video" |cut -d\/ -f2 )
	duracion=${duracion%??}

	# Comprueba si el archivo es de más de 10'
	if (( $duracion > 600 )) && ! grep -q $id "$DESCARGADOS"; then
	    # Descargando el episodio
	    descargar_video_yt $id
	    comprobar $?
	else
	    echo "- El episodio $id es corto o ya descargado"
	fi
	
    done
}

################################
####    Script principal    ####
################################

# Comprobar dependencias
#dependencias

# Leer nombres y URLs de los canales de YouTube desde el archivo de texto
while IFS= read -r linea; do
    nombre=$(echo "$linea" | cut -d ',' -f 1)
    url=$(echo "$linea" | cut -d ',' -f 2)
    #echo "Nombre del canal: $nombre"
    #echo "URL del canal: $url"
    buscar_ultimos_yt "$nombre" "$url"
done < "$archivo_canales"
