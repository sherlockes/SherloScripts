#!/bin/bash

###################################################################
# Script Name: hugo.sh
# Description: Instala y actualiza Hugo
# Args: N/A
# Creation/Update: 20191114/20240115
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

# Arquitectura del procesador
    arch=$(uname -m)
if [ $arch == 'aarch64' ]; then
        bits='arm64'
    elif [ $arch == 'x86_64' ]; then
        bits='amd64'
    else
	bits='arm-v7'	
    fi

hugo_check(){

    hugo_download_path="https://github.com/gohugoio/hugo/releases/download/"

    hugo_latest_path=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
	| grep "browser_download_url" \
	| grep "[Ll]inux" \
	| grep "${bits}" \
	| grep -v "hugo_extended" \
	| grep -v "arm64" \
	| grep "\.tar\.gz" \
	| cut -d ":" -f 2,3 \
	| tr -d \")

    echo $hugo_latest_path

    # Extrae el número de la última version disponible
    nombre_carpeta=$(basename $(dirname $hugo_latest_path))
    hugo_latest_ver="${nombre_carpeta:1}"
    echo "La última versión disponible es $hugo_latest_ver"

    if which hugo >/dev/null; then
	# Extrae el número de la versión de Hugo isntalada
	hugo_local_ver=$(hugo version | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')

	echo "Versión instalada $hugo_local_ver, última versión $hugo_latest_ver"

	if [ $hugo_local_ver == $hugo_latest_ver ]
	then
	    echo "hugo instalado y actualizado..."
	else
	    echo 'actualizando a hugo '$hugo_latest_ver
	    
	    if [[ -f ~/.local/bin/hugo ]] 
	    then 
		rm ~/.local/bin/hugo
	    else 
		sudo dpkg -P hugo
	    fi
	    
	    hugo_install
	fi
	
    else
	echo 'Hugo no está instalado...'
	hugo_install
    fi
}

hugo_install(){
    cd ~

    echo 'Comprobando el directorio ~/.local/bin...'
    mkdir -p ~/.local/bin

    echo 'Descargando la última versión de Hugo...'
    wget -q $hugo_latest_path

    
    # Busca el archivo *.tar.gz descargado
    instalador="$(find . -maxdepth 1 -name "hugo_*.tar.gz")"

    if [[ -n $instalador ]]
    then
	echo 'Descomprimiendo el instalador...'
	# Extrae el archivo "Hugo" a "~/.local/bin"
	tar -xzf $instalador -C ~/.local/bin hugo

	# Borra el archivo descargado
	rm $instalador
    fi

    # Comprueba si la ruta esta en el PATH
    if [[ -n $(echo $PATH | grep "$HOME/.local/bin") ]]
    then
	echo "La ruta $HOME/.local/bin está en el PATH"
    else
	echo "La ruta no está en el Path, se añade"
	PATH=$PATH:~/.local/bin
    fi
    
}

hugo_check
