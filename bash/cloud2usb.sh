#!/bin/bash

###################################################################
#Script Name: cloud2usb.sh
#Description: Sincronizar nuve pública con usb externo conectado a raspberry
#Args: N/A
#Creation/Update: 20230119/20230119
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

PIN=18
CARPETA=~/usb_ext
NUBE="Sherlockes78_UN_en"

################################
####      Dependencias      ####
################################

# Comprobando la instalación de Rclone
source "$( dirname "${BASH_SOURCE[0]}" )/rclone.sh"
rclone_check


################################
####       Funciones        ####
################################
enciende(){
    # Enceder el relé
    echo $PIN > /sys/class/gpio/export
    sleep 1
    echo out > "/sys/class/gpio/gpio$PIN/direction"
    sleep 1
    echo 1 > "/sys/class/gpio/gpio$PIN/value"
    echo "El disco se ha encendido"

    # Montar la unidad
    sleep 20
    sudo mount /dev/sdb1 "$CARPETA/"
    echo "La unidad está montada"
}

apaga(){
    #Desmontamos la unidad
    sudo umount $CARPETA

    #Apagamos el disco
    echo 0 > "/sys/class/gpio/gpio$PIN/value"
    sleep 1

    #Eliminamos la entrada del puerto GPIO 18
    echo $PIN > /sys/class/gpio/unexport
}



################################
####    Script principal    ####
################################

enciende




# Sincronizar la carpeta y la unidad remota
timeout 3h rclone sync $NUBE: $CARPETA --transfers 2 --tpslimit 8 --bwlimit 10M -P


apaga


