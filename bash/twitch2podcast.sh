#!/bin/bash

###################################################################
#Script Name: twitch2podcast.sh
#Description: Generación de Podcast a partir de canal de Twitch
#Args: N/A
#Creation/Update: 20220317/20220521
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

CANAL="jordillatzer"
TITULO="Jordi Llatzer en Twitch"
SERVIDOR="http://192.168.10.202:5005"
FECHA=$(date)

twitch_dir=~/twitch
twdl=$twitch_dir/twitch-dl.pyz

notificacion=~/SherloScripts/bash/telegram.sh
inicio=$( date +%s )

mensaje=$'Actualizar Twitch mediante <a href="https://raw.githubusercontent.com/sherlockes/SherloScripts/master/bash/twitch2podcast.sh">twitch2podcast.sh</a>\n'
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'

###############
## Funciones ##
###############

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
buscar_ultimos () {
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    local titulo=${2:?Falta el título del canal}

    # Obtiene el json de los ultimos vídeos.
    mensaje+=$'Obteniendo últimos vídeos . . . . . . . . . . . . '
    echo "- Obteniendo últimos vídeos de $titulo"
    json=$(python3 $twdl videos $canal -j)
    comprobar $?

    # Limitar a 15 videos la lista de descargados
    mensaje+=$'Recortando listas de descargados . . . . . .'
    echo "- Recortando listas de descargados"
    head -n15 $twitch_dir/$canal/descargados.txt > tmp
    mv tmp $twitch_dir/$canal/descargados.txt

    # Limitar a 15 videos la lista de items
    head -n150 $twitch_dir/$canal/items.xml > tmp
    mv tmp $twitch_dir/$canal/items.xml
    comprobar $?

    # Busca sobre los ultimos diez videos
    for i in {0..9}
    do
	# Si el vídeo a comenzado hace menos de 3 horas pasa al siguiente
	publicado=$(echo "$json" | jq ".videos[$i].publishedAt" | cut -c2- | rev | cut -c2- | rev)
	publicado=$(date -d "$publicado+3 hours" +%s)
	
	if [[ $(date +%s) < $publicado ]]
	then
	    mensaje+=$"El vídeo $id está en emisión."
            mensaje+=$'\n'
	    continue
	fi
	
	# obtiene la identificación y minutos de duración del último vídeo
	id=$(echo "$json" | jq ".videos[$i].id" | cut -c2- | rev | cut -c2- | rev)
	mins=$(expr $(echo "$json" | jq ".videos[$i].lengthSeconds") / 60)

	# Comprobar si el archivo ya ha sido descargado
	if grep -q $id $twitch_dir/$canal/descargados.txt
	then
        echo $i
        if [ $i -eq 0 ]
        then
            echo "- No hay nuevos vídeos.";
            mensaje+=$"No hay nuevos vídeos."
            mensaje+=$'\n'
	        # No sigue comprobando si ya ha visto uno descargado
	        break
        fi
	    echo "- El vídeo $id ya ha sido descargado.";
        mensaje+=$"El vídeo $id ya ha sido descargado."
        mensaje+=$'\n'
	    # No sigue comprobando si ya ha visto uno descargado
	    break
	else
	    echo "- Descargando el audio del vídeo $id.";
            mensaje+=$"Descargando el audio de $id . . ."

            if (( $mins > 10 ))
            then
		# Descarga el audio en formato mkv
		$twdl download -q audio_only $id;
		comprobar $?
            else
		echo "- El archivo sólo tiene $mins minutos, no se descarga."
		mensaje+=$"El archivo sólo tiene $mins minutos, no se descarga."
		mensaje+=$'\n'
            fi

	    # Añade el archivo al principio de la lista de descargados
	#echo $id >> $twitch_dir/$canal/descargados.txt;
	echo $id | cat - $twitch_dir/$canal/descargados.txt > temp && mv temp $twitch_dir/$canal/descargados.txt
	
	fi
    done
}

