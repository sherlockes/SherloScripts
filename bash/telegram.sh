#!/bin/bash

###########################################################################
# Script Name: Envío de mansaje a un canal de telegram
# Description:
#  - A partir de un archivo de configuración, ubicado en el directorio raiz
#    del usuario, envía un mensaje a un canal de Telegram
#  - El archivo "config.conf" constará de
#        TOKEN="xxxxxxxxxxxxxxxxxxxxxxx"
#        CHAT_ID="-167687696987674433"
#        Mensaje="Mensaje vacío de Telegram"
# Args:
#  - Mensaje a enviar
# Creation/Update: 20201015/20201015
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf

# Ajusta el mensaje al parámetro que se le ha pasado al script
MESSAGE="$1"

# Si no hay parámetros se coge el mensaje por defecto del archivo de configuración.
if [ $# -eq 0 ]; then
    MESSAGE=$Mensaje
fi

URL="https://api.telegram.org/bot$TOKEN/sendMessage?parse_mode=html"

curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"

#curl --data chat_id="$CHAT_ID" --data-urlencode "text=${$1}" "https://api.telegram.org/bot$TOKEN/sendMessage?parse_mode=HTML"
