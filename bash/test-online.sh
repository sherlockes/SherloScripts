#!/bin/bash

###################################################################
#Script Name: test-online.sh
#Description: Comprueba que dispositivos estan online a partir del ssh config
#Args: N/A
#Creation/Update: 20230206/20230206
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

ssh_config_ruta="$HOME/.ssh/config"
ssh_config=$(cat $ssh_config_ruta)


################################
####      Dependencias      ####
################################

# Crea la RUTA de descarga si no existe
#if [[ ! -e $RUTA ]]; then mkdir $RUTA; fi

# Instala xmllint si no está disponible
#if ! which xmllint >/dev/null; then sudo apt install -y libxml2-utils; fi


################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################


# Colocer la IP local y el rango
LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+')
LOCAL_RANGE=$(echo $LOCAL_IP | cut -f1-3 -d".")

ZERO_RANGE='192.168.191'

while read -r line; do
    IFS=' '
    read -ra newarr <<< "$line"
    
    if [ "${newarr[0]}" = 'Host' ]; then
	
	nombre="${newarr[1]}"
    fi

    if [ "${newarr[0]}" = 'Hostname' ]; then
	
	REMOTE_IP="${newarr[1]}"
	REMOTE_RANGE=$(echo $REMOTE_IP | cut -f1-3 -d".")

	echo $REMOTE_RANGE
	echo $LOCAL_RANGE
	
	if [ $REMOTE_RANGE = $LOCAL_RANGE ] || [ $REMOTE_RANGE = $ZERO_RANGE ] ; then
	    if ping -c 1 $REMOTE_IP &> /dev/null
	    then
		echo "Conexión exitosa a $nombre"
	    else
		echo "Error de conexión a $nombre"
	    fi
	fi
    fi
    
done <$ssh_config_ruta
