#!/bin/bash

###################################################################
# Script Name: rclone.sh
# Description: Instala, actualiza y copia configuración de rclone
# Args: N/A
# Creation/Update: 20200429/20200430
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

bits=$(getconf LONG_BIT)
if [ $bits == '64' ]
then
    bits='amd64'
else
    bits='arm'
fi

rclone_check(){
    if which rclone >/dev/null; then
	echo 'Comprobando la versión instalada de Rclone...'
	rclone_local_ver=$(rclone version | head -1 | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	echo 'Versión instalada '$rclone_local_ver' de Rclone, comprobando versión web...'
			
	rclone_web_ver=$(curl -s https://api.github.com/repositories/17803236/releases/latest \
	    | grep "browser_download_url.*rclone-[^extended].*-linux-${bits}\.deb" \
    | cut -d ":" -f 2,3 \
    | tr -d \" \
    | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	if [ $rclone_local_ver == $rclone_web_ver ]
	then
	    echo "Su versión está actualizada"
	else
	    echo 'Actualizando a la versión '$rclone_web_ver
	    sudo dpkg -P hugo
	    rclone_install
	fi

	
    else
	rclone_install
    fi
}

rclone_install(){
    echo 'Descargando la última versión de Rclone'
	curl -s https://api.github.com/repositories/17803236/releases/latest \
	    | grep "browser_download_url.*rclone-[^extended].*-linux-${bits}\.deb" \
	    | cut -d ":" -f 2,3 \
	    | tr -d \" \
	    | wget -qi -
	
	installer="$(find . -name "*linux-${bits}.deb")"
	echo $installer
	echo 'Instalando Rclone'
	sudo dpkg -i $installer
	rm $installer
}


rclone_check
