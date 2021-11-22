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
#Creation/Update: 20200521/20211122
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

mensaje=$'Faenas diarias de Rpi mediante pidiario.sh\n'
mensaje=$'------------------------------------------\n'
unidades=(Onedrive_UN_en Sherlockes78_UN_en)
carpetas=(pelis series)
notificacion=~/SherloScripts/bash/telegram.sh

#----------------------------------------------------------
# Función para comprobar la salida
#----------------------------------------------------------
comprobar(){

    if [ $1 -eq 0 ]; then
	mensaje+=$'OK'
    else
	mensaje+=$'ERROR'
    fi
    mensaje+=$'\n'
}

# ---------------------------------------------------------
# Actualiza hugo rclone si es necesario
# ---------------------------------------------------------
mensaje+=$'Actualización de Hugo...'
. /home/pi/SherloScripts/bash/hugo.sh
comprobar $?

mensaje+=$'Actualización de Rclone...'
. /home/pi/SherloScripts/bash/rclone.sh && rclone_check
comprobar $?

# ---------------------------------------------------------
# Google Drive - Sincronización de carpetas
# ---------------------------------------------------------
echo "Sincronizando las carpetas de Google Drive..."

mensaje+=$'Sincronizando carpeta SherloScripts...'
rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/ --exclude "/.git/**"
comprobar $?

mensaje+=$'Sincronizando carpeta Dotfiles...'
rclone sync -v Sherlockes_GD:/dotfiles/ /home/pi/dotfiles --exclude "/emacs/**"
comprobar $?

# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
# ---------------------------------------------------------
echo "Actualizando repositorios de GitHub..."
repo=(SherloScripts sherblog)
for i in "${repo[@]}"
do
    mensaje+=$'Actualizando el repositorio $i...'
    echo "Actualizando el repositorio $i"
    cd ~/$i

    git add --all
    git commit -m "Update"
    git push
    comprobar $?
done

# --------------------------------------------------------------
# Comprueba el estado de las distintas nubes públicas
# --------------------------------------------------------------

for u in "${unidades[@]}"
do
    mensaje+=$"Comprobando disponibilidad de $u..."
    rclone -v size $u:

    if [ $? -eq 0 ]; then
	echo "OK"
	mensaje+=$'OK'
    else
	echo "KO"
	mensaje+=$'ERROR'
	$notificacion "$mensaje"
	exit 0
    fi
    mensaje+=$'\n'
done

# --------------------------------------------------------------------------
# Comprueba y sincroniza Sherloflix con la unidad compartida de Sherlockes78
# --------------------------------------------------------------------------
echo "Sincronizando las nubes de Sherloflix..."
#rclone sync ${unidades[0]}: ${unidades[1]}: --transfers 2 --tpslimit 8 --bwlimit 10M -P

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



# Envia el mensaje de telegram con el resultado
$notificacion "$mensaje"

exit 0
