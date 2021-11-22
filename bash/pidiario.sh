
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
echo "Sincronizando las carpetas de Google Drive..."
rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/ --exclude "/.git/**"
rclone sync -v Sherlockes_GD:/dotfiles/ /home/pi/dotfiles --exclude "/emacs/**"

# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
# ---------------------------------------------------------
echo "Actualizando repositorios de GitHub..."
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
carpetas=(pelis series)
notificacion=~/SherloScripts/bash/telegram.sh

for u in "${unidades[@]}"
do
    rclone -v size $u:

    if [ $? -eq 0 ]; then
	echo "OK"
    else
	echo "KO"
	$notificacion "Hay un error de conexión con $u"
	exit 0
    fi
done

# --------------------------------------------------------------------------
# Comprueba y sincroniza Sherloflix con la unidad compartida de Sherlockes78
# --------------------------------------------------------------------------
echo "Sincronizando las nubes de Sherloflix..."
rclone sync ${unidades[0]}: ${unidades[1]}: --transfers 2 --tpslimit 8 --bwlimit 10M -P

echo "Comprobando sincronización de las nubes de Sherloflix..."

for u in "${carpetas[@]}"
do
    diferencias=$( rclone check ${unidades[0]}:/$u ${unidades[1]}:/$u --size-only 2>&1 | grep 'differences found' | cut -d ":" -f 6 | cut -d " " -f 2 )

if [ $diferencias -ne 0 ];
then
    echo "La sincronización de las $u de las nubes no es correcta."
    $notificacion "Hay un error de sincronización de las $u de las nubes!!!"
else
    echo "La sincronización de $u es correcta."
fi
done

exit 0
