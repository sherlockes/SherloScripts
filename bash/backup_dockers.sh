#!/bin/bash

###################################################################
#Script Name: backup_dockers.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250225/20250225
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

FOLDER_TO_BACKUP="~/dockers"  # Cambia esta ruta
REMOTE_NAME="Sherlockes_Mega"
REMOTE_PATH="backup_dockers"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_$(basename "$FOLDER_TO_BACKUP")_$TIMESTAMP.tar.gz"
BACKUP_PATH="/tmp/$BACKUP_NAME"


################################
####      Dependencias      ####
################################


################################
####       Funciones        ####
################################


################################
####    Script principal    ####
################################
# Comprimir la carpeta
echo "Comprimiendo $FOLDER_TO_BACKUP en $BACKUP_PATH..."
sudo tar -czf "$BACKUP_PATH" -C "$FOLDER_TO_BACKUP" .

# Subir a rclone
echo "Subiendo $BACKUP_NAME a $REMOTE_NAME:$REMOTE_PATH..."
rclone copy "$BACKUP_PATH" "$REMOTE_NAME:$REMOTE_PATH/"

# Verificar si la subida fue exitosa
if [ $? -eq 0 ]; then
    echo "Backup subido con éxito."
    sudo rm "$BACKUP_PATH"
else
    echo "Error en la subida del backup."
fi



