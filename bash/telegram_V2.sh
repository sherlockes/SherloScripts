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

# Inicio del mensaje para que sea monoespaciado
mensaje="\`"

# Longitud máxima por línea
max_len=35

################################
####      Dependencias      ####
################################


################################
####       Funciones        ####
################################

tele_msg_instr() {
    texto_instr="$1"
}

tele_msg_resul() {
    texto_resul="$1"

    total_caracteres=$(expr length "$texto_instr")
    total_caracteres=$(expr $total_caracteres + $(expr length "$texto_resul")) 

    echo "El número total de caracteres es: $total_caracteres"
    concatenar_con_puntos

}

tele_msg_title() {

    texto="$1"
    longitud=${#texto}
    
    # Calcula cuántos caracteres se necesitan agregar a cada lado
    caracteres_restantes=$((max_len - longitud))
    caracteres_por_lado=$((caracteres_restantes / 2))

    # Rellena el texto con guiones
    guiones_por_lado=$(printf "%-${caracteres_por_lado}s" "")
    texto_rellenado="${guiones_por_lado// /-}$texto${guiones_por_lado// /-}"

    # Si la longitud total es menor que 35, agrega un guion adicional al final
    if (( ${#texto_rellenado} < $max_len )); then
        texto_rellenado="$texto_rellenado-"
    fi

    # Generar una cadena de guiones de longitud max_len
    guiones_adicionales=$(printf "%-${max_len}s" "")
    guiones_adicionales="${guiones_adicionales// /-}"
    gujiones_adicinales='-----------------------------------'

    # Introduce el título entre dos líneas de guiones
    mensaje+="$guiones_adicionales"
    mensaje+='\n'
    mensaje+="$texto_rellenado"
    mensaje+=$'\n'
    #mensaje+="$guiones_adicionales"
    #mensaje+='\n'
}


concatenar_con_puntos() {
   
    # Calcula cuántos puntos se deben añadir entre las dos cadenas
    longitud_total=$((max_len - ${#texto_instr} - ${#texto_resul}))
    
    # Asegura que la longitud total sea mayor o igual a 0
    if (( longitud_total >= 0 )); then
        # Construye la cadena con puntos intercalados
        puntos=$(printf '%.0s.' $(seq 1 $longitud_total))
        resultado="$texto_instr$puntos$texto_resul"
	mensaje+="$resultado"
	mensaje+=$'\n'
        echo "$resultado"
    else
        echo "Las cadenas son demasiado largas para alcanzar una longitud total de 35 caracteres."
    fi
}

tele_send_msg() {

	# URL para enviar mensaje
	url="https://api.telegram.org/bot$TOKEN/sendMessage"

	mensaje+=$"\`"
	
	# Parámetros del mensaje
	parametros="chat_id=$CHAT_ID&text=$mensaje&parse_mode=Markdown"

	# Envío del mensaje utilizando curl
	curl -s -d "$parametros" "$url" > /dev/null

}


################################
####    Script principal    ####
################################

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf
