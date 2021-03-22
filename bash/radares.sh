#!/bin/bash
# -*- encoding: utf-8 -*-

###################################################################
#Script Name: Radares
#Description: Descarga de radares y copia a Google Drive
#Args: N/A
#Creation/Update: 20191112/20210318
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

set -e

# ----------------------------------
# Definición de variables
# ----------------------------------
carpeta=~/radares
notificacion=~/SherloScripts/bash/telegram.sh
mensaje=$'Actualización de radares desde www.todo-poi.es\n'

# ----------------------------------
# Crear la carpeta local
# ----------------------------------
crear_carpeta(){
    mkdir $carpeta
}
# ----------------------------------
# Descargar archivos
# ----------------------------------
descargar_archivos(){
    curl 'https://www.todo-poi.es/radar/GARMIN_RADARES/garminvelocidad 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500.zip' -o $carpeta/radares_1.zip
    curl 'https://www.todo-poi.es/radar/GARMIN_RADARES/garmintipo 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500.zip' -o $carpeta/radares_2.zip
}
# ---------------------------------------
# Descomprimir archivos y borrar sobrante
# ---------------------------------------
descomprimir_archivos(){
    unzip $carpeta/radares_1.zip -d $carpeta/
    rm -rf $carpeta/PoiLoader
    cp $carpeta/'garminvelocidad 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'/*.csv $carpeta
    rm -rf $carpeta/'garminvelocidad 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'

    unzip $carpeta/radares_2.zip -d $carpeta/
    rm -rf $carpeta/PoiLoader
    cp $carpeta/'garmintipo 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'/*.csv $carpeta
    rm -rf $carpeta/'garmintipo 3xx-5xx-6xx, Zumo, StreetPilot c550, 2720, 2820, 7200 y 7500'
    rm $carpeta/radares_*.zip
}
# ----------------------------------
# Uniendo archivos
# ----------------------------------
unir_archivos(){
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

# ----------------------------------
# Renombrando archivos
# ----------------------------------
renombrar_archivos(){
    mv $carpeta/R_BBS_fijos_total.csv $carpeta/01_fijos.csv
    mv $carpeta/R_BBS_camu_total.csv $carpeta/02_moviles.csv
    mv $carpeta/R_BBS_Foto.csv $carpeta/04_camaras.csv
    mv $carpeta/R_BBS_tramo.csv $carpeta/05_tramo.csv
    mv $carpeta/R_BBS_semaforos.csv $carpeta/06_semaforos.csv
    mv $carpeta/R_BBS_APR.csv $carpeta/07_restringido.csv
}

# Programa principal
crear_carpeta
descargar_archivos
descomprimir_archivos
unir_archivos
renombrar_archivos

# ----------------------------------
# Sincronizando con Google Drive
# ----------------------------------
rclone sync $carpeta Sherlockes_GD:Radares

# ----------------------------------
# Borrando los rastros
# ----------------------------------
rm -rf $carpeta

# Envia el mensaje de telegram con el resultado
$notificacion "$mensaje"
