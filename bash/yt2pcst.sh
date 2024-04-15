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
DESCARGADOS="$yt2pcst_dir/descargados.txt"


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

buscar_ultimos(){
    # Valores de argumentos
    local nombre=${1:?Falta el nombre del canal}
    local url=${2:?Falta el nombre del canal}
    local videos
    local id
    local duracion

    # Obtiene el json de los ultimos vídeos.
    mensaje+=$'Obteniendo últimos vídeos . . . . . . . . . . . . .'
    echo "- Buscando últimos vídeos de $nombre en $url"

    mapfile -t videos < <( yt-dlp --flat-playlist --print "%(id)s/%(duration)s" --playlist-end 2 $url )

    comprobar $?


    for video in ${videos[@]}
    do
	id=$( echo "$video" |cut -d\/ -f1 )
	duracion=$( echo "$video" |cut -d\/ -f2 )
	duracion=${duracion%??}

	# Comprueba si el archivo es de más de 10'
	if (( $duracion > 600 )) && ! grep -q $id "$DESCARGADOS"; then
	    # Descargando el episodio
	    descargar_video $id
	    comprobar $?

	    echo "- Taggeando el vídeo $id"
	    mensaje+=$"Taggeando vídeo $id . . . . . . "
	    tag $id $nombre
	    comprobar $?
	else
	    echo "- El episodio $id es corto o ya descargado"
	fi
	
    done
}

#----------------------------------------------------------#
#       Descargar un vídeo de Youtube a partir del ID      #
#----------------------------------------------------------#
descargar_video(){
    local id=${1:?Falta el id del video}
    local url="https://www.youtube.com/watch?v=$id"

    yt-dlp -o "%(id)s.%(ext)s" --extract-audio --audio-format mp3 $url

    if [ $? -eq 0 ]; then
	# Añadiendo el episodio descargado a la lista
	echo -e "- Añadiendo a la lista de episodios descargados"
	echo $id | cat - $DESCARGADOS > temp && mv temp $DESCARGADOS
    fi
}

#----------------------------------------------------------#
#        Añadir info al archivo de audio de Youtube        #
#----------------------------------------------------------#
tag(){
    local id=${1:?Falta el id del archivo}
    local artista=${2:?Falta el nombre del artista}
    local titulo=$(yt-dlp --get-title "https://www.youtube.com/watch?v=$id")

    echo -e "- Taggeando y moviendo el audio."

    # Poniendo título al audio
    id3v2 -t "$titulo" -a "$CANAL_NOMBRE" -A "Youtube2Podcast" -- "$id.mp3"

    # Añadir el item al listado del feed
    anadir_item "$id.mp3"

    # Mover a la carpeta mp3
    mv -- "$id.mp3" mp3
}

#----------------------------------------------------------#
#                   Añadir un nuevo item                   #
#----------------------------------------------------------#
anadir_item(){
    echo "- Añadiendo elemento a la lista..."
    local file=${1:?Falta el nombre del archivo}
    
    #local ID_EP="${track%.*}"
    local ID_EP=$id
    
    local TIT_EP=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 -- $file)
    local ART_EP=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 -- $file)

    local URL_VID
    local FEC_EP

    URL_VID="https://www.youtube.com/watch?v=$ID_EP"
    FEC_EP=$(yt-dlp --print "%(upload_date)s" $URL_VID)
    FEC_EP=$(date -d $FEC_EP +"%Y-%m-%dT%H:%M:%S%:z")
    FEC_EP=$(date --date "$FEC_EP+14 hours" "+%a, %d %b %Y %T %Z")

    local LEN_EP=$(ffprobe -i $file -show_format -v quiet | sed -n 's/duration=//p')
    LEN_EP=$(echo ${LEN_EP%.*})

    # crea el "item.xml" con info del episodio
    cat >> item.xml <<END_ITEM
    <item>
      <guid isPermaLink="true">$servidor/$canal/$ID_EP</guid>
      <title>$TIT_EP</title>
      <link>$URL_EP</link>
      <description>$TIT_EP</description>
      <pubDate>$FEC_EP</pubDate>
      <author>$ART_EP</author>
      <content:encoded><![CDATA[<p>Episodio descargado de $servicio.</p>]]></content:encoded>
      <enclosure length="$LEN_EP" type="audio/mpeg" url="$SERVIDOR/twitch/$canal/mp3/$ID_EP.mp3"/>
    </item>
END_ITEM

    # Añade los "items.xml" ya descargado a continuación del "item.xml"
    cat items.xml >> item.xml
    mv item.xml items.xml
}

################################
####    Script principal    ####
################################

cd $yt2pcst_dir

# Comprobar dependencias
#dependencias

# Leer nombres y URLs de los canales de YouTube desde el archivo de texto
while IFS= read -r linea; do
    nombre=$(echo "$linea" | cut -d ',' -f 1)
    url=$(echo "$linea" | cut -d ',' -f 2)
    #echo "Nombre del canal: $nombre"
    #echo "URL del canal: $url"
    buscar_ultimos "$nombre" "$url"
done < "$archivo_canales"
