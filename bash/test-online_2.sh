#!/bin/bash

###################################################################
#Script Name: test-online.sh
#Description: Comprueba que dispositivos estan online a partir del ssh config
#Args: N/A
#Creation/Update: 20230206/20250809
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

comprobar_horario_bak () {

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


comprobar_horario() {
    local ini="$1"
    local fin="$2"
    local hora_actual
    hora_actual=$(date +%H)

    # Si alguno no es numérico, fuera de horario
    [[ "$ini" =~ ^[0-9]+$ && "$fin" =~ ^[0-9]+$ ]] || return 1

    if (( ini <= fin )); then
        # Rango normal, ej: 8-14
        (( hora_actual >= ini && hora_actual < fin )) && return 0 || return 1
    else
        # Rango que cruza medianoche, ej: 22-2
        (( hora_actual >= ini || hora_actual < fin )) && return 0 || return 1
    fi
}


################################
####    Script principal    ####
################################


# Colocer la IP local y el rango
LOCAL_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+')
LOCAL_RANGE=$(echo $LOCAL_IP | cut -f1-3 -d".")



while read -r line; do
    IFS=' '
    read -ra newarr <<< "$line"
    
    if [ "${newarr[0]}" = 'Host' ]; then
	
	nombre="${newarr[1]}"
	echo $nombre

	HORARIO="${newarr[-1]}"
	HORA_INI=$(echo "$HORARIO" | cut -d '-' -f 1)
	HORA_FIN=$(echo "$HORARIO" | cut -d '-' -f 2)

	resultado="$(comprobar_horario "$HORA_INI" "$HORA_FIN")"
	echo "La función devolvió: $resultado"

	
    fi

    if [ "${newarr[0]}" = 'Hostname' ] && comprobar_horario $HORA_INI $HORA_FIN; then
		
	REMOTE_IP="${newarr[1]}"
	REMOTE_RANGE=$(echo $REMOTE_IP | cut -f1-3 -d".")
	
	if [ $REMOTE_RANGE = $ZERO_RANGE ] ; then
	    if ping -c 1 $REMOTE_IP &> /dev/null
	    then
		echo -e "$nombre (Zerotier) is ${GREEN}OK${NOCOLOR} @ $REMOTE_IP"
		mensaje+=$"$nombre (Zerotier) is OK @ $REMOTE_IP"
	    else
		echo -e "$nombre (Zerotier) is ${RED}KO${NOCOLOR} @ $REMOTE_IP"
		mensaje+=$"$nombre (Zerotier) is KO @ $REMOTE_IP --- ATENCION ---"
		TODO_OK=false
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
    #$notificacion "$mensaje"
fi

exit 0
