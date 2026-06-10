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
LOG_PATH="/home/sherlockes/SherloScripts/bash/transmissiond.log"

# Ruta al archivo de variables de entorno (.env)
ENV_PATH="/home/sherlockes/SherloScripts/bash/.env"

# Patrón de búsqueda para errores de torrents no registrados
SEARCH_PATTERN="unregistered|not registered|rejected"

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

# Comprobar que las variables de Telegram estén configuradas
# Soporta tanto TELEGRAM_BOT_TOKEN/TELEGRAM_CHAT_ID como TOKEN/CHAT_ID
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-$TOKEN}"
CHAT_ID="${TELEGRAM_CHAT_ID:-$CHAT_ID}"

if [ -z "$BOT_TOKEN" ]; then
    echo "Error: La variable TELEGRAM_BOT_TOKEN (o TOKEN) no está configurada en el archivo .env." >&2
    exit 1
fi

if [ -z "$CHAT_ID" ]; then
    echo "Error: La variable TELEGRAM_CHAT_ID (o CHAT_ID) no está configurada en el archivo .env." >&2
    exit 1
fi

# =================================================================
# Procesamiento del Log
# =================================================================

# Función para escapar caracteres HTML especiales de los nombres de los torrents
escape_html() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Obtener los torrents no registrados únicos
# 1. Filtramos las líneas que coinciden con el patrón de error (insensible a mayúsculas/minúsculas)
# 2. Extraemos el nombre del torrent (lo que está después de la marca de tiempo y antes de ' Tracker error:')
# 3. Ordenamos y eliminamos duplicados
unregistered_torrents=$(grep -iE "$SEARCH_PATTERN" "$LOG_PATH" | sed -nE 's/^\[[^]]*\][[:space:]]+(.*)[[:space:]]+Tracker error:[[:space:]]*".*"[[:space:]]+\(.*\)[[:space:]]*$/\1/p' | sort -u)

# Si no hay torrents no registrados, salimos sin enviar mensaje
if [ -z "$unregistered_torrents" ]; then
    echo "No se encontraron torrents no registrados en el log."
    exit 0
fi

# =================================================================
# Envío de Mensaje a Telegram
# =================================================================

# Construir el cuerpo del mensaje en formato HTML
mensaje="⚠️ <b>Torrents no registrados detectados:</b>"$'\n'$'\n'

# Leer línea por línea para escapar caracteres HTML de los nombres y añadirlos al mensaje
while IFS= read -r torrent; do
    if [ -n "$torrent" ]; then
        escaped_torrent=$(escape_html "$torrent")
        mensaje+="• <code>$escaped_torrent</code>"$'\n'
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
