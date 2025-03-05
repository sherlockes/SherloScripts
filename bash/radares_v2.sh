#!/bin/bash

###################################################################
#Script Name: radares_v2.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250305/20250305
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

RUTA=~/temp


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
    unzip -o "$HOME/radares.zip" -d "$HOME/radares"

    # Verificar si la extracción fue exitosa
    if [[ $? -ne 0 ]]; then
        echo "Error al descomprimir el archivo."
        return 1
    fi

    # Si hay otro ZIP dentro, descomprimirlo también
    inner_zip=$(find "$output_dir" -type f -name "*.zip")
    if [[ -n "$inner_zip" ]]; then
        echo "Encontrado un ZIP dentro: $inner_zip"
        unzip -o "$inner_zip" -d "$output_dir"
        rm "$inner_zip"  # Eliminar el ZIP interno después de extraerlo
    fi

    # Eliminar el archivo ZIP principal después de la extracción (opcional)
    rm "$output_file"

    echo "Descarga y descompresión completadas exitosamente en $output_dir."
}

# Llamar a la función
download_and_unzip



################################
####    Script principal    ####
################################


