#!/bin/bash

###################################################################
# Script Name: hugo.sh
# Description: Instala y actualiza Hugo
# Args: N/A
# Creation/Update: 20191114/20200502
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

bits=$(getconf LONG_BIT)
if [ $bits == '64' ]
then
    bits='64bit'
else
    bits='ARM'
fi

hugo_check(){
    if which hugo >/dev/null; then
	hugo_local_ver=$(hugo version | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')
	hugo_web_ver=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
			   | grep "browser_download_url.*hugo_[^extended].*_Linux-${bits}\.deb" \
			   | cut -d ":" -f 2,3 \
			   | tr -d \" \
			   | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	echo $hugo_local_ver
	echo $hugo_web_ver
	
	if [ $hugo_local_ver == $hugo_web_ver ]
	then
	    echo "hugo instalado y actualizado..."
	else
	    echo 'actualizando a hugo '$hugo_web_ver
	    sudo dpkg -P hugo
	    hugo_install
	fi
	
    else
	echo 'Hugo no está instalado...'
	hugo_install
    fi
}

hugo_install(){
    cd ~
    
    mkdir hugo_install
    cd hugo_install

    echo 'Descargando la última versión de Hugo...'
    curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
	| grep "browser_download_url" \
	| grep "[Ll]inux" \
	| grep "${bits}" \
	| grep -v "hugo_extended" \
	| cut -d ":" -f 2,3 \
	| tr -d \" \
	| wget -qi -

    
    instalador="$(find . -maxdepth 1 -name "hugo_*")"
    tar -xvzf $instalador

    ./hugo version
    #installer="$(find . -name "*Linux-${bits}.deb")"
    
    #sudo dpkg -i $installer
    #rm $installer
}

hugo_check
