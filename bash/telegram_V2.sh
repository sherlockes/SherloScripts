#!/bin/bash

###################################################################
#Script Name: telegram_V2.sh
#Description: Envía mensaje a telegrám calculando la longitud de línea
#Args: N/A
#Creation/Update: 20240424/20240426
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
#
# Funciones:
# - tele_msg_title "Titulo" -> Título entre líneas de guiones
# - tele_msg_instr "Descrip" -> Identifica el proceso a realizar
# - tele_msg_resul "Result" -> Resultado del proceso
# - tele_end -> Envía el mensaje
###################################################################


################################
####       Variables        ####
################################

# Hora de inicio
init_time=$( date +%s )

# Inicio del mensaje para que sea monoespaciado
mensaje="\`"

# Longitud máxima por línea
max_len=35

################################
####      Dependencias      ####
################################

# Archivo "~/config.conf"
# TOKEN="XXXXXXXX:XXXXXXXXXXXXXXXXXXXXXXXX"
# CHAT_ID="-XXXXXXXXXXXXX"

if [ ! -e ~/config.conf ]; then
    echo "Atención: El archivo ~/config.conf no existe."
    exit
fi

if ! command -v curl &> /dev/null; then
    echo "Atención: El comando 'curl' no está disponible en este equipo, se instala."
    sudo apt update  # Actualiza la lista de paquetes
    sudo apt install curl  # Instala el paquete curl
fi


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

    # Lo pasamos a mayúsculas y calculamos longitud
    texto="${texto^^}"
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
    
    # Introduce el título entre dos líneas de guiones
    tele_hr
    mensaje+="$texto_rellenado"
    mensaje+=$'\n'
    tele_hr
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
	resultado="$texto_instr$puntos$texto_resul"
	resultado="${resultado:0:max_len}"
	mensaje+="$resultado"
	mensaje+=$'\n'
        echo "Las cadenas son demasiado largas para alcanzar una longitud total de 35 caracteres."
    fi
}

tele_end(){
    # Calcula la duración del script
    end_time=$( date +%s )
    let duration=$end_time-$init_time
    tele_hr
    tele_msg_instr "Duración del script:"
    tele_msg_resul "$duration sg"

    # Envía el mensaje
    tele_send_msg
}

tele_hr(){
    # Generar una cadena de guiones de longitud max_len
    linea_guiones=$(printf "%-${max_len}s" "")
    linea_guiones=${guiones_adicionales// /-}
    
    mensaje+="$linea_guiones"
    mensaje+=$'\n'
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

nombre_script=$(basename "$0")
echo "El nombre del archivo del script es: $nombre_script"
