#!/bin/bash

###################################################################
# Script Name: photos-gsync.sh
# Description: Copia de suguridad de Google Photos
# Args: N/A
# Creation/Update: 20201211/20201211
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

lista=(Onedrive_UN_en dd_gdu)

notificacion=~/SherloScripts/bash/telegram.sh

origen=$(rclone config file | cut -d ":" -f 2)


for u in "${lista[@]}"
do
    rclone -v size $u:

    if [ $? -eq 0 ]; then
	echo "OK"
    else
	echo "KO"
    $notificacion "Hay un erro de conexión con $u"
    fi
done
