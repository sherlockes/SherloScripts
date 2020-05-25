#!/bin/bash

###################################################################
# Script Name: rclone.sh
# Description: Instala, actualiza y copia configuración de rclone
# Args: N/A
# Creation/Update: 20200429/20200430
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
	bits='arm'
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
