#!/bin/bash
# -*- encoding: utf-8 -*-

###################################################################
#Script Name: pidiario.sh
#Description: - Actualiza Hugo
#             - Sincroniza la carpeta SherloScripts
#             - Actualiza los repos de GitHubsincroniza nubes
#             - Comprueba el estado de varias nubes públicas
#             - Sincroniza las nubes de Sherloflix
#Args: N/A
#Creation/Update: 20200521/20200927
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

# ---------------------------------------------------------
# Actualiza hugo rclone si es necesario
# ---------------------------------------------------------
. /home/pi/SherloScripts/bash/hugo.sh
. /home/pi/SherloScripts/bash/rclone.sh && rclone_check

# ---------------------------------------------------------
# SherloScripts - Copia las carpeta de Google Drive
# ---------------------------------------------------------
rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/

#rclone copy -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/
#rclone sync -v Sherlockes_GD:/SherloScripts/bash/ /home/pi/SherloScripts/bash/
#rclone sync -v Sherlockes_GD:/SherloScripts/'google scripts'/ /home/pi/SherloScripts/'google scripts'/
#rclone sync -v Sherlockes_GD:/SherloScripts/hugo/ /home/pi/SherloScripts/hugo/
#rclone sync -v Sherlockes_GD:/SherloScripts/python/ /home/pi/SherloScripts/python/
#rclone sync -v Sherlockes_GD:/SherloScripts/upython/ /home/pi/SherloScripts/upython/

# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
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
##rclone sync Sherlockes78_UN_en: Onedrive_UN_en: --transfers 2 --tpslimit 8 --bwlimit 5M

#rclone sync Onedrive_UN_en: Sherlockes78_UN_en: --transfers 2 --tpslimit 8 --bwlimit 5M


exit 0