#!/bin/bash

###################################################################
#Script Name: yt2pcst.sh
#Description: Generación de un podcast a partir de canales de youtube
#Args: N/A
#Creation/Update: 20240411/20240418
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

# Ubicación del script para mandar notificaciones a telegram
source telegram_V2.sh

PATH="/home/pi/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Hora de inicio del Script
inicio=$( date +%s )

# Número de vídeos a comprobar de cada canal
num_videos=20

# Número de vídeos máximo a descargar en total
num_max_descargas=2
num_descargas=0

# Carpeta para guardar los archivos y comprobación de su existencia
yt2pcst_dir="$HOME/yt2pcst"

if [ ! -d "$yt2pcst_dir" ]; then
    echo "La carpeta contenedora no existe. Creando carpetas y portada..."
    mkdir -p "$yt2pcst_dir"
    mkdir -p "$yt2pcst_dir/mp3"
    wget -O "$yt2pcst_dir/artwork.jpg" "https://picsum.photos/400/400"
fi

# Episodios ya descargados
DESCARGADOS="$yt2pcst_dir/descargados.txt"

if [ ! -f "$DESCARGADOS" ]; then
    echo "El archivo de descargados no existe. Creando el archivo..."
    touch "$DESCARGADOS"
fi

# Ruta al archivo de canales
archivo_canales="$yt2pcst_dir/canales.txt"

if [ ! -f "$archivo_canales" ]; then
    echo "El archivo de canales no existe. Creando el archivo..."
    touch "$archivo_canales"
    echo "Jordi LLatzer,https://www.youtube.com/@jordillatzer/videos" > $archivo_canales
    echo "He creado un canal de ejemplo, rellenalo a tu gusto y vuelve a lanzar el script"
    exit 0
fi

# Limitar el archivo descargados
num_canales=$(wc -l < $archivo_canales)
head -n 300 $DESCARGADOS > temp.txt && mv temp.txt $DESCARGADOS

# Ruta del servidor webdav donde estarán alojados los episodios
SERVIDOR="http://192.168.10.210:5005"

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
	echo "ATENCION: id3v2 no está disponible, se intenta instalar"
	sudo apt install -y id3v2
    fi

    # ffmpeg
    if command -v ffmpeg >/dev/null 2>&1 ; then
	echo "Versión de ffmpeg: $(ffmpeg -version | grep 'ffmpeg version' | sed 's/ffmpeg version \([-0-9.]*\).*/\1/')"
    else
	echo "ATENCION: ffmpeg no está disponible, se intenta instalar"
	sudo apt install -y ffmpeg
    fi

    # rclone
    if command -v rclone >/dev/null 2>&1 ; then
	echo "Versión de rclone: $(rclone version | grep 'rclone' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/'
)"
    else
	echo "ATENCION: rclone no está disponible, se intenta instalar"
	sudo -v ; curl https://rclone.org/install.sh | sudo bash
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
	tele_msg_resul "ok"
    else
	tele_msg_resul "KO"
    fi
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
    tele_msg_instr "$nombre videos"
    
    echo "- Buscando últimos vídeos de $nombre en $url"

    mapfile -t videos < <( yt-dlp --flat-playlist --print "%(id)s/%(duration)s" --playlist-end $num_videos $url )

    comprobar $?

    for video in ${videos[@]}
    do
	id=$( echo "$video" |cut -d\/ -f1 )
	duracion=$( echo "$video" |cut -d\/ -f2 )
	duracion=${duracion%??}
	
	# Comprueba si el archivo es de más de 10'
	if (( $duracion > 1200 )) && ! grep -q $id "$DESCARGADOS"; then
	    # Descargando el episodio
	    tele_msg_instr "Download $id "
	    echo "- Descargando el vídeo $id"
	    descargar_video $id
	    comprobar $?

	    echo "- Taggeando el vídeo $id"
	    tele_msg_instr "Tag $id "
	    tag $id "$nombre"
	    comprobar $?
	else
	    echo "- El episodio $id ($duracion sg) es corto o ya descargado"
	    if (( $duracion < 1201 )) && ! grep -q $id "$DESCARGADOS"; then
		# echo -e "- Añadiendo $id corto a descargados"
		echo $id | cat - $DESCARGADOS > temp && mv temp $DESCARGADOS
	    fi
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
	# Incrementa en 1 las descargas realizadas
	num_descargas=$((num_descargas + 1))
	# Añadiendo el episodio descargado a la lista
	echo -e "- Añadiendo a la lista de episodios descargados"
	echo -e "- Descargados $num_descargas de $num_max_descargas"
	echo $id | cat - $DESCARGADOS > temp && mv temp $DESCARGADOS

	# Verificar si se ha alcanzado el número deseado de descargas
	if [ $num_descargas -eq $num_max_descargas ]; then
	    echo "Ya vale de descargas"
	    break  # Salir del bucle
	fi
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
    id3v2 -t "$titulo" -a "$artista" -A "Youtube2Podcast" -- "$id.mp3"

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
      <content:encoded><![CDATA[<p>Episodio descargado de Youtube.</p>]]></content:encoded>
      <enclosure length="$LEN_EP" type="audio/mpeg" url="$SERVIDOR/youtube/mp3/$ID_EP.mp3"/>
    </item>
