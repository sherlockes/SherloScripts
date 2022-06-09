#!/bin/bash

###################################################################
#Script Name: youtube2podcast.sh
#Description: Creación de un podcast a partir de un canal de youtube
#Args: N/A
#Creation/Update: 20220605/20220605
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

CANAL="jordillatzer"
CANAL_NOMBRE="Jordi Llatzer"
TITULO="Jordi Llatzer en Twitch"
SERVIDOR="http://192.168.10.202:5005"
#CANAL_YT="https://www.youtube.com/channel/UCSQJX9lm4u92bx0XGpEIUiA"
CANAL_YT="https://www.youtube.com/watch?v=T-SliI2PHQQ&list=PLD75mPDs8ehwjBOCDPUlmxsnNySzJl-Lv"


twitch_dir=~/twitch
DESCARGADOS="$twitch_dir/$CANAL/descargados_yt.txt"

################################
####      Dependencias      ####
################################

# yt-dlp
# id3v2
# ffmpeg

################################
####       Funciones        ####
################################

#----------------------------------------------------------#
#   Buscar los últimos vídeos de un canal no descargados   #
#----------------------------------------------------------#

buscar_ultimos_yt(){
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    local videos
    local id
    local duracion

    echo "- Buscando últimos vídeos de $CANAL_NOMBRE"
    
    mapfile -t videos < <( yt-dlp --dateafter now-30day --get-filename -o "%(id)s/%(duration)s" $CANAL_YT )

    for video in ${videos[@]}
    do
	id=$( echo "$video" |cut -d\/ -f1 )
	duracion=$( echo "$video" |cut -d\/ -f2 )

	# Comprueba si el archivo es de más de 20'
	if (( $duracion > 1200 )) && ! grep -q $id "$DESCARGADOS"; then
	    # Descargando el episodio
	    descargar_video_yt $id
	else
	    echo "- El episodio $id no se procesa por corto o ya descargado"
	fi
	
    done
    
}

descargar_video_yt(){
    local id=${1:?Falta el id del video}
    local url="https://www.youtube.com/watch?v=$id"
    
    echo -e "- Descargando episodio $id...."
    yt-dlp -o "%(id)s.%(ext)s" --extract-audio --audio-format mp3 $url

    if [ $? -eq 0 ]; then
	# Añadiendo el episodio descargado a la lista
	echo -e "- Añadiendo a la lista de episodios descargados"
	echo $id | cat - $DESCARGADOS > temp && mv temp $DESCARGADOS
    fi
}

tag_y_mover(){
    # Comprueba si hay algún mp3 en la carpeta del canal, si no hay sale de la función
    cd $twitch_dir
    if [ ! -e ./*.mp3 ]; then return; fi

    # Lista todos los mp3 de la carpeta
    for track in *.mp3 ; do
	local nombre="${track%.*}"
	local titulo=$(yt-dlp --get-title "https://www.youtube.com/watch?v=$nombre")
	
	id3v2 -t "$titulo" -a "$CANAL_NOMBRE" -A "Youtube2Podcast" $track
	
	anadir_item $track "youtube" "$CANAL"

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
	FEC_EP=$(date -d $fecha +"%Y-%m-%dT%H:%M:%S%:z")
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
      <enclosure length="$LEN_EP" type="audio/mpeg" url="$servidor/twitch/$canal/mp3/$NOM_EP"/>
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

    # Comprueba si hay algún mp3 en la carpeta del canal, si no hay sale de la función
    if [ ! -e ./$canal/mp3/*.mp3 ]; then return; fi

    # Encabezado del feed
    echo "- Insertando el encabezado del feed"
    mensaje+=$"Actualizando el Feed"
    mensaje+=$'\n'

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

    # Comprueba si hay algún mp3 en la carpeta del canal, si no hay sale de la función
    if [ ! -e ./$canal/mp3/*.mp3 ]; then return; fi
    
    # Subiendo archivos a la nube via rclone
    echo "- Subiendo los mp3's al sevidor remoto"
    mensaje+=$"Subiendo los mp3's al sevidor webdav . . ."
    rclone copy $canal Sherlockes78_UN_en:twitch/$canal/ --create-empty-src-dirs
    comprobar $?

    # Eliminando audio y video local
    echo "- Eliminando audios locales"
    find . -type f -name "*.mp3" -delete

    # Borrando los archivos de la nube anteriores a 30 días
    mensaje+=$"Borrando contenido antiguo . . . . . . . . ."
    rclone delete Sherlockes78_UN_en:twitch/$canal/mp3 --min-age 30d
    comprobar $?
}


################################
####    Script principal    ####
################################

echo "######################################"
echo "## Youtube to Podcast by Sherlockes ##"
echo "######################################"

cd $twitch_dir
echo "- Corriendo en $twitch_dir"

# Buscar nuevos videos y convertirlos a mp3
buscar_ultimos_yt "$CANAL"

tag_y_mover

# Actualizar el feed con los nuevos vídeos
actualizar_feed "$SERVIDOR" "$CANAL" "$TITULO"

# Subir el nuevo contenido al servidor
#subir_contenido "$CANAL"




