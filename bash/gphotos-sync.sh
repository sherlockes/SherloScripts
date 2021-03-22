#!/bin/bash

###################################################################
# Script Name: photos-gsync.sh
# Description: Copia de seguridad de Google Photos
# Args: N/A
# Creation/Update: 20201211/20210322
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
    #cd ~/$hostname
    #python3 -m pipenv run gphotos-sync ~/$hostname

    cd ~/gphotos-sync
    gphotos-sync ~/$hostname
    # --------------------------------------------
    # Desmonta la unidad
    # --------------------------------------------
    fusermount -zu ~/$hostname
    rmdir ~/$hostname
fi
