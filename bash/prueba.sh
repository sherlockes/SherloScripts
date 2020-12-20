#!/bin/bash

###################################################################
# Script Name: photos-gsync.sh
# Description: Copia de suguridad de Google Photos
# Args: N/A
# Creation/Update: 20201211/20201211
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

lista=(pi@192.168.1.203 sherlockes@192.168.1.200)

origen=$(rclone config file | cut -d ":" -f 2)

#scp $origen $destino

for u in "${lista[@]}"
do
    # Extrae ruta del archivo de configuración
    destino=$(ssh $u rclone config file | cut -d ":" -f 2 | rev | cut -d "/" -f2-8 | rev )
    # Quita el primer carácter en blanco y añade la barra
    destino="${destino:1}/"
    scp $origen $u:$destino
done


rclone copy $origen Sherlockes_GD:'Mis cosas'