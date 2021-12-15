#!/bin/bash

###################################################################
#Script Name: sherloflix.sh
#Description: Montaje de Sherloflix en el NAS con rclone y limpieza
#Args: N/A
#Creation/Update: 20210217/20211213
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

#sherloflix="Onedrive_UN_en"
sherloflix="Sherlockes78_UN_en"
sherloflix_path="/volume1/video/Sherloflix"
conf_path="/var/services/homes/sherlockes/.config/rclone/rclone.conf"
series_path="/volume1/video/Series/00_mover"
pelis_path="/volume1/video/Peliculas/00_mover"

echo "--------------------------------------------------------------------"
echo "---- Script para montar y archivar pelis y series en sherloflix ----"
echo "--------------------------------------------------------------------"

echo "0.- Esperando 30 sg..."
sleep 30

# Monta la unidad remota en el NAS
echo "1.- Montando la unidad remota de $sherloflix como Sherloflix...."
#rclone mount $sherloflix: $sherloflix_path --vfs-cache-mode full --allow-other --config=$conf_path --daemon
rclone mount $sherloflix: $sherloflix_path --read-only --allow-other --config=$conf_path --gid 33 --umask 0027 --allow-non-empty --daemon


# Moviendo las series de la carpeta 00_mover a la nube
echo "2.- Archivando series ya visualizadas...."

cd $series_path

for i in * ; do
    if [ -d "$i" ]; then
	    echo "Moviendo ... $i"
	    rclone move -P --config=$conf_path --delete-empty-src-dirs "$i"/ $sherloflix:/series/"$i"
    fi
done

find . -empty -type d -delete

# Moviendo las pelis de la carpeta 00_mover a la nube
echo "3.- Archivando peliculas ya visualizadas...."

cd $pelis_path

for i in * ; do
    if [ -f "$i" ]; then
        echo "Moviendo ... $i"
        rclone move -P --config=$conf_path "$i" $sherloflix:/pelis/"$i"
    fi
done

find . -empty -type d -delete


echo "4.- Script terminado"



