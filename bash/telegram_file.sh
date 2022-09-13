#!/bin/bash

###########################################################################
# Script Name: Envío de un archivo a un canal de telegram
# Description:
#  - A partir de un archivo de configuración, ubicado en el directorio raiz
#    del usuario, envía un archivo a un canal de Telegram
#  - El archivo "config.conf" constará de
#        TOKEN="xxxxxxxxxxxxxxxxxxxxxxx"
#        CHAT_ID="-167687696987674433"
#        Archivo="/home/pi/config.conf"
# Args:
#  - Ubicación del archivo a enviar
# Creation/Update: 20220901/20220913
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf

# Ajusta el mensaje al parámetro que se le ha pasado al script
ARCHIVO="$1"

# Si no hay parámetros se coge el mensaje por defecto del archivo de configuración.
if [ $# -eq 0 ]; then
    ARCHIVO=$Archivo
fi

URL="https://api.telegram.org/bot$TOKEN/sendDocument"

curl -F document=@$Archivo https://api.telegram.org/bot$TOKEN/sendDocument?chat_id=$CHAT_ID


