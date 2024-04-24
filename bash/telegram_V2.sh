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

mensaje=""

max_len=50

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
    concatenar_con_puntos

}

concatenar_con_puntos() {
   
    # Calcula cuántos puntos se deben añadir entre las dos cadenas
    longitud_total=$((maxlen - ${#texto_instr} - ${#texto_resul}))
    
    # Asegura que la longitud total sea mayor o igual a 0
    if (( longitud_total >= 0 )); then
        # Construye la cadena con puntos intercalados
        puntos=$(printf '%.0s.' $(seq 1 $longitud_total))
        resultado="$texto_instr$puntos$texto_resul\n"
        echo "$resultado"
    else
        echo "Las cadenas son demasiado largas para alcanzar una longitud total de 50 caracteres."
    fi
}


################################
####    Script principal    ####
################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf
