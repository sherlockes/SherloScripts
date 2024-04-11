#!/bin/bash

###################################################################
#Script Name: yt2pcst.sh
#Description: Generación de un poscast a partir de canales de youtube
#Args: N/A
#Creation/Update: 20240411/20240411
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

RUTA=~/temp

# Ruta al archivo de canales
archivo_canales="/home/sherlockes/yt2pcst/canales.txt"


################################
####      Dependencias      ####
################################




################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################


# Leer nombres y URLs de los canales de YouTube desde el archivo de texto
while IFS= read -r linea; do
    nombre=$(echo "$linea" | cut -d ',' -f 1)
    url=$(echo "$linea" | cut -d ',' -f 2)
    echo "Nombre del canal: $nombre"
    echo "URL del canal: $url"
done < "$archivo_canales"
