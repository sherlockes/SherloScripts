#!/bin/bash

###########################################################################
#Script Name: Actualización de Hugo
#Description: Comprueba e instala si es necesario la última versión de Hugo
#Args: N/A
#Creation/Update: 20191114/20191114
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
############################################################################

# ----------------------------------
# Definición de variables
# ----------------------------------
bits=$(getconf LONG_BIT)

# -----------------------------------
# Comprobación de versión local y web
# -----------------------------------
hugo_local_ver=$(hugo version | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

hugo_web_ver=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
    | grep "browser_download_url.*hugo_[^extended].*_Linux-${bits}bit\.deb" \
    | cut -d ":" -f 2,3 \
    | tr -d \" \
    | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

echo "Tiene instalada la versión $hugo_local_ver de Hugo y la última versión disponible es la $hugo_web_ver"

# -----------------------------------
# Actualizando si es necesario
# -----------------------------------

if [ $hugo_local_ver == $hugo_web_ver ]
then
    echo "Su versión está actualizada"
else
    echo "Actualizando a la última versión..."
    sudo dpkg -P hugo
    curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
	| grep "browser_download_url.*hugo_[^extended].*_Linux-64bit\.deb" \
	| cut -d ":" -f 2,3 \
	| tr -d \" \
	| wget -qi -
    installer="$(find . -name "*Linux-64bit.deb")"
    sudo dpkg -i $installer
    rm $installer
fi
