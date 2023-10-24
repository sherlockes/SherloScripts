#!/bin/bash

###################################################################
#Script Name: test-online.sh
#Description: Comprueba que dispositivos estan online a partir del ssh config
#Args: N/A
#Creation/Update: 20230206/20231024
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

# Envio de mensaje de telegram
notificacion=~/SherloScripts/bash/telegram.sh
inicio=$( date +%s )

# Colores para el texto
RED='\033[0;31m'
GREEN='\x1b[32m'
NOCOLOR='\033[0m'

# Ruta a config ssh
ssh_config_ruta="$HOME/.ssh/config"

# Rango de asignación de Zerotier
ZERO_RANGE='192.168.191'

# Rangos de IP' y máquinas de salto
RANGE_1='192.168.10'
JUMP_1=rpiz
RANGE_2='192.168.1'
JUMP_2=rpi5oz

# Todo está correcto
TODO_OK=true

# Texto para enviar el mensaje
mensaje=$'Comprobación de dispositivos online mediante <a href="https://raw.githubusercontent.com/sherlockes/SherloScripts/master/bash/test-online.sh">test-online.sh</a>\n'
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'

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
# Recibe los parámetros INI y FIN que son las horas a las que el aparato se
# enciende y apaga todos los días. La función devuelve 0 en caso de que a la
# hora en que se la llame esté dentro de este horario

comprobar_horario () {

    AHORA=$(date +%H)
    INI=$1
    FIN=$2

    if [ $FIN -gt $INI ] && [ $INI -lt $AHORA ] && [ $AHORA -lt $FIN ]; then
	return 0
    elif [ $FIN -lt $INI ] && [ $AHORA -lt $FIN ]; then
	return 0
    elif [ $FIN -lt $INI ] && [ $AHORA -gt $INI ]; then
	return 0
    else
	return 1
    fi
    
}

################################
####    Script principal    ####
################################

# Colocer la IP local y el rango
LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+')
LOCAL_RANGE=$(echo $LOCAL_IP | cut -f1-3 -d".")

# Lectura por líneas del archivo ssh_config_ruta
while read -r line; do
    IFS=' '
    read -ra newarr <<< "$line"

    # La primera palabra de la línea deberá ser "Host"
    if [ "${newarr[0]}" = 'Host' ]; then

	# El nombre del "Host" es la segunda palabra de la línea
	nombre="${newarr[1]}"

	# El horario de encendido/apagado es la última palabra
	HORARIO="${newarr[-1]}"
	HORA_INI=$(echo "$HORARIO" | cut -d '-' -f 1)
	HORA_FIN=$(echo "$HORARIO" | cut -d '-' -f 2)
    fi

    if [ "${newarr[0]}" = 'Hostname' ] && comprobar_horario $HORA_INI $HORA_FIN; then
		
	REMOTE_IP="${newarr[1]}"
	REMOTE_RANGE=$(echo $REMOTE_IP | cut -f1-3 -d".")
	
	if [ $REMOTE_RANGE = $ZERO_RANGE ] ; then
	    # El rango de IP corresponde a un cliente de Zerotier
	    if ping -c 1 $REMOTE_IP &> /dev/null ; then
		echo -e "$nombre (Zerotier) ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		mensaje+=$"$nombre (Zerotier) OK @ $REMOTE_IP"
	    else
		# Espera 5 sg para hacer un segundo intento
		sleep 5
		 if ping -c 1 $REMOTE_IP &> /dev/null ; then
		     echo -e "$nombre (Zerotier) ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		     mensaje+=$"$nombre (Zerotier) OK @ $REMOTE_IP"
		 else
		     echo -e "$nombre (Zerotier) ${RED}KO${NOCOLOR} @ $REMOTE_IP"
		     mensaje+=$"$nombre (Zerotier) KO @ $REMOTE_IP --- ATENCION ---"
		     TODO_OK=false
		 fi
	    fi
	    mensaje+=$'\n'
	elif [ $REMOTE_RANGE = $LOCAL_RANGE ] ; then
	    # El rango corresponde a una IP local
	    if ping -c 1 $REMOTE_IP &> /dev/null ; then
		echo -e "$nombre ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		mensaje+=$"$nombre OK @ $REMOTE_IP"
	    else
		# Espera 5 sg para hacer un segundo intento
		sleep 5
		if ping -c 1 $REMOTE_IP &> /dev/null ; then
		   echo -e "$nombre ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		   mensaje+=$"$nombre OK @ $REMOTE_IP"
		else
		   echo -e "$nombre ${RED}KO${NOCOLOR} @ $REMOTE_IP"
		   mensaje+=$"$nombre KO @ $REMOTE_IP --- ATENCION ---"
		   TODO_OK=false
		fi
	    fi
	    mensaje+=$'\n'
	elif [ $REMOTE_RANGE != $LOCAL_RANGE ] ; then
	    # El rango corresponde a una IP remota
	    if ssh rpi5oz "ping -c 1 $REMOTE_IP" &< /dev/null ; then
		echo -e "$nombre ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		mensaje+=$"$nombre OK @ $REMOTE_IP"
	    else
		# Espera 5 sg para hacer un segundo intento
		sleep 5
		if ssh rpi5oz "ping -c 1 $REMOTE_IP" &< /dev/null ; then
		    echo -e "$nombre ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		    mensaje+=$"$nombre OK @ $REMOTE_IP"
		else
		    echo -e "$nombre ${RED}KO${NOCOLOR} @ $REMOTE_IP"
		    mensaje+=$"$nombre KO @ $REMOTE_IP --- ATENCION ---"
		    TODO_OK=false
		fi
	    fi
	    mensaje+=$'\n'	
	fi
    fi
done <$ssh_config_ruta

# Envia el mensaje de telegram con el resultado si algo ha fallado
if ! $TODO_OK ; then
    fin=$( date +%s )
    let duracion=$fin-$inicio
    mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'
    mensaje+=$"Duración del Script:  $duracion segundos"
    $notificacion "$mensaje"
fi

exit 0
