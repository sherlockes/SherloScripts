#!/bin/bash

###################################################################
#Script Name: restic-backup.sh
#Description: Copia de seguridad de contenedores en Uberz
#Args: N/A
#Creation/Update: 20260518/20260518
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

# 1. Cargar variables de entorno desde el archivo .env
ENV_FILE="/home/sherlockes/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "❌ Error: No se encuentra el archivo de entorno en $ENV_FILE"
    exit 1
fi

# Configuración de Restic / Rclone
export RCLONE_CONFIG="/home/sherlockes/.config/rclone/rclone.conf"
REPO_REMOTE="rclone:Sherlockes_Mega:docker_backups"
REPO_LOCAL="/home/sherlockes/restic-backup"
PASSWORD_FILE="/home/sherlockes/.restic-password"

# Función para enviar notificaciones a Telegram
enviar_telegram() {
    local mensaje="$1"
    curl -s -X POST "https://api.telegram.org/bot${TG_TEJELONSOS_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TG_NOTIF_ID}" \
        -d "parse_mode=Markdown" \
        -d "text=${mensaje}" > /dev/null
}

# ==========================================
# SINCRONIZACIÓN PREVIA (RSYNC)
# ==========================================
echo "Sincronizando carpeta Intrubot desde RPI..."
rsync -avz --progress --recursive --mkpath pi@192.168.10.210:/home/pi/dockers/intrubot/ /home/sherlockes/dockers/intrubot
if [ $? -ne 0 ]; then
    enviar_telegram "⚠️ *Backup $(hostname)*: El rsync de Intrubot ha dado fallos, pero se continuará con el backup de Restic."
fi

# ==========================================
# 1. BACKUP EN REMOTO (MEGA)
# ==========================================
echo "Iniciando backup en REMOTO: $(date)"
sudo -E restic -r $REPO_REMOTE --password-file $PASSWORD_FILE backup /home/sherlockes/dockers --exclude="*.mp3" --exclude="*.mp4"

if [ $? -ne 0 ]; then
    enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: El backup en *REMOTO (Mega)* ha fallado."
    exit 1
fi

echo "Aplicando política de retención en REMOTO"
sudo -E restic -r $REPO_REMOTE --password-file $PASSWORD_FILE forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
if [ $? -ne 0 ]; then
    enviar_telegram "⚠️ *Aviso $(hostname)*: El backup remoto se hizo, pero falló la limpieza (Prune REMOTO)."
fi

# ==========================================
# 2. BACKUP EN LOCAL
# ==========================================
# Auto-inicialización del repositorio local si no existe
if [ ! -f "$REPO_LOCAL/config" ]; then
    echo "Inicializando repositorio local..."
    sudo -E restic -r "$REPO_LOCAL" --password-file "$PASSWORD_FILE" init
    if [ $? -ne 0 ]; then
        enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: No se pudo inicializar el repositorio local."
        exit 1
    fi
fi

echo "Iniciando backup en LOCAL: $(date)"
sudo -E restic -r $REPO_LOCAL --password-file $PASSWORD_FILE backup /home/sherlockes/dockers --exclude="*.mp3" --exclude="*.mp4"

if [ $? -ne 0 ]; then
    enviar_telegram "🚨 *FALLO CRÍTICO $(hostname)*: El backup en *LOCAL* ha fallado."
    exit 1
fi

echo "Aplicando política de retención en LOCAL"
sudo -E restic -r $REPO_LOCAL --password-file $PASSWORD_FILE forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
if [ $? -ne 0 ]; then
    enviar_telegram "⚠️ *Aviso $(hostname)*: El backup local se hizo, pero falló la limpieza (Prune LOCAL)."
fi

# ==========================================
# NOTIFICACIÓN DE ÉXITO GENERAL
# ==========================================
echo "Todos los backups completados con éxito: $(date)"
enviar_telegram "🟢 *Backup Completado ($(hostname))*: Las copias en LOCAL y REMOTO se han realizado y purgado correctamente."
