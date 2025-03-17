#!/bin/bash

###################################################################
#Script Name: tw2pcst.sh
#Description: Generación de Podcast a partir de canal de Twitch
#Args: N/A
#Creation/Update: 20220317/20250317
#Author: www.sherblog.es
#Email: sherlockes@gmail.com                        
###################################################################

CANAL="jordillatzer"
TITULO="Jordi Llatzer en Twitch"
SERVIDOR=${SERVER:-"homezgz.ddns.net:5005"}
FECHA=$(date)

twitch_dir="$HOME/twitch"

# Incluye el archivo de mensajes de Telegram
source ~/SherloScripts/bash/telegram_V2.sh

###############
## Funciones ##
###############

#----------------------------------------------------------#
#                   Comprobar la salida                    #
#----------------------------------------------------------#
comprobar(){

    if [ $1 -eq 0 ]; then
	tele_msg_resul "ok"
    else
	tele_msg_resul "KO"
    fi
}

#----------------------------------------------------------#
#   Buscar los últimos vídeos de un canal no descargados   #
#----------------------------------------------------------#
buscar_ultimos () {
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    local titulo=${2:?Falta el título del canal}

    # Obtiene el json de los ultimos vídeos.
    tele_msg_instr "Search last videos"
    echo "- Obteniendo últimos vídeos de $titulo"
    json=$(twitch-dl videos $canal --json)

    comprobar $?

    # Limitar a 15 videos la lista de descargadoscase 
    tele_msg_instr "Trim downloaded list"
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

	# obtiene la identificación y minutos de duración del último vídeo
	id=$(echo "$json" | jq ".videos[$i].id" | cut -c2- | rev | cut -c2- | rev)
	mins=$(expr $(echo "$json" | jq ".videos[$i].lengthSeconds") / 60)
	
	if [[ $(date +%s) < $publicado ]]
	then
	    tele_msg_instr "El vídeo $id está en emisión"
            tele_msg_resul "..."
	    continue
	fi
	
	# Comprobar si el archivo ya ha sido descargado
	if grep -q $id $twitch_dir/$canal/descargados.txt
	then
	    
        if [ $i -eq 0 ]
        then
            echo "- No hay nuevos vídeos.";
            tele_msg_instr "No hay nuevos vídeos"
            tele_msg_resul "..."
	    
	    # No sigue comprobando si ya ha visto uno descargado
	    continue
        fi
	    echo "- El vídeo $id ya se ha descargado.";
            tele_msg_instr "Video $id already downloaded"
            tele_msg_resul "..."
	    
	    # No sigue comprobando si ya se ha visto uno descargado
	    continue
	else
	    echo "- Descargando el audio del vídeo $id.";
            tele_msg_instr "Download $id audio"

            if (( $mins > 10 ))
            then
		# Descarga el audio en formato mkv
		#twitch-dl download -q audio_only $id;
		#comprobar $?
		#resultado=$?
		#echo "la salida es $?"
		#comprobar $resultado

		output=$(twitch-dl download -q audio_only "$id" 2>&1)  # Capturar la salida y errores
		echo "$output"  # Imprimir la salida por depuración

		if echo "$output" | grep -q "403 Forbidden"; then
		    echo "Error: Acceso prohibido a la descarga."
		    continue
		    # Acciones en caso de error
		elif echo "$output" | grep -iq "error"; then
		    echo "Error detectado en la descarga."
		    continue
		    # Acciones en caso de error general
		elif
		    # No se ha descargado correctamente, pasa al siguiente
		    echo "El audio no se ha descargado correctamente"
		    comprobar $?
		    continue
		else
		    # Añade el archivo al principio de la lista de descargados
		    #echo $id >> $twitch_dir/$canal/descargados.txt;
		    echo "El audio se ha descargado correctemente"
		    comprobar $?
		    echo $id | cat - $twitch_dir/$canal/descargados.txt > temp && mv temp $twitch_dir/$canal/descargados.txt
		fi
            else
		echo "- El archivo sólo tiene $mins minutos, no se descarga."
		tele_msg_instr "Archivo de sólo $mins minutos."
		tele_msg_resul "..."

		# Añade el archivo al principio de la lista de descargados
		echo $id | cat - $twitch_dir/$canal/descargados.txt > temp && mv temp $twitch_dir/$canal/descargados.txt
            fi
	fi
    done
}

#----------------------------------------------------------#
#      Pasa a mp3 los vídeos descargados en la carpeta     #
#----------------------------------------------------------#
convertir_mp3 () {
    local canal=${1:?Falta el nombre del canal}
    echo "- Buscando archivos para convertir en $canal"
    tele_msg_instr "Search $canal files"
    tele_msg_resul "..."

    for file in ./*.mkv; do
       local nombre=$(basename $file .mkv)
       #local nombre=$(basename "$file" .mkv | tr -cd '[:print:]' | awk '{$1=$1};1')
       local id_ep=$(echo $nombre | awk -F'_' '{print $2}')

       echo "- Episodio $id_ep, codificando audio y eliminando silencios"
       tele_msg_instr "Recode $id_ep audio"
       ffmpeg -y -loglevel 24 -i "$file" -af silenceremove=1:0:-50dB "${file%.mkv}.mp3"
       tele_check $?

       echo "- Episodio $id_ep, moviendo mp3"
       tele_msg_instr "Move $id_ep mp3"
       mv $nombre.mp3 $canal/mp3/$id_ep.mp3
       tele_check $?

       echo "- Episodio $id_ep, eliminando el video"
       tele_msg_instr "Delete $id_ep video"
       rm $file
       tele_check $?
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
	json=$(python3 twitch-dl info $ID_EP -json)
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
    
    # Subiendo archivos a la nube via rclone
    echo "- Subiendo los mp3's al sevidor remoto"
    tele_msg_instr "Upload mp3 to server"
    rclone copy $canal Sherlockes78_GD:twitch/$canal/ --create-empty-src-dirs

    tele_check $?

    # Eliminando audio y video local
    echo "- Eliminando audios locales"
    find . -type f -name "*.mp3" -delete

    # Borrando los archivos de la nube anteriores a 30 días
    tele_msg_instr "Delete older mp3s"
    rclone delete Sherlockes78_GD:twitch/$canal/mp3 --min-age 30d
    tele_check $?
}


########################
## Programa principal ##
########################

echo "#####################################"
echo "## Twitch to Podcast by Sherlockes ##"
echo "#####################################"

tele_msg_title "From twitch to podcast"

cd $twitch_dir
echo "- Corriendo en $twitch_dir"

# Comprobar la instalación de twitch-dl en el directorio
#. ~/SherloScripts/bash/twitch-dl.sh && check

# Buscar nuevos videos y convertirlos a mp3
buscar_ultimos "$CANAL" "$TITULO"

# Convertir a mp3 los vídeos descargados (Si los hay)
if ls ./*.mkv 1> /dev/null 2>&1; then
    convertir_mp3 "$CANAL"
fi

# Actualizar el feed y sube el nuevo contenido (Si lo hay)
if ls ./$CANAL/mp3/*.mp3 1> /dev/null 2>&1; then
    actualizar_feed "$SERVIDOR" "$CANAL" "$TITULO"
    subir_contenido "$CANAL"
else
    echo "- No hay nuevo contenido."
    tele_msg_instr "No new content"
    tele_msg_resul "..."
fi


# Envia el mensaje de telegram con el resultado
tele_end


