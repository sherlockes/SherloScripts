#!/bin/bash

###################################################################
#Script Name: backup_dockers.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250225/20250312
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

export RCLONE_CONFIG="/home/sherlockes/.config/rclone/rclone.conf"

REPO="rclone:Sherlockes_Mega:docker_backups"
PASSWORD_FILE="/home/sherlockes/.restic-password"

################################
####    Script principal    ####
################################

# Copiar la carpeta del docker intrubot en RPI
echo "Copiando Intrubot config desde RPI"
rsync -avz --progress --recursive --mkpath pi@192.168.10.210:/home/pi/dockers/i>

# Realizar backup
echo "Iniciando backup de ~/dockers: $(date)"
sudo -E restic -r $REPO --password-file $PASSWORD_FILE backup ~/dockers --exclu>

# Política de retención (opcional)
echo "Aplicando política de retención"
sudo -E restic -r $REPO --password-file $PASSWORD_FILE forget --keep-daily 7 -->





