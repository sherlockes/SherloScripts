#!/bin/bash

###################################################################
#Script Name: youtube2podcast.sh
#Description: Creación de un podcast a partir de un canal de youtube
#Args: N/A
#Creation/Update: 20220605/20230511
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

PATH="/home/pi/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

CANAL="jordillatzer"
CANAL_NOMBRE="Jordi Llatzer"
TITULO="Jordi Llatzer en Twitch"
SERVIDOR="http://192.168.10.202:5005"
CANAL_YT="https://www.youtube.com/@jordillatzer/videos"

twitch_dir=~/twitch
DESCARGADOS="$twitch_dir/$CANAL/descargados_yt.txt"

notificacion=~/SherloScripts/bash/telegram.sh
inicio=$( date +%s )

mensaje=$'Actualizar Youtube via <a href="https://raw.githubusercontent.com/sherlockes/SherloScripts/master/bash/youtube2podcast.sh">youtube2podcast.sh</a>\n'
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'


echo "######################################"
echo "## Youtube to Podcast by Sherlockes ##"
echo "######################################"

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
    echo "- Buscando últimos vídeos de $CANAL_NOMBRE"

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

descargar_video_yt(){
    local id=${1:?Falta el id del video}
    local url="https://www.youtube.com/watch?v=$id"
    
    echo "- Descargando el vídeo $id"
    mensaje+=$"Descargando vídeo $id . . . . . . "
    yt-dlp -o "%(id)s.%(ext)s" --extract-audio --audio-format mp3 $url

    if [ $? -eq 0 ]; then
	# Añadiendo el episodio descargado a la lista
	echo -e "- Añadiendo a la lista de episodios descargados"
	echo $id | cat - $DESCARGADOS > temp && mv temp $DESCARGADOS
    fi
}

tag_y_mover(){
    cd $twitch_dir

    echo -e "- Taggeando y moviendo los archivos"

    # Lista todos los mp3 de la carpeta
    for track in *.mp3 ; do
	local nombre="${track%.*}"
	local titulo=$(yt-dlp --get-title "https://www.youtube.com/watch?v=$nombre")

	# Poniendo título al audio
	id3v2 -t "$titulo" -a "$CANAL_NOMBRE" -A "Youtube2Podcast" $track

	# Añadir el item al listado del feed
	anadir_item $track "youtube" "$CANAL"

	# Mover a la carpeta mp3
	mv $track $CANAL/mp3
    done
}

#----------------------------------------------------------#
#                   Añadir un nuevo item                   #
#----------------------------------------------------------#
anadir_item(){
    echo "- Añadiendo elemento a la lista..."
    local file=${1:?Falta el nombre del archivo}
    local servicio=${2:?Falta el servicio de descarga}
    local canal=${3:?Falta el canal de descarga}
    
    local ID_EP="${track%.*}"
    
    local TIT_EP=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 $file)
    local ART_EP=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 $file)

    local URL_VID
    local FEC_EP

    if [ "$servicio" = "youtube" ]; then
	# Personalización para Youtube
	URL_VID="https://www.youtube.com/watch?v=$ID_EP"
	FEC_EP=$(yt-dlp --print "%(upload_date)s" $URL_VID)
	FEC_EP=$(date -d $FEC_EP +"%Y-%m-%dT%H:%M:%S%:z")
	FEC_EP=$(date --date "$FEC_EP+14 hours" "+%a, %d %b %Y %T %Z")
    else
	# Personalización para Twitch
	URL_VID="https://www.twitch.tv/videos/$ID_EP"
    fi

    local LEN_EP=$(ffprobe -i $file -show_format -v quiet | sed -n 's/duration=//p')
    LEN_EP=$(echo ${LEN_EP%.*})

    # crea el "item.xml" con info del episodio
    cat >> $canal/item.xml <<END_ITEM
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
    cat $canal/items.xml >> $canal/item.xml
    mv $canal/item.xml $canal/items.xml
}


#----------------------------------------------------------#
#                    Actualizar el feed                    #
#----------------------------------------------------------#
# (Coge la info de
actualizar_feed () {
    # Valores de argumentos
    local servidor=${1:?Falta el servidor del feed}
    local canal=${2:?Falta el nombre del canal}
    local titulo=${3:?Falta el título del canal}

    cd $twitch_dir

    # Comprueba si hay algún mp3 en la carpeta del canal, si no hay sale de la función
    if [ ! -e ./$canal/mp3/*.mp3 ]; then return; fi
    
    # Encabezado del feed
    echo "- Insertando el encabezado del feed"

    cat > $canal/feed.xml <<END_HEADER
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <atom:link href="$servidor/twitch/$canal/feed.xml" rel="self" type="application/rss+xml"/>
    <title>$TITULO</title>
    <description>Un podcast creado por Sherlockes a partir del canal de $TITULO</description>
    <copyright>Copyright 2022 Sherlockes</copyright>
    <language>es</language>
    <pubDate>$FECHA</pubDate>
    <lastBuildDate>$FECHA</lastBuildDate>
    <image>
      <link>https://sherblog.pro</link>
      <title>$TITULO</title>
      <url>$servidor/twitch/$canal/artwork.jpg</url>
    </image>
    <link>https://www.sherblog.pro</link>
END_HEADER

    # Añadir lista de episodios al feed
    echo "- Añadiendo lista de episodios al feed"
    cat $canal/items.xml >> $canal/feed.xml

    # Añadiendo el pie del feed
    echo "- Añadiendo el pie del feed"
    cat >> $canal/feed.xml <<END
  </channel>
</rss>
END
}

#----------------------------------------------------------#
#               Subir contenido actualizado                #
#----------------------------------------------------------#
subir_contenido () {
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    
    # Subiendo archivos a la nube via rclone
    echo "- Subiendo los mp3's al servidor remoto"
    rclone copy $canal Sherlockes78_UN3_en:twitch/$canal/ --create-empty-src-dirs

    # Eliminando audio y video local
    echo "- Eliminando audios locales"
    find . -type f -name "*.mp3" -delete

    # Borrando los archivos de la nube anteriores a 30 días
    rclone delete Sherlockes78_UN3_en:twitch/$canal/mp3 --min-age 30d
}


################################
####    Script principal    ####
################################

cd $twitch_dir
echo "- Corriendo en $twitch_dir"

# Comprobar dependencias
mensaje+=$'Comprobando dependencias. . . . . . . . . . . '
dependencias
comprobar $?

# Buscar nuevos videos y convertirlos a mp3
buscar_ultimos_yt "$CANAL"

# Añadir info si hay nuevos vídeos y moverlos a la carpeta mp3
if ls ./*.mp3 1> /dev/null 2>&1; then
    mensaje+=$'Añadiendo info del nuevo vídeo . . . . . . . . '
    tag_y_mover
    comprobar $?
fi

# Actualizar el feed si hay nuevos vídeos
if ls ./$CANAL/mp3/*.mp3 1> /dev/null 2>&1; then
    mensaje+=$'Actualizando el Feed . . . . . . . . . . . . . . . . '
    actualizar_feed "$SERVIDOR" "$CANAL" "$TITULO"
    comprobar $?
fi

# Subir si hay nuevo contenido al servidor
if ls ./$CANAL/mp3/*.mp3 1> /dev/null 2>&1; then
    mensaje+=$"Subiendo los mp3's al sevidor webdav . . ."
    subir_contenido "$CANAL"
    comprobar $?
fi

# Envia el mensaje de telegram con el resultado
fin=$( date +%s )
let duracion=$fin-$inicio
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'
mensaje+=$"Duración del Script:  $duracion segundos"

$notificacion "$mensaje"
