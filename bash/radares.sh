#!/bin/bash

###################################################################
#Script Name: Radares
#Description: Descarga de radares y copia a Google Drive
#Args: N/A
#Creation/Update: 20191112/20240604
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################


# ----------------------------------
# Definición de variables
# ----------------------------------
carpeta=~/radares
PATH="/home/pi/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


# Ubicación del script para mandar notificaciones a telegram
source ~/SherloScripts/bash/telegram_V2.sh

#----------------------------------------------------------#
#                   Comprobar la salida                    #
#----------------------------------------------------------#
comprobar(){

    if [ $1 -eq 0 ]; then
	tele_msg_resul "ok"
    else
	tele_msg_resul "KO"
    fi
}

# ----------------------------------
# Crear la carpeta local
# ----------------------------------
mkdir $carpeta

download(){
    tele_msg_instr "Downloading files"
    #curl 'https://www.todo-poi.es/radar/GARMIN_RADARES/garminvelocidad 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500.zip' -o $carpeta/radares_1.zip
    curl "https://www.todo-poi.es/radar/GARMIN_RADARES/garminvelocidad%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip" -o $carpeta/radares_1.zip

    #curl 'https://www.todo-poi.es/radar/GARMIN_RADARES/garmintipo 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500.zip' -o $carpeta/radares_2.zip

    curl "https://www.todo-poi.es/radar/GARMIN_RADARES/garmintipo%203xx-5xx-6xx,%20Zumo,%20StreetPilot%20c550,%202720,%202820,%207200%20y%207500.zip" -o $carpeta/radares_2.zip
}

unzip(){
    tele_msg_instr "Unzipping files"
    #unzip $carpeta/radares_1.zip -d $carpeta/
    cd $carpeta
    unzip
    
    echo "Hola mundo"
    rm -rf $carpeta/PoiLoader
    cp $carpeta/'garminvelocidad 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'/*.csv $carpeta
    rm -rf $carpeta/'garminvelocidad 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'

    unzip $carpeta/radares_2.zip -d $carpeta/
    rm -rf $carpeta/PoiLoader
    cp $carpeta/'garmintipo 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'/*.csv $carpeta
    rm -rf $carpeta/'garmintipo 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'
    rm $carpeta/radares_*.zip
}

join(){
    tele_msg_instr "Joining files"
    rm $carpeta/*[0-9].csv
    rm $carpeta/*variable.csv
    cat $carpeta/*_tramo*.csv $carpeta/*_tunel*.csv > $carpeta/R_BBS_tramo.csv
    rm $carpeta/*_tramo_*.csv
    rm $carpeta/*_tunel*.csv
    cat $carpeta/R_BBS_curvas_peligrosas.csv $carpeta/R_BBS_puntos_negros.csv > $carpeta/03_cajas.csv
    rm $carpeta/R_BBS_curvas_peligrosas.csv
    rm $carpeta/R_BBS_puntos_negros.csv
    rm $carpeta/R_BBS_Alcoholemia.csv
}

rename(){
    tele_msg_instr "Renaming files"
    mv $carpeta/R_BBS_fijos_total.csv $carpeta/01_fijos.csv
    mv $carpeta/R_BBS_camu_total.csv $carpeta/02_moviles.csv
    mv $carpeta/R_BBS_Foto.csv $carpeta/04_camaras.csv
    mv $carpeta/R_BBS_tramo.csv $carpeta/05_tramo.csv
    mv $carpeta/R_BBS_semaforos.csv $carpeta/06_semaforos.csv
    mv $carpeta/R_BBS_APR.csv $carpeta/07_restringido.csv
}

sync(){
    tele_msg_instr "Syncing files"
    rclone sync $carpeta Sherlockes_GD:Radares
}

clear(){
    tele_msg_instr "Clear files"
    rm -rf $carpeta
}


#### Script principal ####
#download
#comprobar $?
unzip
comprobar $?
join
comprobar $?
rename
comprobar $?
sync
comprobar $?
clear
comprobar $?


# Envia el mensaje de telegram con el resultado
tele_end
