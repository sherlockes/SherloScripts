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

# Ruta al archivo YAML
canales_yaml="~/yt2pcst/canales.yaml"


################################
####      Dependencias      ####
################################

# Instalar yq si no está instalado
if ! command -v yq &> /dev/null; then
    echo "Instalando yq..."
    sudo apt-get install yq -y
fi


################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################


# Leer nombres y URLs de los canales de YouTube desde el archivo YAML
nombres=$(yq eval '.canales[].nombre' $canales_yaml)
urls=$(yq eval '.canales[].url' $canales_yaml)

# Mostrar los nombres y URLs
echo "Nombres de canales:"
echo "$nombres"
echo "URLs de canales:"
echo "$urls"
