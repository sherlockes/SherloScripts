#!/bin/bash

###################################################################
# Script Name: photos-gsync.sh
# Description: Copia de seguridad de Google Photos
# Args: N/A
# Creation/Update: 20201211/20220222
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
###################################################################

host=sherlockes@192.168.10.200
ruta=/homes/sherlockes/gphotos
hostname=nas-gphotos
ruta_destino=/photo/sherlo_gphotos
hostname_destino=syn-photos

# --------------------------------------------
# Comprobar la instalación de sshfs
# --------------------------------------------

if which sshfs >/dev/null; then
    echo 'sshfs está instalado...'
else
    echo 'instalando sshfs...'
    sudo apt install sshfs
fi

# --------------------------------------------
# Comprobar el acceso ssh
# --------------------------------------------
status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 $host echo ok 2>&1)

if [[ $status == ok ]] ; then
    echo "Acceso a $host autorizado..."
elif [[ $status == "Permission denied"* ]] ; then
    echo "Acceso a $host no autorizado..."
    exit
else
    echo "No es posible el aceso a $host"
    exit
fi

if [[ $status == ok ]] ; then
    # --------------------------------------------
    # Crea las carpetas y monta la unidades
    # --------------------------------------------
    mkdir ~/$hostname
    sshfs $host:$ruta ~/$hostname

    mkdir ~/$hostname_destino
    sshfs $host:$ruta_destino ~/$hostname_destino

    # --------------------------------------------
    # Sincroniza sólo el mes anterior
    # --------------------------------------------
    mes_ant_ini_mes=$(date -d "last month" '+%m')
    mes_ant_ini_ano=$(date -d "last month" '+%Y')
    fecha_ini="${mes_ant_ini_ano}-${mes_ant_ini_mes}-01"

    mes_ant_fin_dia=$(date -d "$(date +%Y-%m-01) -1 day" '+%d')
    mes_ant_fin_mes=$(date -d "$(date +%Y-%m-01) -1 day" '+%m')
    mes_ant_fin_ano=$(date -d "$(date +%Y-%m-01) -1 day" '+%Y')
    fecha_fin="${mes_ant_fin_ano}-${mes_ant_fin_mes}-${mes_ant_fin_dia}"

    # --------------------------------------------
    # Realiza la sincronización
    # --------------------------------------------
    ~/.local/bin/gphotos-sync --rescan --flush-index --skip-video --do-delete --start-date $fecha_ini --end-date $fecha_fin ~/$hostname
    #~/.local/bin/gphotos-sync --rescan --skip-video --do-delete ~/$hostname
    

    # --------------------------------------------
    # Ajusta fecha de toma (exif_create.sh)
    # --------------------------------------------
    carpeta="/home/pi/${hostname}/photos/${mes_ant_ini_ano}/${mes_ant_ini_mes}"
    cd $carpeta
    source "$( dirname "${BASH_SOURCE[0]}" )/exif_create.sh"

    # --------------------------------------------
    # Copia la carpeta del mes anterior
    # --------------------------------------------
    carpeta_destino="/home/pi/${hostname_destino}/${mes_ant_ini_ano}"
    mkdir -p $carpeta_destino
    rsync -av $carpeta $carpeta_destino --delete
    
    # --------------------------------------------
    # Desmonta las unidades
    # --------------------------------------------
    fusermount -zu ~/$hostname
    rmdir ~/$hostname

    fusermount -zu ~/$hostname_destino
    rmdir ~/$hostname_destino
fi
