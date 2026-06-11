#!/bin/bash

###################################################################
#Script Name: restic-backup.sh
#Description: Copia de seguridad 100% modular con Restic
#Args: [Ruta al archivo de configuración] (Opcional)
#Creation/Update: 20260518/20260611
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

# 1. Cargar archivo de configuración del backup (Portabilidad total con $HOME)
CONFIG_FILE="${1:-$HOME/.restic-backup}"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Error: No se encuentra el archivo de configuración en $CONFIG_FILE"
    exit 1
fi

# 2. Inyección de variables de entorno para Rclone y Restic
export RCLONE_CONFIG="$RCLONE_CONFIG_PATH"
export RESTIC_PASSWORD="$RESTIC_PASSWORD"

# Función para enviar notificaciones a Telegram
enviar_telegram() {
    local mensaje="$1"
    # Solo envía si las variables de Telegram están configuradas en este archivo
    if [ ! -z "$TG_BOT_TOKEN" ] && [ ! -z "$TG_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TG_CHAT_ID}" \
            -d "parse_mode=Markdown" \
            -d "text=${mensaje}" > /dev/null
    fi
}

# ==========================================
# 1. BACKUP EN REMOTO (MEGA)
# ==========================================
echo "Comprobando repositorio remoto..."
sudo -E restic -r "$REPO_REMOTE" snapshots > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Inicializando repositorio remoto..."
    sudo -E restic -r "$REPO_REMOTE" init
    if [ $? -ne 0 ]; then
        enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: No se pudo inicializar el repositorio REMOTO."
        exit 1
    fi
fi

echo "Iniciando backup en REMOTO: $(date)"
sudo -E restic -r "$REPO_REMOTE" backup "$BACKUP_SOURCE" --exclude="*.mp3" --exclude="*.mp4"

if [ $? -ne 0 ]; then
    enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: El backup en *REMOTO* ha fallado."
    exit 1
fi

echo "Aplicando política de retención en REMOTO"
sudo -E restic -r "$REPO_REMOTE" forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
if [ $? -ne 0 ]; then
    enviar_telegram "⚠️ *Aviso $(hostname)*: El backup remoto se hizo, pero falló la limpieza (Prune REMOTO)."
fi

# ==========================================
# 2. BACKUP EN LOCAL
# ==========================================
# Auto-inicialización del repositorio local si no existe
if [ ! -f "$REPO_LOCAL/config" ]; then
    echo "Inicializando repositorio local..."
    sudo -E restic -r "$REPO_LOCAL" init
    if [ $? -ne 0 ]; then
        enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: No se pudo inicializar el repositorio local."
        exit 1
    fi
fi

echo "Iniciando backup en LOCAL: $(date)"
sudo -E restic -r "$REPO_LOCAL" backup "$BACKUP_SOURCE" --exclude="*.mp3" --exclude="*.mp4"

if [ $? -ne 0 ]; then
    enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: El backup en *LOCAL* ha fallado."
    exit 1
fi

echo "Aplicando política de retención en LOCAL"
sudo -E restic -r "$REPO_LOCAL" forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
if [ $? -ne 0 ]; then
    enviar_telegram "⚠️ *Aviso $(hostname)*: El backup local se hizo, pero falló la limpieza (Prune LOCAL)."
fi

# ==========================================
# NOTIFICACIÓN DE ÉXITO GENERAL
# ==========================================
echo "Todos los backups completados con éxito: $(date)"
enviar_telegram "🟢 *Backup Completado ($(hostname))*: Las copias de [$BACKUP_SOURCE] en LOCAL y REMOTO se han realizado y purgado correctamente."
