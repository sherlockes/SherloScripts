#!/bin/bash

###################################################################
# Script Name: rclone.sh
# Description: Instala, actualiza y copia configuración de rclone
# Args: N/A
# Creation/Update: 20200429/20230315
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################


# -------------------------------------------------------
# Comprueba la instalación de Rclone
# -------------------------------------------------------
rclone_check(){

    # Arquitectura del procesador
    bits=$(getconf LONG_BIT)
    if [ $bits == '64' ];
    then
	bits='amd64'
    else
	bits='arm-v7'
    fi

    # Comprueba si Rclone está instalado
    if which rclone >/dev/null; then
	# Versión de Rclone instalada
	rclone_local_ver=$(rclone version | head -1 | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	# Versión de Rclone disponble
	rclone_web_ver=$(curl -s https://api.github.com/repositories/17803236/releases/latest \
	    | grep "browser_download_url.*rclone-[^extended].*-linux-${bits}\.deb" \
    | cut -d ":" -f 2,3 \
    | tr -d \" \
    | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	# Versión instalada VS Versión disponible
	if [ $rclone_local_ver == $rclone_web_ver ]
	then
	    echo "rclone instalado y actualizado..."
	else
	    echo 'actualizando a rclone '$rclone_web_ver
	    sudo dpkg -P rclone
	    rclone_install
	fi
	
    else
	# Instala Rclone si no está instalado
	echo 'instalando rclone...'
	rclone_install
    fi
}


# -------------------------------------------------------
# Comprueba el estado de las unidades remotas
# -------------------------------------------------------
rclone_test_remotes(){
    local remotos=( $(rclone listremotes) )
    for remoto in "${remotos[@]}"
    do
	# Le quitamos los ":" al final de la cadena
	remoto=${remoto%?}

	if [$remoto -eq "Sherlockes_Gphotos"]; then
	    continue
	fi

	rclone mkdir $remoto:test

	if [ $? -eq 0 ]; then
	    echo "Es posible crear un directorio en $remoto"
	    rclone rmdir $remoto:test
	else
	    echo "No es posible crear un directorio en $remoto"
	fi
    done
    exit
}


# -------------------------------------------------------
# Realiza la instalación de Rclone
# -------------------------------------------------------

rclone_install(){
    echo 'Descargando la última versión de Rclone'
	curl -s https://api.github.com/repositories/17803236/releases/latest \
	    | grep "browser_download_url.*rclone-[^extended].*-linux-${bits}\.deb" \
	    | cut -d ":" -f 2,3 \
	    | tr -d \" \
	    | wget -qi -
	
	installer="$(find . -name "*linux-${bits}.deb")"
	sudo dpkg -i $installer
	rm $installer
}

# -------------------------------------------
# Propagación del archivo de config de rclone
# -------------------------------------------

rclone_config(){
    clear
    echo "------------------------------------------------"	
    echo "--------------  www.sherblog.pro  --------------"
    echo "------------------------------------------------"
    echo "-- Actualizar la config remota de Rclone..."

    # Ubicaciones de archivos de configuración local, remoto y copia de seguridad
    LOCAL_CON=$(rclone config file | tail -1)
    REMOTE_CON="Sherlockes_GD:dotfiles/rclone/rclone.conf"
    BKP_CON="Sherlockes_GD:dotfiles/rclone/rclone($(date '+%Y%m%d')bkp).conf"

    # Comprueba si el archivo de configuración es un enlace simbólico
    if [ -h $LOCAL_CON ]; then
	echo "-- La configuración no ha sido modificada."
	sleep 2
	return
    fi

    # Calcula las antigüedades de los archivos
    echo 'Calculando antigüedades de los archivos...'
    DATE_LOCAL_CON=`echo $(rclone lsl $LOCAL_CON) | cut -d ' ' -f 2,3 | xargs -i date -d {} "+%s"`
    DATE_REMOTE_CON=`echo $(rclone lsl $REMOTE_CON) | cut -d ' ' -f 2,3 | xargs -i date -d {} "+%s"`
    
    if (( $DATE_REMOTE_CON > $DATE_LOCAL_CON )); then
	echo "-- Config remota más reciente, no se va a propagar."
    else
	read -p "El archivo local es mayor, quieres propaparlo? (si/no) " yn

	case $yn in 
	    si ) rclone_config_propagate ;;
	    * )  exit;;
	esac
    fi

    # Si existe la carpeta "Dotfiles" cambia el archivo por un enlace simbólico
    if [ -d ~/dotfiles/rclone/ ]; then
	echo "-- Actualizando Dotfiles locales..."
	cp $LOCAL_CON ~/dotfiles/rclone/rclone.conf
	echo "-- Creando el enlace con los Dotfiles"
	ln -sf ~/dotfiles/rclone/rclone.conf $LOCAL_CON
    fi
}

rclone_config_propagate(){
    echo "-- Guardando backup remoto y actualizando..."
    rclone copyto $REMOTE_CON $BKP_CON
    rclone copyto $LOCAL_CON $REMOTE_CON
}


# -------------------------------------------------------
# Lista las nubes de /.config/rclone/rclone.conf
# -------------------------------------------------------

rclone_list(){
    clear
    echo "------------------------------------------------"	
    echo "--------------  www.sherblog.pro  --------------"
    echo "------------------------------------------------"

    rclone_remotes=($(rclone listremotes | cut -d ":" -f 1))
    
    local x=1
    for i in "${rclone_remotes[@]}"
    do
	if rclone_montado ${i};
	then
	    estado="\e[32m(Montar)\e[0m"
	else
	    estado="\e[31m(Desmontar)\e[0m"
	fi
	
	echo -e "-- $x. ${i} $estado"
	((x+=1))
    done
    echo "-- $x. Volver"
    echo "------------------------------------------------"

    read -p "Selecciona una opción [ 1 - $((${#rclone_remotes[@]} + 1))] " choice
    if (($choice < $((${#rclone_remotes[@]} + 1))));then
	rclone_des_montar "${rclone_remotes[$((choice - 1))]}"
    fi
}


# -------------------------------------------------------
# Función para comprobar si la unidad está montada
# -------------------------------------------------------
rclone_montado (){
    local carpeta=$HOME"/clouds/$1"
    if [ ! -x $carpeta ]
    then
	# La carpeta no existe
	return 0
    else
	# La carpeta existe
	if mount | grep $carpeta > /dev/null; then
	    # La carpeta está montada
	    return 1
	else
	    # La carpeta no está montada
	    return 0
	fi
    fi
}

# -------------------------------------------------------
# Función de montaje y desmontaje de unidades
# -------------------------------------------------------
rclone_des_montar(){
    local carpeta=$HOME"/clouds/$1"
    
    if rclone_montado $1;
    then
	# Acción si la carpeta está desmontada
        echo "Montando $1..."
        mkdir $carpeta
	eval "rclone mount $1: $carpeta --allow-other --daemon"
    else
        echo "Desmontando $1..."
	fusermount -u $carpeta
        rm -rf $carpeta
    fi
    sleep 2
    rclone_list
}
