#!/bin/bash

###########################################################################
# Script Name: Descarga de archivos desde una canal de Telegram
# Description:
# Creation/Update: 20210131/20210219
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf

# Montaje de la unidad remota para la carpeta de descargas
#rclone mount Sherlockes78_GD:Shd_Sherlockes78 ~/teledown/files --allow-other --daemon

# Comprobación de las actualizaciones del servicio
cd ~/teledown/telegram-download-daemon
git pull origin master
cd ..
sudo pip3 install -r telegram-download-daemon/requirements.txt

# Borra los mensajes antigüos del canal de telegram de descargas
python3 delete.py

# Ejecuta el servicio de descargas
python3 telegram-download-daemon/telegram-download-daemon.py --api-id $api_id --api-hash $api_hash --channel $canal_descargas --dest ~/teledown/files --temp ~/teledown/temp

