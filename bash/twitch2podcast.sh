#!/bin/bash

###################################################################
#Script Name: twitch2podcast.sh
#Description: Generación de Podcast a partir de canal de Twitch
#Args: N/A
#Creation/Update: 20220317/20220224
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

CANAL="jordillatzer"
TITULO="Jordi Llatzer en Twitch"
SERVIDOR="http://192.168.10.202:5005"
FECHA=$(date)

twitch_dir=~/twitch
twdl=$twitch_dir/twitch-dl.pyz

echo "#####################################"
echo "## Twitch to Podcast by Sherlockes ##"
echo "#####################################"

###############
## Funciones ##
###############

# Función para buscar los últimos vídeos de un canal no descargados
buscar_ultimos () {
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    #local titulo=${2:?Falta el título del canal}
    local titulo=$2

    # Obtiene el json de los ultimos vídeos.
    echo "$2"
    echo "- Obteniendo últimos vídeos de $titulo"
    json=$(python3 $twdl videos $canal -j)

    # Busca sobre los ultimos diez videos
    for i in {0..9}
    do
	# obtiene la identificación y minutos de duración del último vídeo
	id=$(echo "$json" | jq ".videos[$i].id" | cut -c2- | rev | cut -c2- | rev)
	mins=$(expr $(echo "$json" | jq ".videos[$i].lengthSeconds") / 60)

	# Comprobar si el archivo ya ha sido descargado
	if grep -q $id $twitch_dir/$canal/descargados.txt
	then 
	    echo "- El vídeo $id ya ha sido descargado.";
	    # No sigue comprobando si ya ha visto uno descargado
	    break
	else
	    echo "- Descargando el audio del vídeo $id.";
            if (( $mins > 10 ))
            then
		# Descarga el audio en formato mkv
		$twdl download -q audio_only $id;
            else
		echo "- El archivo sólo tiene $mins minutos, no se descarga."
            fi
	    # Añade el archivo a la lista de descargados
	    echo $id >> $twitch_dir/$canal/descargados.txt;
	fi
    done
}

# Función para pasar a mp3 los vídeos descargados en la carpeta
# (Coge todos los vídeos que hay en la carpeta del script)
convertir_mp3 () {
    # comprueba si hay algún video, si no hay sale de la función
    if [ ! -e ./*.mkv ]; then return; fi;

    local canal=${1:?Falta el nombre del canal}
    echo "- Buscando archivos para convertir en $canal"

    for file in ./*.mkv; do
	local nombre=$(basename $file .mkv)
	local id_ep=$(echo $nombre | awk -F'_' '{print $2}')

	echo "- Episodio $id_ep, codificando audio y eliminando silencios"
	ffmpeg -loglevel 24 -i "$file" -af silenceremove=1:0:-50dB "${file%.mkv}.mp3"

	echo "- Episodio $id_ep, moviendo mp3"
	mv $nombre.mp3 $canal/mp3/$nombre.mp3

	echo "- Episodio $id_ep, eliminando el video"
	rm $file
    done
}

# Función para actualizar el feed a partir de lo anterior y lo descargado
# (Coge la info de
actualizar_feed () {
    # Valores de argumentos
    local servidor=${1:?Falta el servidor del feed}
    local canal=${2:?Falta el nombre del canal}
    local titulo=${3:?Falta el título del canal}

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

    # Buscando mp3's locales para extraer info
    echo "- Buscando nuevos episodios descargados"

    find $canal -type f -name "*.mp3" | while read -r file; do
	NOM_EP=$(basename $file)
	ART_EP=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 $file)
	TIT_EP=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 $file)
	FEC_EP=$(echo $NOM_EP | awk -F'_' '{print $1}')
	FEC_EP=$(date -d $FEC_EP +'%a, %d %b %Y')
	ID_EP=$(echo $NOM_EP | awk -F'_' '{print $2}')

	echo "- Añadiendo episodio $ID_EP a la dista de episodios"

	# crea el "item.xml" con info del episodio
	cat >> $canal/item.xml <<END_ITEM
    <item>
      <guid isPermaLink="true">$servidor/$canal/$ID_EP</guid>
      <title>$TIT_EP</title>
      <link>http://linktoyourpodcast.com/$ID_EP</link>
      <description>Esta es la descripción</description>
      <pubDate>$FEC_EP 22:00:00 PST</pubDate>
      <author>$ART_EP</author>
      <content:encoded><![CDATA[<p>Episodio descargado de Twitch.</p>]]></content:encoded>
      <enclosure length="37424476" type="audio/mpeg" url="$servidor/twitch/$canal/mp3/$NOM_EP"/>
    </item>
END_ITEM
    done

    # Añade los "items.xml" ya descargado a continuación del "item.xml"
    cat $canal/items.xml >> $canal/item.xml
    mv $canal/item.xml $canal/items.xml
    
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

subir_contenido () {
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    
    # Subiendo archivos a la nube via rclone
    echo "- Subiendo los mp3's al sevidor remoto"
    rclone copy $canal Sherlockes78_UN_en:twitch/$canal/ --create-empty-src-dirs

    # Eliminando audio y video local
    echo "- Eliminando audios locales"
    find . -type f -name "*.mp3" -delete
}

########################
## Programa principal ##
########################

cd $twitch_dir
echo "- Corriendo en $twitch_dir"

# Comprobar la instalación de twitch-dl en el directorio
. ~/SherloScripts/bash/twitch-dl.sh && check
case 
buscar_ultimos "$CANAL" "$TITULO"
convertir_mp3 "$CANAL"
actualizar_feed "$SERVIDOR" "$CANAL" "$TITULO"
subir_contenido "$CANAL"
