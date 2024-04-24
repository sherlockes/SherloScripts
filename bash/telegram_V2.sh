#!/bin/bash

###################################################################
#Script Name: telegram_V2.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20240424/20240424
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################



################################
####      Dependencias      ####
################################


################################
####       Funciones        ####
################################

msg_instr() {
    texto_instr="$1"
}

msg_resul() {
    texto_resul="$1"

    total_caracteres=$(expr length "$texto_instr")
    total_caracteres=$(expr $total_caracteres + $(expr length "$texto_resul")) 

    echo "El número total de caracteres es: $total_caracteres"

}


################################
####    Script principal    ####
################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf
