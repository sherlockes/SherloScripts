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

################################
####      Dependencias      ####
################################

# yt-dlp
# id3v2

################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################

echo "######################################"
echo "## Youtube to Podcast by Sherlockes ##"
echo "######################################"

cd $twitch_dir
echo "- Corriendo en $twitch_dir"

echo "- Descargando lista del canal de $CANAL"
#yt-dlp --dateafter now-30day --get-filename -o "%(id)s/%(duration)s" $CANAL_YT > salida

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
