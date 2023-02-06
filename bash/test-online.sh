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


# for line in $ssh_config
# do
#     echo -e "$line\n"
# done

number=1

while read -r line; do
    IFS=' '
    read -ra newarr <<< "$line"
    
    if [ "${newarr[0]}" = 'Host' ]; then
	
	nombre="${newarr[1]}"
    fi

    if [ "${newarr[0]}" = 'Hostname' ]; then
	
	hostname="${newarr[1]}"

	if ping -c 1 $hostname &> /dev/null
	then
	    echo "Conexión exitosa a $nombre"
	else
	    echo "Error de conexión a $nombre"
	fi
	
    fi
    
done <$ssh_config_ruta
