#!/bin/bash

###########################################################################
# Script Name: teledown_move.sh 
# Description: Mueve los archivos descargados de la raspberry al NAS
# Creation/Update: 20210228/20210310
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

Nas_lan_ip='192.168.1.200'
destino='nas:/var/services/video/00_temp/'
mensaje=$'Moviendo archivos descargados al NAS...\n'
notificacion=~/SherloScripts/bash/telegram.sh

comprobar(){
    if [ $1 -eq 0 ]; then
	mensaje+=$'OK'
    else
	mensaje+=$'ERROR'
    fi
    mensaje+=$'\n'
}

# Comprueba si hay archivos en la carpeta ORIGEN
if [ "$(ls -A ~/teledown/files)" ]; then
     # Comprueba si el NAS está encendido
    status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 sherlockes@$Nas_lan_ip echo ok 2>&1)

    if [[ $status == ok ]] ; then
	echo 'Acceso al NAS, copiando...'

	for file in ~/teledown/files/*; do
	    nombre=$(echo "$file" | sed "s/.*\///")
	    mensaje+="Copiando $nombre ... "
	    scp "$file" $destino
	    comprobar $?
	    mensaje+="Borrando $nombre ... "
	    rm "$file"
	    comprobar $?
	done
	$notificacion "$mensaje"
    else
	echo 'No hay acceso al NAS...'
    fi
else
    echo 'No hay archivos para copiar...'
fi




