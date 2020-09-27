#!/bin/bash
from time import sleep

TOKEN="931043591:AAGzY_sw2Ucadmqn0nfKQPDYzc5mQEAOqvA"
CHAT_ID="-1001306695790"
MESSAGE="Hello World"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

while [ 1 ];
do

    ruta_anterior=`cat ruta.sh`
    archivo=$(curl -s https://educa.aragon.es/-/adjudicacion_semanal_sec|grep "INF-ACT-COM-LISTA-ADJUDICADOS-ALFABETICO*"|cut -d " " -f 2|cut -c 7-|rev|cut -c 2-|rev)
    path="https://educa.aragon.es"
    ruta="$path$archivo"
    echo "$ruta" > "ruta.sh"
    if [[ "$ruta" == "$ruta_anterior" ]]
    then
        MESSAGE="Paciencia..."
    else
        MESSAGE="Se ha actualizado¡¡¡"
        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
    fi
    sleep 300  
done


