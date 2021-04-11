#!/bin/bash

###################################################################
# Script Name: host.sh
# Description: Monta "host" en la carpeta ~/hostname mediante sshfs
# Args: N/A
# Creation/Update: 20201016/20210113
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

host=pi@192.168.191.204
hostname=rpi5o

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
    echo "No es posible el acceso a $host"
    exit
fi

# --------------------------------------------
# Crea la carpeta y monta la unidad
# --------------------------------------------
mkdir ~/$hostname
sshfs $host:/home/pi ~/$hostname

# --------------------------------------------
# Desmonta la unidad y borra la carpeta
# --------------------------------------------
read -p "La unidad esta montada en home/$hostname pulsa una tecla para desmontarla. " -n1 -s
clear
fusermount -u ~/$hostname
rmdir ~/$hostname

