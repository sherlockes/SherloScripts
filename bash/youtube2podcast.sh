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
#CANAL_YT="https://www.youtube.com/channel/UCSQJX9lm4u92bx0XGpEIUiA"
CANAL_YT="https://www.youtube.com/watch?v=T-SliI2PHQQ&list=PLD75mPDs8ehwjBOCDPUlmxsnNySzJl-Lv"


twitch_dir=~/twitch
DESCARGADOS="$twitch_dir/$CANAL/descargados_yt.txt"

################################
####      Dependencias      ####
################################

# yt-dlp
# id3v2

################################
####       Funciones        ####
################################

#----------------------------------------------------------#
#   Buscar los últimos vídeos de un canal no descargados   #
#----------------------------------------------------------#
buscar_ultimos_2 () {
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}

    echo "- Descargando lista del canal de $CANAL"
    yt-dlp --dateafter now-30day --get-filename -o "%(id)s/%(duration)s" $CANAL_YT > salida

    while read -r line; do
	IFS='/'
	array=( $line )
	DURACION=${array[1]}
	EPISODIO=${array[0]}
    
	if (( $DURACION > 1200 )); then
	    # Comprobar si el archivo ya ha sido descargado
	    if grep -q $EPISODIO "$twitch_dir/$CANAL/descargados_yt.txt"
	    then
		echo "- El episodio $EPISODIO ya ha sido descargado"
	    else
		# Descargando el episodio
		echo -e "- Descargando episodio $EPISODIO...."
		yt-dlp -o "%(id)s.%(ext)s" --parse-metadata "title:Probando ando" --extract-audio --audio-format mp3 "https://www.youtube.com/watch?v="$EPISODIO

		# Añadiendo el episodio descargado a la lista
		echo -e "- Añadiendo a la lista de episodios descargados"
		echo $EPISODIO | cat - "$twitch_dir/$CANAL/descargados_yt.txt" > temp && mv temp "$twitch_dir/$CANAL/descargados_yt.txt"

		AUDIO="$EPISODIO.mp3"
	    
		id3v2 -t "Sólo un título" -a "Jordi Llatzer" -A "Youtube2Podcast" $AUDIO
		mv $AUDIO "$twitch_dir/$CANAL/mp3"
	    
		for track in *.mp3 ; do
		    echo "Taggeando ando"
		    echo $track
		    #id3v2 -t "Sólo un título" -a "Jordi Llatzer" -A "Youtube2Podcast" $track
		done

		# Mover mp3
		#find "$twitch_dir" -iname '*.mp3' -exec mv '{}' "$twitch_dir/$CANAL/mp3" \;
	    fi
	fi
    done < salida
}

buscar_ultimos(){
    # Valores de argumentos
    local canal=${1:?Falta el nombre del canal}
    local videos
    local id
    local duracion

    mapfile -t videos < <( yt-dlp --dateafter now-30day --get-filename -o "%(id)s/%(duration)s" $CANAL_YT )

    for video in ${videos[@]}
    do
	id=$( echo "$video" |cut -d\/ -f1 )
	duracion=$( echo "$video" |cut -d\/ -f2 )
	titulo=$( echo "$video" |cut -d\/ -f3 )

	# Comprueba si el archivo es de más de 20'
	if (( $duracion > 1200 )) && ! grep -q $id "$DESCARGADOS"; then
	    # Descargando el episodio
	    echo -e "- Descargando episodio $id...."
	    yt-dlp -o "%(title)s.%(ext)s" --extract-audio --audio-format mp3 "https://www.youtube.com/watch?v="$id
	    
	    # Añadiendo el episodio descargado a la lista
	    echo -e "- Añadiendo a la lista de episodios descargados"
	    echo $id | cat - $DESCARGADOS > temp && mv temp $DESCARGADOS

	else
	    echo " - El episodio $id no se procesa por corto o ya descargado"
	fi
	
    done
    
}

descargar_video(){
    local video=${1:?Falta el id del video}
    
    #yt-dlp -o "%(id)s.%(ext)s" --parse-metadata "title:%(title)s" --extract-audio --audio-format mp3 "https://www.youtube.com/watch?v="$video

    yt-dlp -o "%(id)s.%(ext)s" --extract-audio --audio-format mp3 "https://www.youtube.com/watch?v="$video
}

tag_y_mover(){
    for track in *.mp3 ; do
	echo "Taggeando ando"
	echo $track
	id3v2 -t "$track" -a "Jordi Llatzer" -A "Youtube2Podcast" $track
    done
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
buscar_ultimos "$CANAL"

tag_y_mover
