#!/bin/bash

###########################################################################
# Script Name: Descarga de archivos desde una canal de Telegram
# Description:
# Creation/Update: 20210131/20210131
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf

rclone mount Sherlockes78_GD:Shd_Sherlockes78 ~/teledown/files --allow-other --daemon

cd ~/teledown/telegram-download-daemon

git pull origin master

cd ..

pip install -r telegram-download-daemon/requirements.txt

python3 delete.py

python3 telegram-download-daemon/telegram-download-daemon.py --api-id $api_id --api-hash $api_hash --channel $canal_descargas --dest ~/teledown/files --temp ~/teledown/files
#python3 telegram-download-daemon-old/telegram-download-daemon.py --api-id $api_id --api-hash $api_hash --channel $canal_descargas --dest ~/teledown/files --temp ~/teledown/temp