END_ITEM

    # Añade los "items.xml" ya descargado a continuación del "item.xml"
    cat items.xml >> item.xml
    mv item.xml items.xml
}

#----------------------------------------------------------#
#                    Actualizar el feed                    #
#----------------------------------------------------------#
# (Coge la info de
actualizar_feed () {
    # Valores de argumentos
    local servidor=${1:?Falta el servidor del feed}

    cd $yt2pcst_dir
    
    # Encabezado del feed
    echo "- Insertando el encabezado del feed"

    cat > feed.xml <<END_HEADER
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
      <link>https://sherblog.es</link>
      <title>Youtube2Podcast</title>
      <url>$servidor/youtube/artwork.jpg</url>
    </image>
    <link>https://www.sherblog.es</link>
END_HEADER

    # Añadir lista de episodios al feed
    echo "- Añadiendo lista de episodios al feed"
    cat items.xml >> feed.xml

    # Añadiendo el pie del feed
    echo "- Añadiendo el pie del feed"
    cat >> feed.xml <<END
  </channel>
</rss>
END
}

#----------------------------------------------------------#
#               Subir contenido actualizado                #
#----------------------------------------------------------#
subir_contenido () {
    
    # Subiendo archivos a la nube via rclone
    echo "- Subiendo mp3's al servidor remoto"
    rclone copy $yt2pcst_dir Sherlockes78_GD:youtube/ --create-empty-src-dirs

    # Eliminando audio y video local
    echo "- Eliminando audios locales"
    find . -type f -name "*.mp3" -delete

    # Borrando los archivos de la nube anteriores a 30 días
    rclone delete Sherlockes78_GD:youtube/mp3 --min-age 30d
}
################################
####    Script principal    ####
################################



#mensaje=$'Actualizar Youtube via <a href="https://raw.githubusercontent.com/sherlockes/SherloScripts/master/bash/yt2pc.sh">yt2pc.sh</a>\n'
#mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'


echo "######################################"
echo "## Youtube to Podcast by Sherlockes ##"
echo "######################################"

tele_msg_title "  From youtube to podcast  "

cd $yt2pcst_dir

# Comprobar dependencias
#tele_msg_instr "Check dependencies "
#dependencias
#comprobar $?

# Leer nombres y URLs de los canales de YouTube desde el archivo de texto
while IFS= read -r linea; do
    nombre=$(echo "$linea" | cut -d ',' -f 1)
    url=$(echo "$linea" | cut -d ',' -f 2)
    #echo "Nombre del canal: $nombre"
    #echo "URL del canal: $url"
    buscar_ultimos "$nombre" "$url"
done < "$archivo_canales"

# Actualizar el feed  y subir contenido si hay nuevos vídeos
if ls ./mp3/*.mp3 1> /dev/null 2>&1; then
    tele_msg_instr "Feed update "
    actualizar_feed "$SERVIDOR"
    comprobar $?

    tele_msg_instr "Upload mp3's to server "
    subir_contenido
    comprobar $?
else
    tele_msg_instr "No new content "
    tele_msg_resul "..."
fi

# Envia el mensaje de telegram con el resultado
tele_end
