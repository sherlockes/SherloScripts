#!/bin/bash

###################################################################
#Script Name: transmission_check.sh
#Description: Lee un log de transmissiond, busca torrents no registrados y envía aviso por Telegram.
#Args: N/A
#Creation/Update: 20260610/20260610
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com
###################################################################

# =================================================================
# Configuración
# =================================================================

# Ruta al archivo de log de transmissiond
LOG_PATH="/home/sherlockes/logs/transmissiond.log"

# Ruta al archivo de variables de entorno (.env)
ENV_PATH="/home/sherlockes/.env"

# Patrón de búsqueda para errores de torrents no registrados
SEARCH_PATTERN="unregistered|not registered|rejected"

# Horas máximas desde la última modificación del log para procesarlo
MAX_AGE_HOURS=2

# =================================================================
# Validaciones e Inicialización
# =================================================================

# Comprobar si el archivo de log existe
if [ ! -f "$LOG_PATH" ]; then
    echo "Error: El archivo de log no existe en '$LOG_PATH'." >&2
    exit 1
fi

# Comprobar si el archivo .env existe
if [ ! -f "$ENV_PATH" ]; then
    echo "Error: El archivo .env de configuración no existe en '$ENV_PATH'." >&2
    exit 1
fi

# Cargar variables de entorno del archivo .env
set -a
source "$ENV_PATH"
set +a

# Comprobar si el archivo de log ha sido modificado en las últimas n horas
if [ -n "$MAX_AGE_HOURS" ]; then
    current_time=$(date +%s)
    mtime=$(stat -c %Y "$LOG_PATH")
    age_seconds=$((current_time - mtime))
    max_age_seconds=$((MAX_AGE_HOURS * 3600))
    
    if [ "$age_seconds" -gt "$max_age_seconds" ]; then
        exit 0
    fi
fi

# Comprobar que las variables de Telegram estén configuradas
# Soporta tanto TELEGRAM_BOT_TOKEN/TELEGRAM_CHAT_ID como TOKEN/CHAT_ID
BOT_TOKEN="${TG_TEJELONSOS_BOT_TOKEN:-$TOKEN}"
CHAT_ID="${TG_NOTIF_ID:-$CHAT_ID}"

if [ -z "$BOT_TOKEN" ]; then
    echo "Error: La variable TG_TEJELONSOS_BOT_TOKEN (o TOKEN) no está configurada en el archivo .env." >&2
    exit 1
fi

if [ -z "$CHAT_ID" ]; then
    echo "Error: La variable TG_NOTIF_ID (o CHAT_ID) no está configurada en el archivo .env." >&2
    exit 1
fi

# =================================================================
# Procesamiento del Log
# =================================================================

# Función para escapar caracteres HTML especiales de los nombres de los torrents
escape_html() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Obtener los torrents no registrados con su última hora de fallo (sin milisegundos)
# Usamos awk para agrupar por archivo, quedarnos con la última marca de tiempo y devolver la lista ordenada.
unregistered_torrents=$(awk -v pat="$SEARCH_PATTERN" '
tolower($0) ~ tolower(pat) {
    idx = index($0, "]")
    if (idx > 2) {
        ts = substr($0, 2, idx - 2)
        sub(/\.[0-9]{3}$/, "", ts)
        rest = substr($0, idx + 2)
        idx_err = index(rest, " Tracker error:")
        if (idx_err > 0) {
            file = substr(rest, 1, idx_err - 1)
            gsub(/^[ \t]+|[ \t]+$/, "", file)
            latest[file] = ts
        }
    }
}
END {
    for (f in latest) {
        print latest[f] "|" f
    }
}' "$LOG_PATH" | sort)

# Si no hay torrents no registrados, salimos sin enviar mensaje
if [ -z "$unregistered_torrents" ]; then
    echo "No se encontraron torrents no registrados en el log."
    exit 0
fi

# =================================================================
# Envío de Mensaje a Telegram
# =================================================================

# Construir el cuerpo del mensaje en formato HTML con título solicitado
mensaje="⚠️ <b>Torrents no registrados en DS920</b>"$'\n'$'\n'

# Leer línea por línea para construir el cuerpo del mensaje
first_item=true
while IFS="|" read -r ts torrent; do
    if [ -n "$torrent" ]; then
        escaped_torrent=$(escape_html "$torrent")
        
        # Introducir una línea en blanco entre archivo y archivo (evitando antes del primer elemento)
        if [ "$first_item" = true ]; then
            first_item=false
        else
            mensaje+=$'\n'
        fi
        
        mensaje+="• <b>Hora:</b> $ts"$'\n'
        mensaje+="$escaped_torrent"$'\n'
    fi
done <<< "$unregistered_torrents"

# URL de la API de Telegram
url="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

# Enviar el mensaje utilizando curl
response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
    -d "chat_id=${CHAT_ID}" \
    -d "parse_mode=HTML" \
    --data-urlencode "text=${mensaje}")

# Obtener el código de respuesta HTTP (última línea) y la respuesta JSON
http_code=$(echo "$response" | tail -n1)
json_response=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo "Mensaje enviado con éxito a Telegram."
else
    echo "Error al enviar mensaje a Telegram (Código HTTP: $http_code)." >&2
    echo "Respuesta del servidor: $json_response" >&2
    exit 1
fi
