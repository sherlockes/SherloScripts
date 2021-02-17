#!/bin/bash

###################################################################
# Script Name: photos-gsync.sh
# Description: Copia de seguridad de Google Photos
# Args: N/A
# Creation/Update: 20201211/20210217
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

host=sherlockes@192.168.1.200
ruta=/homes/sherlockes/gphotos
hostname=nas-gphotos

# --------------------------------------------
# Comprobar la instalación de sshfs
# --------------------------------------------

if which sshfs >/dev/null; then
    echo 'sshfs está instalado...'
else
    echo 'instalando sshfs...'
    sudo apt install sshfs
fi

# --------------------------------------------
# Comprobar el acceso ssh
# --------------------------------------------
status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 $host echo ok 2>&1)

if [[ $status == ok ]] ; then
    echo "Acceso a $host autorizado..."
elif [[ $status == "Permission denied"* ]] ; then
    echo "Acceso a $host no autorizado..."
    exit
else
    echo "No es posible el aceso a $host"
    exit
fi

if [[ $status == ok ]] ; then
    # --------------------------------------------
    # Crea la carpeta y monta la unidad
    # --------------------------------------------
    mkdir ~/$hostname
    sshfs $host:$ruta ~/$hostname

    # --------------------------------------------
    # Realiza la sincronización
    # --------------------------------------------
    cd ~/$hostname
    pipenv run gphotos-sync ~/$hostname


    # --------------------------------------------
    # Coloca las fechas en las que no tengan
    # --------------------------------------------

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

    # --------------------------------------------
    # Desmonta la unidad
    # --------------------------------------------
    fusermount -zu ~/$hostname
    rmdir ~/$hostname
fi
