#!/bin/bash

###################################################################
#Script Name: sherblog_test.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250105/20250105
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

RUTA=~/temp


################################
####      Dependencias      ####
################################

# Crea la RUTA de descarga si no existe
if [[ ! -e $RUTA ]]; then mkdir $RUTA; fi

# Instala xmllint si no está disponible
if ! which xmllint >/dev/null; then sudo apt install -y libxml2-utils; fi


################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################


