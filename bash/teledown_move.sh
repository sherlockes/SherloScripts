#!/bin/bash

###########################################################################
# Script Name: teledown_move.sh 
# Description: Mueve los archivos descargados de la raspberry al NAS
# Creation/Update: 20210228/20210228
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

Nas_lan_ip='192.168.1.200'

# --------------------------------------------
# Comprobar la instalación de sshfs
# (Montar carpetas remotas)
# --------------------------------------------
if which sshfs >/dev/null; then
    echo 'sshfs está instalado...'
else
    echo 'instalando sshfs...'
    sudo apt install sshfs
fi

# Comprueba si el NAS está encendido
status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 sherlockes@$Nas_lan_ip echo ok 2>&1)

if [[ $status == ok ]] ; then
    echo 'Acceso al NAS, copiando...'
    # --------------------------------------------
    # Crea la carpeta y monta la unidad
    # --------------------------------------------
    mkdir ~/teledown/nas
    sshfs sherlockes@192.168.1.200:/downloads/GD_Sherlockes78 ~/teledown/nas
    mv -v ~/teledown/files/* ~/teledown/nas
    fusermount -u ~/teledown/nas
    rmdir ~/teledown/nas
fi