#!/bin/bash
# -*- encoding: utf-8 -*-

###################################################################
#Script Name: pidiario.sh
#Description: - Actualiza Hugo
#             - Sincroniza la carpeta SherloScripts y dotfiles
#             - Actualiza los repos de GitHub
#             - Guarda la config de HA en GitHub
#             - Comprueba el estado de varias nubes públicas
#             - Sincroniza las nubes de Sherloflix
#             - Comprueba la sincronización de las carpetas
#Args: N/A
#Creation/Update: 20200521/20230521
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

unidades=(Sherlockes78_UN2_en Sherlockes78_UN3_en)
carpetas=(pelis series twitch)
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
hugo_rclone_check(){
    echo "Actualizando Hugo..."
    mensaje+=$'Actualización de Hugo . . . . . . . . . . . . . . . . '
    . /home/pi/SherloScripts/bash/hugo.sh
    comprobar $?

    echo "Actualizando Rclone"
    mensaje+=$'Actualización de Rclone . . . . . . . . . . . . . . . '
    . /home/pi/SherloScripts/bash/rclone.sh && rclone_check
    comprobar $?
}

# -------------------------------------------------------
# Comprueba el estado de las unidades remotas
# -------------------------------------------------------
rclone_check_remotes(){
    # Crea el enlace a la configuración de Rclon en Dotfiles
    mensaje+=$'Actualizando configuración Rclone . . . . '
    ln -sf ~/dotfiles/rclone/rclone.conf ~/.config/rclone/rclone.conf
    #cp ~/dotfiles/rclone/rclone.conf ~/.config/rclone
    comprobar $?
    
    mensaje+=$'Disponibilidad de nubes\n'
    remotos=( $(rclone listremotes) )
    for remoto in "${remotos[@]}"
    do
	# Le quitamos los ":" al final de la cadena
	remoto=${remoto%?}

	if [ "$remoto" = "Sherlockes_Gphotos" ]; then
	    continue
	fi

	mensaje+=$" -$remoto (W). . "
	rclone mkdir $remoto:test

	if [ $? -eq 0 ]; then
	    mensaje+=$'OK'
	    echo "Es posible crear un directorio en $remoto"
	    rclone rmdir $remoto:test
	else
	    mensaje+=$'ERROR'
	    echo "No es posible crear un directorio en $remoto"
	fi
	mensaje+=$'\n'

	mensaje+=$" -$remoto (R). . "
	rclone -v size $remoto:

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
}

# ---------------------------------------------------------
# Actualiza el archivo init.el en el repositorio de Github
# ---------------------------------------------------------
update_initel(){
    echo "Actualizando el archivo init.el..."
    mensaje+=$'Actualizando el archivo init.el . . . . . . . . . '
    rclone sync -vv Sherlockes_GD:/dotfiles/emacs/.emacs.d/ Sherlockes_GD:/SherloScripts/elisp/ --include "/init.el"
    comprobar $?
}

# ---------------------------------------------------------
# Google Drive - Sincronización de carpetas
# ---------------------------------------------------------
gdrive_folders_sync(){
    echo "Sincronizando las carpetas de Google Drive..."

    mensaje+=$'Sincronizando carpeta SherloScripts . . . . '
    rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/ --exclude "/.git/**"
    comprobar $?

    mensaje+=$'Sincronizando carpeta Dotfiles . . . . . . . . . '
    rclone sync -v Sherlockes_GD:/dotfiles/ /home/pi/dotfiles --exclude "/emacs/**"
    comprobar $?

    mensaje+=$'Actualizando link rclone config. . . . . . . . '
    ln -sf /home/pi/dotfiles/rclone/rclone.conf /home/pi/.config/rclone/rclone.conf
    comprobar $?
}


# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
# ---------------------------------------------------------
github_repos_update(){
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
}

# ---------------------------------------------------------
# Home Assistant - Guarda la configuración en GitHub
# ---------------------------------------------------------
ha_config(){
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
}

# --------------------------------------------------------------------------
# Comprueba y sincroniza Sherloflix con la unidad compartida de Sherlockes78
# --------------------------------------------------------------------------
sherloflix_sync(){
    echo "Sincronizando las nubes de Sherloflix..."
    mensaje+=$"SherloFlix sinc. .  . ."
    timeout 3h rclone sync ${unidades[0]}: ${unidades[1]}: --transfers 2 --tpslimit 8 --bwlimit 10M -P --exclude "/twitch/**"
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
}

################################
####    Script principal    ####
################################

hugo_rclone_check # Comprueba el estado de la instalación de Rclone y Hugo
rclone_check_remotes # Comprueba si es posible escribir en los remotos de Rclone
update_initel # Actualiza la zonfiguración de Emacs
gdrive_folders_sync # Sincroniza "SherloScripts", "Dotfiles" y el enlace simbólico de Rclone
github_repos_update # Actualiza los repositorios de "SherloScripts" y "Sherblog"
ha_config # Guarda la configuración de Home Assistant
clouds_check # Comprueba la disponibilidad de las nubes
sherloflix_sync # Sincroniza las nubes de Sherloflix y comprueba el estado

# Envia el mensaje de telegram con el resultado
fin=$( date +%s )
let duracion=$fin-$inicio
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'
mensaje+=$"Duración del Script:  $duracion segundos"

$notificacion "$mensaje"
