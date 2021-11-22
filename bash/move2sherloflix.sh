#!/bin/bash

###########################################################################
# Script Name: move2sherloflix.sh
# Description: Busca archivo y carpetas para suber a la nube de sherloflix
# Creation/Update: 20210428/20210814
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

sherloflix="Onedrive_UN_en"
conf_path="/var/services/homes/sherlockes/.config/rclone/rclone.conf"

echo "---- Script para mover películas y series ----"

# Moviendo las series de la carpeta 00_mover a la nube
echo "1.- Moviendo series...."

cd /volume1/video/Series/00_mover

for i in * ; do
    echo "$i"
    if [ -d "$i" ]; then
	echo "Moviendo ... $i"
        rclone move -P --config=$conf_path --delete-empty-src-dirs "$i"/ $sherloflix:/series/"$i"
    fi
done


# Moviendo las pelis de la carpeta 00_mover a la nube
echo "2.- Moviendo peliculas...."

cd /volume1/video/Peliculas/00_mover

for i in * ; do
  if [ -f "$i" ]; then
      echo "Moviendo ... $i"
      rclone move -P --config=$conf_path "$i" $sherloflix:/pelis/"$i"
  fi
done
