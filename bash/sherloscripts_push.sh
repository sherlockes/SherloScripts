#!/bin/bash
# -*- encoding: utf-8 -*-

###################################################################
#Script Name: sherloscripts_push.sh
#Description: Sube los cambios en Sherloscript al repositorio y 
#             sincroniza nubes 
#Args: N/A
#Creation/Update: 20200521/20200927
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

# ---------------------------------------------------------
# Actualiza hugo si es necesario
# ---------------------------------------------------------
cd SherloScripts/bash
./hugo.sh


# ---------------------------------------------------------
# Copia la carpeta de Google Drive a /home/pi/SherloScripts
# ---------------------------------------------------------
rclone copy -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/
rclone sync -v Sherlockes_GD:/SherloScripts/bash/ /home/pi/SherloScripts/bash/
rclone sync -v Sherlockes_GD:/SherloScripts/'google scripts'/ /home/pi/SherloScripts/'google scripts'/
rclone sync -v Sherlockes_GD:/SherloScripts/hugo/ /home/pi/SherloScripts/hugo/
rclone sync -v Sherlockes_GD:/SherloScripts/python/ /home/pi/SherloScripts/python/
rclone sync -v Sherlockes_GD:/SherloScripts/upython/ /home/pi/SherloScripts/upython/

# ---------------------------------------------------------
# Actualiza los repositorios de GitHub
# ---------------------------------------------------------
repo=(SherloScripts sherblog)
for i in "${repo[@]}"
do
    echo "Actualizando el repositorio $i"
    cd ~/$i

    git add --all
    git commit -m "Update"
    git push
done


# --------------------------------------------------------------
# Comprueba el estado de las distintas nubes públicas
# --------------------------------------------------------------

unidades=(Onedrive_UN_en Sherlockes78_UN_en)

notificacion=~/SherloScripts/bash/telegram.sh

for u in "${unidades[@]}"
do
    rclone -v size $u:

    if [ $? -eq 0 ]; then
	echo "OK"
    else
	echo "KO"
    $notificacion "Hay un erro de conexión con $u"
    fi
done

# --------------------------------------------------------------
# Sincroniza Sherloflix con la unidad compartida de Sherlockes78
# --------------------------------------------------------------
#rclone sync Sherlockes78_UN_en: Onedrive_UN_en: --transfers 2 --tpslimit 8 --bwlimit 5M
rclone sync Onedrive_UN_en: Sherlockes78_UN_en: --transfers 2 --tpslimit 8 --bwlimit 5M


exit 0
