#!/bin/bash

###################################################################
# Script Name: exif_create.sh
# Description: Incluye la fecha de captura en las imágenes que no
#              la tienen
# Args: N/A
# Creation/Update: 20210114/20210114
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

# Comprobando si exiftool está instalado en el sistema
if which exiftool >/dev/null; then
    echo 'exiftool está instalado...'
else
    echo 'instalando exiftool...'
    sudo apt install libimage-exiftool-perl
fi


shopt -s nullglob

for ext in jpg jpeg png gif; do 
    files=( *."$ext" )
    if [ ${#files[@]} -gt 0 ]; then
        printf 'Número de imágenes %s : %d\n' "$ext" "${#files[@]}"
        for file in "${files[@]}"; do
            captura=$( exiftool -CreateDate $file )
            if [ -n "$captura" ]; then
                echo $file " tiene fecha de captura"
            else
                echo $file " no tiene fecha de captura."
                exiftool "-CreateDate<FileModifyDate" $file
                exiftool "-FileModifyDate<CreateDate" $file
            fi
        done 
        rm *."$ext"_original
    fi
done

