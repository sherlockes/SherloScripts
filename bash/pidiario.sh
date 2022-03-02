#!/bin/bash
# -*- encoding: utf-8 -*-

###################################################################
#Script Name: pidiario.sh
#Description: - Actualiza Hugo
#             - Sincroniza la carpeta SherloScripts
#             - Actualiza los repos de GitHub
#             - Guarda la config de HA en GitHub
#             - Comprueba el estado de varias nubes públicas
#             - Sincroniza las nubes de Sherloflix
#             - Comprueba la sincronización de las carpetas
#Args: N/A
#Creation/Update: 20200521/20220302
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

unidades=(Sherlockes78_UN_en Onedrive_UN_en)
carpetas=(pelis series)
notificacion=~/SherloScripts/bash/telegram.sh
inicio=$( date +%s )

mensaje=$'Faenas diarias de Rpi mediante <a href="https://raw.githubusercontent.com/sherlockes/SherloScripts/master/bash/pidiario.sh">pidiario.sh</a>\n'
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'

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
mensaje+=$'Actualización de Hugo . . . . . . . . . . . . . . . . '
. /home/pi/SherloScripts/bash/hugo.sh
comprobar $?

mensaje+=$'Actualización de Rclone . . . . . . . . . . . . . . . '
. /home/pi/SherloScripts/bash/rclone.sh && rclone_check
comprobar $?

# ---------------------------------------------------------
# Google Drive - Sincronización de carpetas
# ---------------------------------------------------------
echo "Sincronizando las carpetas de Google Drive..."

mensaje+=$'Sincronizando carpeta SherloScripts . . . . '
rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/ --exclude "/.git/**"
comprobar $?

mensaje+=$'Sincronizando carpeta Dotfiles . . . . . . . . . '
rclone sync -v Sherlockes_GD:/dotfiles/ /home/pi/dotfiles --exclude "/emacs/**"
comprobar $?

# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
# ---------------------------------------------------------
echo "Actualizando repositorios de GitHub..."
repo=(SherloScripts sherblog)
for i in "${repo[@]}"
do
    mensaje+=$"Actualizar el repositorio $i . . . "
    echo "Actualizando el repositorio $i"
    cd ~/$i

    git add --all
    git commit -m "Update"
    git push
    comprobar $?
done

# ---------------------------------------------------------
# Home Assistant - Guarda la configuración en GitHub
# ---------------------------------------------------------
echo "Guardando config de HA en GitHub..."
mensaje+=$"Guardando config de HA en GitHub . . . . . "
#ssh root@192.168.10.202 -p 222 'bash -s' < /home/pi/SherloScripts/bash/ha_gitpush.sh
ssh -T root@192.168.10.202 -p 222 <<'ENDSSH'
cd /config
git add .
git commit -m "Configuración HA de `date +'%d-%m-%Y %H:%M:%S'`"
git push -u origin master
ENDSSH
comprobar $?

# --------------------------------------------------------------
# Comprueba el estado de las distintas nubes públicas
# --------------------------------------------------------------

for u in "${unidades[@]}"
do
    mensaje+=$"Disponibilidad de $u . . "
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
mensaje+=$"${unidades[0]} Vs ${unidades[1]}."
timeout 3h rclone sync ${unidades[0]}: ${unidades[1]}: --transfers 2 --tpslimit 8 --bwlimit 10M -P
comprobar $?

echo "Comprobando sincronización de las nubes de Sherloflix..."

for u in "${carpetas[@]}"
do
    echo "Comprobando sincronización de $u..."
    mensaje+=$"Sincronización de $u . . . . . . . . . . . . . . . "
    diferencias=$( rclone check ${unidades[0]}:/$u ${unidades[1]}:/$u --size-only 2>&1 | grep 'differences found' | cut -d ":" -f 6 | cut -d " " -f 2 )

if [ $diferencias -ne 0 ];
then
    echo "La sincronización de las $u de las nubes no es correcta."
    mensaje+=$'ERROR'
else
    mensaje+=$'OK'
    echo "La sincronización de $u es correcta."
fi
mensaje+=$'\n'
done

# Envia el mensaje de telegram con el resultado
fin=$( date +%s )
let duracion=$fin-$inicio
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'
mensaje+=$"Duración del Script:  $duracion segundos"

$notificacion "$mensaje"

exit 0
