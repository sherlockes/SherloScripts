#!/bin/bash

###################################################################
#Script Name: twitch2podcast.sh
#Description: Generación de entorno de desarrollo para sherblog.pro
#Args: N/A
#Creation/Update: 20220317/20220217
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

canal="jordillatzer"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
twdl=$script_dir/twitch-dl.pyz

cd $script_dir

# Obtiene el json de los ultimos vídeos.
json=$(python3 $twdl videos $canal -j)

# Busca sobre los ultimos diez videos
for i in {0..9}
do
    # obtiene la identificación y minutos de duración del último vídeo
    id=$(echo "$json" | jq ".videos[$i].id" | cut -c2- | rev | cut -c2- | rev)
    mins=$(expr $(echo "$json" | jq ".videos[$i].lengthSeconds") / 60)

    # Comprobar si el archivo ya ha sido descargado
    if grep -q $id $script_dir/descargados.txt
    then 
	echo "El vídeo $id ya ha sido descargado.";
    else
	echo "Descargando el audio del vídeo $id.";
        if (( $mins > 10 ))
        then
            $twdl download -q audio_only $id;
            # Convertir videos a mp3 y eliminar los mkv's
            find . -type f -name "*.mkv" -exec bash -c 'FILE="$1"; ffmpeg -i "${FILE}" -af silenceremove=1:0:-50dB -vn -c:a libmp3lame -y "mp3/${FILE%.mkv}.mp3";' _ '{}' \;
            find . -type f -name "*.mkv" -delete
        else
            echo "El archivo sólo tiene $mins minutos, no se descarga."
        fi
    # Añade el archivo a la lista de descargados
	echo $id >> $script_dir/descargados.txt;
    fi
done




