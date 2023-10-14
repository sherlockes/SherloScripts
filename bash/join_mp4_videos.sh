#!/bin/bash

###################################################################
#Script Name: join_mp4_videos.sh
#Description: Une los mp4 de una carpeta
#Args: N/A
#Creation/Update: 20230922/20230922
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

RUTA=~/temp

################################
####      Dependencias      ####
################################

# Instala ffmpeg si no está disponible
if ! which ffmpeg >/dev/null; then sudo apt install -y ffmpeg; fi

################################
####    Script principal    ####
################################

# Nombre del archivo de salida concatenado
output_file="output.mp4"

# Lista de archivos de vídeo en el directorio actual con la extensión .mp4
videos=$(ls *.mp4 2>/dev/null)

# Verificar si hay videos para concatenar
if [ -z "$videos" ]; then
  echo "No se encontraron archivos de vídeo en este directorio."
  exit 1
fi

# Crear un archivo de lista para ffmpeg
list_file="file_list.txt"
rm -f "$list_file"
for video in $videos; do
  echo "file '$video'" >> "$list_file"
done

# Concatenar los vídeos utilizando ffmpeg
ffmpeg -f concat -safe 0 -i "$list_file" -c:v copy -c:a copy "$output_file"

# Limpiar el archivo de lista
rm -f "$list_file"

echo "Concatenación completada. El vídeo concatenado se encuentra en $output_file."
