#!/bin/bash

###################################################################
#Script Name: sherloflix.sh
#Description: Montaje de Sherloflix en el NAS con rclone y limpieza
#Args: N/A
#Creation/Update: 20210217/20210217
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

# Monta la unidad remota en el NAS
rclone mount Onedrive_UN_en: /var/services/video/Sherloflix --allow-other --config=/var/services/homes/sherlockes/.config/rclone/rclone.conf --daemon

# Mueve las películas de la carpeta 00_mover del NAS a la unidad remota
rclone move -P --delete-empty-src-dirs /var/services/video/Peliculas/00_mover/ Onedrive_UN_en:/pelis --config=/var/services/homes/sherlockes/.config/rclone/rclone.conf

# Mueve las series de la carpeta 00_mover del NAS a la unidad remota y borra las carpetas vacías
rclone moveto -P /var/services/video/Series/00_mover/ Onedrive_UN_en:/series --config=/var/services/homes/sherlockes/.config/rclone/rclone.conf
find /var/services/video/Series/00_mover/* -empty -type d -delete



