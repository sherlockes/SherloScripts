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
#             - Sincroniza la web sherblog.pro con una carpeta en Google drive
#Args: N/A
#Creation/Update: 20200521/20240119
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

unidades=(Sherlockes78_UN2_en Sherlockes78_UN3_en)
carpetas=(pelis series) # No se incluye la carpeta twitch
notificacion=~/SherloScripts/bash/telegram.sh
inicio=$( date +%s )

# Incluye el archivo que contiene la función para mensajes a Telegram
source ~/SherloScripts/bash/telegram_V2.sh

tele_msg_title "  Faenas diarias de rpi  "

#----------------------------------------------------------
# Función para comprobar la salida
#----------------------------------------------------------
comprobar(){

    if [ $1 -eq 0 ]; then
	tele_msg_resul "ok"
    else
	tele_msg_resul "KO"
    fi
}

# ---------------------------------------------------------
# Actualiza hugo rclone si es necesario
# ---------------------------------------------------------
hugo_rclone_check(){
    echo "Actualizando Hugo..."
    tele_msg_instr "Actualización de Hugo"
    . /home/pi/SherloScripts/bash/hugo.sh
    tele_check $?

    echo "Actualizando Rclone"
    tele_msg_instr "Actualización de Rclone"
    . /home/pi/SherloScripts/bash/rclone.sh && rclone_check
    tele_check $?
}

# -------------------------------------------------------
# Comprueba el estado de las unidades remotas
# -------------------------------------------------------
rclone_check_remotes(){
    # Crea el enlace a la configuración de Rclon en Dotfiles
    tele_msg_instr "Actualizando configuración Rclone"
    ln -sf ~/dotfiles/rclone/rclone.conf ~/.config/rclone/rclone.conf
    #cp ~/dotfiles/rclone/rclone.conf ~/.config/rclone
    tele_check $?
    
    tele_msg_instr "Disponibilidad de nubes"
    tele_mst_resul "..."
    remotos=( $(rclone listremotes) )
    for remoto in "${remotos[@]}"
    do
	# Le quitamos los ":" al final de la cadena
	remoto=${remoto%?}

	if [ "$remoto" = "Sherlockes_Gphotos" ]; then
	    continue
	fi

	tele_msg_instr"-$remoto (W)"
	rclone mkdir $remoto:test

	if [ $? -eq 0 ]; then
	    tele_msg_resul "ok"
	    echo "Es posible crear un directorio en $remoto"
	    rclone rmdir $remoto:test
	else
	    tele_msg_resul "KO"
	    echo "No es posible crear un directorio en $remoto"
	fi
	mensaje+=$'\n'

	tele_msg_instr "-$remoto (R)"
	rclone -v size $remoto:

	if [ $? -eq 0 ]; then
	    echo "OK"
	   tele_msg_resul "ok"
	else
	    echo "KO"
	    tele_msg_resul "KO"
	    
	    $notificacion "$mensaje"
	    exit 0
	fi
	#mensaje+=$'\n'
    done
}

# ---------------------------------------------------------
# Actualiza el archivo init.el en el repositorio de Github
# ---------------------------------------------------------
update_initel(){
    echo "Actualizando el archivo init.el..."
    tele_msg_instr "Actualizando el archivo init.el"
    rclone sync -vv Sherlockes_GD:/dotfiles/emacs/.emacs.d/ Sherlockes_GD:/SherloScripts/elisp/ --include "/init.el"
    tele_check $?
}

# ---------------------------------------------------------
# Google Drive - Sincronización de carpetas
# ---------------------------------------------------------
gdrive_folders_sync(){
    echo "Sincronizando las carpetas de Google Drive..."

    tele_msg_instr "Sync SherloScripts Folder"
    #rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/ --exclude "/.git/**"
    rclone sync -v /home/pi/SherloScripts/ Sherlockes_GD:/SherloScripts/ --exclude "/.git/**"
    tele_check $?

   tele_msg_instr "Sync Dotfiles folder"
    rclone sync -v Sherlockes_GD:/dotfiles/ /home/pi/dotfiles --exclude "/emacs/**"
    tele_check $?

    tele_msg_instr "Update link rclone config"
    ln -sf /home/pi/dotfiles/rclone/rclone.conf /home/pi/.config/rclone/rclone.conf
    tele_check $?
}


# ---------------------------------------------------------
# Repositorios - Actualiza los repositorios de GitHub
# ---------------------------------------------------------
github_repos_update(){
    echo "Actualizando repositorios de GitHub..."
    repo=(SherloScripts,ha_cfg)
    for i in "${repo[@]}"
    do
	tele_msg_instr "Update $i repo"
	echo "Actualizando el repositorio $i"
	cd ~/$i

	git add --all
	git commit -m "Update"
	git push
	tele_check $?
    done
}

# ---------------------------------------------------------
# Home Assistant - Guarda la configuración en GitHub
# ---------------------------------------------------------
ha_config(){
    echo "Guardando config de HA en GitHub..." 
    tele_msg_instr "Save HS config in GitHub"
    scp -r root@192.168.10.202:/config/ ~/ha_cfg/
    tele_check $?
}

# --------------------------------------------------------------------------
# Comprueba y sincroniza Sherloflix con la unidad compartida de Sherlockes78
# --------------------------------------------------------------------------
sherloflix_sync(){
    echo "Sincronizando las nubes de Sherloflix..."
    tele_msg_instr "SherloFlix sinc"
    timeout 3h rclone sync ${unidades[0]}: ${unidades[1]}: --transfers 2 --tpslimit 8 --bwlimit 10M -P --exclude "/twitch/**"
    tele_check $?

    echo "Comprobando sincronización de las nubes de Sherloflix..."

    for u in "${carpetas[@]}"
    do
	echo "Comprobando sincronización de $u..."
	tele_msg_instr "Sincronización de $u"
	diferencias=$( rclone check ${unidades[0]}:/$u ${unidades[1]}:/$u --size-only 2>&1 | grep 'differences found' | cut -d ":" -f 6 | cut -d " " -f 2 )

	if [ $diferencias -ne 0 ];
	then
	    echo "La sincronización de las $u de las nubes no es correcta."
	    tele_msg_resul "KO"
	else
	    tele_msg_instr "ok"
	    echo "La sincronización de $u es correcta."
	fi
	mensaje+=$'\n'
    done
}

# ----------------------------------------------------------------
# Sincroniza la web sherblog.pro con un directorio en Google Drive
# ----------------------------------------------------------------
sherblog_sync(){
    echo "Sincronizando la web sherblog.pro..."
    tele_msg_instr "Sincronizando la web sherblog.es"
    rclone sync ~/sherblog/ Sherlockes_GD:/sherblog/ --create-empty-src-dirs --exclude "/.git*/**" --exclude "/public/"
    tele_check $?
}


################################
####    Script principal    ####
################################

#hugo_rclone_check # Comprueba el estado de la instalación de Rclone y Hugo
#rclone_check_remotes # Comprueba si es posible escribir en los remotos de Rclone
#update_initel # Actualiza la zonfiguración de Emacs
gdrive_folders_sync # Sincroniza "SherloScripts", "Dotfiles" y el enlace simbólico de Rclone
ha_config # Guarda configuración de Home Assistant
github_repos_update # Actualiza los repositorios de "SherloScripts" y "Sherblog"
#clouds_check # Comprueba la disponibilidad de las nubes
#sherloflix_sync # Sincroniza las nubes de Sherloflix y comprueba el estado

# Envia el mensaje de telegram con el resultado
tele_end
