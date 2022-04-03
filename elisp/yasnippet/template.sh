#!/bin/bash

###################################################################
#Script Name: `(file-name-base)`.sh
#Description: ${1:Descripción}
#Args: N/A
#Creation/Update: `(insert (format-time-string "%Y%m%d"))`/`(insert (format-time-string "%Y%m%d"))`
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

RUTA=~/temp
RSS_URL="https://sherblog.pro/index.xml"
TWEETSH_URL="https://raw.githubusercontent.com/piroor/tweet.sh/trunk/tweet.sh"

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

$0
