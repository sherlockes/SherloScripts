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

echo "Enlazando la configuración de emacs..."
ln -sf ~/dotfiles/emacs/.emacs_home ~/.emacs

echo "Enlazando la configuración de Rclone..."
ln -sf ~/dotfiles/rclone/rclone.conf ~/.config/rclone/rclone.conf

echo "Enlazando la configuración de Gphotos-Sync..."
ln -sf ~/dotfiles/gphotos-sync/client_secret.json ~/.config/gphotos-sync/client_secret.json

echo "Enlazando la configuración de Gspread..."
ln -sf ~/dotfiles/gspread/service_account.json ~/.config/gspread/service_account.json

