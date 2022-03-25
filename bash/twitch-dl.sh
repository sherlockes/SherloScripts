#!/bin/bash

###################################################################
# Script Name: twitch-dl.sh
# Description: Instala, actualiza twith-dl
# Args: N/A
# Creation/Update: 20220325/20220325
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################


# -------------------------------------------------------
# Comprueba la instalación de Twitch-dl
# -------------------------------------------------------
check(){
    if [ ! -e ./twitch-dl.pyz ]; then
	echo "- No está instalado 'twitch-dl' en el directorio..."
	install
    else
	web_ver=$(curl -s https://api.github.com/repositories/118896446/releases/latest \
	    | grep "browser_download_url" | cut -d ":" -f 2,3 | tr -d \" \
	    | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	local_ver=$(python3 twitch-dl.pyz --version | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	# Versión instalada VS Versión disponible
	if [ $local_ver == $web_ver ]
	then
	    echo "- Twitch-dl instalado y actualizado"
	else
	    echo "- Actualizando a Twitch-dl $web_ver"
	    rm twitch-dl.pyz
	    install
	fi
			 
	
    fi
}

install(){
    echo "- Descargando la última versión de Twitch-dl"
    curl -s https://api.github.com/repositories/118896446/releases/latest \
	| grep "browser_download_url" | cut -d ":" -f 2,3 | tr -d \" | wget -qi -
    mv *.pyz twitch-dl.pyz
    chmod +x twitch-dl.pyz
    echo "- Twitch-dl instalado y actualizado"
}
