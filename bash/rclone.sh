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
	rclone_local_ver=$(rclone version | head -1 | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')
	rclone_web_ver=$(curl -s https://api.github.com/repositories/17803236/releases/latest \
	    | grep "browser_download_url.*rclone-[^extended].*-linux-${bits}\.deb" \
    | cut -d ":" -f 2,3 \
    | tr -d \" \
    | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	if [ $rclone_local_ver == $rclone_web_ver ]
	then
	    echo "rclone instalado y actualizado..."
	else
	    echo 'actualizando a rclone '$rclone_web_ver
	    sudo dpkg -P hugo
	    rclone_install
	fi
	
    else
	echo 'instalando rclone...'
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
	sudo dpkg -i $installer
	rm $installer
}