#----------------------------------------------------------#
#      Pasa a mp3 los vídeos descargados en la carpeta     #
#----------------------------------------------------------#
convertir_mp3 () {
    # comprueba si hay algún video, si no hay sale de la función
    if [ ! -e ./*.mkv ]; then return; fi

    local canal=${1:?Falta el nombre del canal}
    echo "- Buscando archivos para convertir en $canal"
    mensaje+=$"Buscando archivos para convertir en $canal"
    mensaje+=$'\n'

    for file in ./*.mkv; do
       local nombre=$(basename $file .mkv)
       local id_ep=$(echo $nombre | awk -F'_' '{print $2}')

       echo "- Episodio $id_ep, codificando audio y eliminando silencios"
       mensaje+=$"Recodificando audio de $id_ep . . . . "
       ffmpeg -loglevel 24 -i "$file" -af silenceremove=1:0:-50dB "${file%.mkv}.mp3"
       comprobar $?

       echo "- Episodio $id_ep, moviendo mp3"
       mensaje+=$"Moviendo mp3 $id_ep . . . . . . . . ."
       mv $nombre.mp3 $canal/mp3/$id_ep.mp3
       comprobar $?

       echo "- Episodio $id_ep, eliminando el video"
       mensaje+=$"Eliminando vídeo $id_ep . . . . . . ."
       rm $file
       comprobar $?
    done
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

    # Buscando mp3's locales para extraer info
    echo "- Buscando nuevos episodios descargados"

    find $canal -type f -name "*.mp3" | while read -r file; do
	NOM_EP=$(basename $file)
	ART_EP=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 $file)
	TIT_EP=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 $file)
	ID_EP=$(echo $NOM_EP | awk -F'_' '{print $2}')

	ID_EP=$(basename $file .mp3)
	
	# Obteniendo info a partir de la ID
	json=$(python3 $twdl info $ID_EP -j)
	FEC_EP=$(echo "$json" | jq ".publishedAt" | cut -c2- | rev | cut -c2- | rev)
	FEC_EP=$(date -d $FEC_EP +"%Y-%m-%dT%H:%M:%S%:z")
	FEC_EP=$(date --date "$FEC_EP-2 hours" "+%a, %d %b %Y %T %Z")

	lengthSeconds=$(echo "$json" | jq ".lengthSeconds")
 
	echo "- Añadiendo episodio $ID_EP a la lista de episodios"
	mensaje+=$"Añadiendo episodio $ID_EP a la lista"
	mensaje+=$'\n'

	# crea el "item.xml" con info del episodio
	cat >> $canal/item.xml <<END_ITEM
    <item>
      <guid isPermaLink="true">$servidor/$canal/$ID_EP</guid>
      <title>$TIT_EP</title>
      <link>https://www.twitch.tv/videos/$ID_EP</link>
      <description>$TIT_EP</description>
      <pubDate>$FEC_EP</pubDate>
      <author>$ART_EP</author>
      <content:encoded><![CDATA[<p>Episodio descargado de Twitch.</p>]]></content:encoded>
      <enclosure length="$lengthSeconds" type="audio/mpeg" url="$servidor/twitch/$canal/mp3/$NOM_EP"/>
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


########################
## Programa principal ##
########################

echo "#####################################"
echo "## Twitch to Podcast by Sherlockes ##"
echo "#####################################"

cd $twitch_dir
echo "- Corriendo en $twitch_dir"

# Comprobar la instalación de twitch-dl en el directorio
#. ~/SherloScripts/bash/twitch-dl.sh && check

# Buscar nuevos videos y convertirlos a mp3
buscar_ultimos "$CANAL" "$TITULO"

# Convertir a mp3 los vídeos descargados
convertir_mp3 "$CANAL"

# Actualizar el feed con los nuevos vídeos
actualizar_feed "$SERVIDOR" "$CANAL" "$TITULO"

# Subir el nuevo contenido al servidor
subir_contenido "$CANAL"

# Envia el mensaje de telegram con el resultado
fin=$( date +%s )
let duracion=$fin-$inicio
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'
mensaje+=$"Duración del Script:  $duracion segundos"

$notificacion "$mensaje"
