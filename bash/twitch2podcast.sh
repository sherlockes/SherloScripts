#!/bin/bash

###################################################################
#Script Name: twitch2podcast.sh
#Description: Generación de entorno de desarrollo para sherblog.pro
#Args: N/A
#Creation/Update: 20220317/20220218
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

CANAL="jordillatzer"
TITULO="Jordi Llatzer en Twitch"
SERVIDOR="http://192.168.10.202:5005"
ANO=2022
FECHA=$(date)

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
twdl=$script_dir/twitch-dl.pyz

echo "#####################################"
echo "## Twitch to Podcast by Sherlockes ##"
echo "#####################################"

cd $script_dir
echo "- Corriendo en $script_dir"

# Obtiene el json de los ultimos vídeos.
echo "- Obteniendo últimos vídeos de $TITULO"
json=$(python3 $twdl videos $CANAL -j)

# Busca sobre los ultimos diez videos
for i in {0..9}
do
    # obtiene la identificación y minutos de duración del último vídeo
    id=$(echo "$json" | jq ".videos[$i].id" | cut -c2- | rev | cut -c2- | rev)
    mins=$(expr $(echo "$json" | jq ".videos[$i].lengthSeconds") / 60)

    # Comprobar si el archivo ya ha sido descargado
    if grep -q $id $script_dir/$CANAL/descargados.txt
    then 
	echo "- El vídeo $id ya ha sido descargado.";
    else
	echo "- Descargando el audio del vídeo $id.";
        if (( $mins > 10 ))
        then
            $twdl download -q audio_only $id;
        else
            echo "- El archivo sólo tiene $mins minutos, no se descarga."
        fi
	# Añade el archivo a la lista de descargados
	echo $id >> $script_dir/$CANAL/descargados.txt;
    fi
done

# Pasa a mp3, quita silencios, mueve el audio a destino y elimina el video
find . -type f -name "*.mkv" | while read -r file; do
    echo "- Codificando el audio y eliminando silencios"
    ffmpeg -loglevel 5 -i "$file" -af silenceremove=1:0:-50dB "${file%.mkv}.mp3"
    echo "- Moviendo el audio a la carpeta de destino"
    nombre=$(basename $file .mkv)
    mv $nombre.mp3 $CANAL/mp3/$nombre.mp3
    echo "- Eliminando el video"
    rm $file
done

# Creación del Feed
echo "- Creando el Feed"

# Encabezado del feed
echo "- Encabezado del feed"

cat > $CANAL/feed.xml <<END_HEADER
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <atom:link href="$SERVIDOR/twitch/$CANAL/feed.xml" rel="self" type="application/rss+xml"/>
    <title>$TITULO</title>
    <description>Un podcast creado por Sherlockes a partir del canal de $TITULO</description>
    <copyright>Copyright 2022 Sherlockes</copyright>
    <language>es</language>
    <pubDate>$FECHA</pubDate>
    <lastBuildDate>$FECHA</lastBuildDate>
    <image>
      <link>https://sherblog.pro</link>
      <title>$TITULO</title>
      <url>$SERVIDOR/twitch/$CANAL/artwork.jpg</url>
    </image>
    <link>https://www.sherblog.pro</link>
END_HEADER

# Buscando mp3's locales para extraer info
echo "- Buscando nuevos episodios descargados"

find $CANAL -type f -name "*.mp3" | while read -r file; do
    NOM_EP=$(basename $file)
    ART_EP=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 $file)
    TIT_EP=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 $file)
    FEC_EP=$(echo $NOM_EP | awk -F'_' '{print $1}')
    FEC_EP=$(date -d $FEC_EP +'%a, %d %b %Y')
    ID_EP=$(echo $NOM_EP | awk -F'_' '{print $2}')

    echo "- Añadiendo episodio $ID_EP a la dista de episodios"
    
    cat >> $CANAL/items.xml <<END_ITEM
    <item>
      <guid isPermaLink="true">$SERVIDOR/$CANAL/$ID_EP</guid>
      <title>$TIT_EP</title>
      <link>http://linktoyourpodcast.com/$ID_EP</link>
      <description>Esta es la descripción</description>
      <pubDate>$FEC_EP 22:00:00 PST</pubDate>
      <author>$ART_EP</author>
      <content:encoded><![CDATA[<p>Episodio descargado de Twitch.</p>]]></content:encoded>
      <enclosure length="37424476" type="audio/mpeg" url="$SERVIDOR/twitch/$CANAL/mp3/$NOM_EP"/>
    </item>
END_ITEM
done

# Añadir lista de episodios al feed
echo "- Añadiendo lista de episodios al feed"
cat $CANAL/items.xml >> $CANAL/feed.xml

# Añadiendo el pie del feed
echo "- Añadiendo el pie del feed"
cat >> $CANAL/feed.xml <<END
  </channel>
</rss>
END

# Subiendo archivos a la nube via rclone
echo "- Subiendo los mp3's al sevidor remoto"
rclone copy $CANAL Sherlockes78_UN_en:twitch/$CANAL/ --create-empty-src-dirs

# Eliinando audio y video local
echo "- Eliminando audios locales"
find . -type f -name "*.mp3" -delete



