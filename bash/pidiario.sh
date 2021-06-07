
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
#Creation/Update: 20200521/20210607
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

# ---------------------------------------------------------
# Actualiza hugo rclone si es necesario
# ---------------------------------------------------------
. /home/pi/SherloScripts/bash/hugo.sh
. /home/pi/SherloScripts/bash/rclone.sh && rclone_check

# ---------------------------------------------------------
# Google Drive - Sincronización de carpetas
# ---------------------------------------------------------
echo "Sincronizando la carpeta SherloScripts"
rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/ --exclude "/.git/**"
rclone sync -v Sherlockes_GD:/dotfiles/ /home/pi/dotfiles --exclude "/emacs/**"

# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
# ---------------------------------------------------------
echo "Actualizando repositorios de GitHub"
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
echo "Sincronizando las nubes de Sherloflix..."
rclone sync Onedrive_UN_en: Sherlockes78_UN_en: --transfers 2 --tpslimit 8 --bwlimit 5M


exit 0
