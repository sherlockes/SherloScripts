#!/bin/bash

###################################################################
#Script Name: sherloflix.sh
#Description: Montaje de Sherloflix en el NAS con rclone y limpieza
#Args: N/A
#Creation/Update: 20210217/20210814
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

sherloflix="Onedrive_UN_en"
sherloflix_path="/volume1/video/Sherloflix"
conf_path="/var/services/homes/sherlockes/.config/rclone/rclone.conf"
series_path="/volume1/video/Series/00_mover"
pelis_path="/volume1/video/Peliculas/00_mover"

echo "---- Script para montar y archivar peli y series en sherloflix ----"

# Moviendo las series de la carpeta 00_mover a la nube
echo "1.- Archivando series ya visualizadas...."

cd $series_path

for i in * ; do
    echo "$i"
    if [ -d "$i" ]; then
	echo "Moviendo ... $i"
	rclone move -P --config=$conf_path --delete-empty-src-dirs "$i"/ $sherloflix:/series/"$i"
    fi
done

find $series_path/* -empty -type d -delete

# Moviendo las pelis de la carpeta 00_mover a la nube
echo "2.- Archivando peliculas ya visualizadas...."

cd /volume1/video/Peliculas/00_mover

for i in * ; do
  if [ -f "$i" ]; then
      echo "Moviendo ... $i"
      rclone move -P --config=$conf_path "$i" $sherloflix:/pelis/"$i"
  fi
done

find $pelis_path/* -empty -type d -delete

# Monta la unidad remota en el NAS
echo "3.- Montando la unidad remota de $sherloflix como Sherloflix...."
rclone mount $sherloflix: $sherloflix_path --allow-other --config=$conf_path --daemon




