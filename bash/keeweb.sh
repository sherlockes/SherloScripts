#!/bin/bash

###################################################################
# Script Name: keeweb.sh
# Description: Instala Keeweb
# Args: N/A
# Creation/Update: 20201001/20201001
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

echo 'Descargando la última versión de Hugo...'

#curl -L https://api.github.com/repos/gohugoio/hugo/releases/latest \
#| grep "browser_download_url.*hugo_[^extended].*_Linux-${bits}\.deb" \
#| cut -d ":" -f 2,3 \
#| tr -d \" \
#| wget -qi -
#installer="$(find . -name "*Linux-${bits}.deb")"
#sudo dpkg -i $installer
#rm $installer

curl -s https://github.com/keeweb/keeweb/releases/latest
