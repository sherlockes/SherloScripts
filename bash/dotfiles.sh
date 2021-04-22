#!/bin/bash

###################################################################
# Script Name: dotfiles.sh
# Description: Crea enlaces a archivos de configuración guardados
# Args: N/A
# Creation/Update: 20210416/20210416
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

# Pide al usuario la carpeta origen
read -p 'Carpeta donde están guardados (relativa a la de usuario): ' carpeta

if [ $carpeta != 'dotfiles' ];then
    echo "Creando el enlace a la carpeta raiz..."
    ln -sf ~/"$carpeta" ~/dotfiles
fi

echo "Enlazando la configuración de ssh..."
ln -sf ~/dotfiles/ssh/config ~/.ssh/config



link_dotfile () {

    if [ -d "$2" ]; then
	echo "Enlazando la configuración de $1..."
	ln -sf $ORIGEN $DESTINO
    else
	echo "$1 no está instalado en el sistena."
    fi

}

# Configuracion de Emacs
NOMBRE="Emacs"
RUTA="~/.emacs.d/"
ORIGEN="~/dotfiles/emacs/.emacs_home"
DESTINO="~/.emacs"
link_dotfile $NOMBRE $RUTA $ORIGEN $DESTINO


# Configuracion de Gspread
NOMBRE="Gspread"
RUTA="~/.config/gspread/"
ORIGEN="~/dotfiles/gspread/service_account.json"
DESTINO="~/.config/gspread/service_account.json"
link_dotfile $NOMBRE $RUTA $ORIGEN $DESTINO

# Configuración de Gphotos-Sync
NOMBRE="Gphotos-Sync"
RUTA="~/.config/gphotos-sync/"
ORIGEN="~/dotfiles/gphotos-sync/client_secret.json"
DESTINO="~/.config/gphotos-sync/client_secret.json"
link_dotfile $NOMBRE $RUTA $ORIGEN $DESTINO

# Configuración de Rclone
NOMBRE="Rclone"
RUTA="~/.config/rclone/"
ORIGEN="~/dotfiles/rclone/rclone.conf"
DESTINO="~/.config/rclone/rclone.conf"
link_dotfile $NOMBRE $RUTA $ORIGEN $DESTINO

