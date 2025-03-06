#!/bin/bash

###################################################################
#Script Name: radares_v2.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250305/20250306
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

carpeta="$HOME/radares"


################################
####      Dependencias      ####
################################



################################
####       Funciones        ####
################################

download_and_unzip() {
    local url="https://www.todo-poi.es/radar/GARMIN_RADARES/garminvelocidad%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip"
    local output_file="$HOME/radares.zip"
    local output_dir="$HOME/radares"

    # Crear el directorio en la home del usuario si no existe
    mkdir -p "$output_dir"

    # Descargar el archivo en la home del usuario
    echo "Descargando el archivo en $output_file..."
    curl -L -o "$output_file" "$url"

    # Verificar si la descarga fue exitosa
    if [[ $? -ne 0 ]]; then
        echo "Error al descargar el archivo."
        return 1
    fi

    # Descomprimir el archivo en ~/radares/
    echo "Descomprimiendo el archivo en $output_dir..."
    unzip "$output_file" -d "$output_dir"

    # Verificar si la extracción fue exitosa
    if [[ $? -ne 0 ]]; then
        echo "Error al descomprimir el archivo."
        return 1
    fi

    # Eliminar el archivo ZIP después de la extracción (opcional)
    rm "$output_file"

    echo "Descarga y descompresión completadas exitosamente en $output_dir."
}

# Llamar a la función
#download_and_unzip




################################
####    Script principal    ####
################################


clear(){
    rm -rf $carpeta
    mkdir $carpeta
}

download(){
    curl "https://www.todo-poi.es/radar/GARMIN_RADARES/garminvelocidad%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip" -o $carpeta/radares_1.zip

    curl "https://www.todo-poi.es/radar/GARMIN_RADARES/garmintipo%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip" -o $carpeta/radares_2.zip
}

unzip_all(){
    unzip -o -j "$carpeta/*.zip" -d "$carpeta"
    find "$carpeta" -type f ! -name "*.csv" -delete
}


clear
download
unzip_all




