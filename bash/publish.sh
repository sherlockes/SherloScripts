#!/bin/bash
# -*- encoding: utf-8 -*-

###########################################################################
# Script Name: Actualización de www.sherblog.pro
# Description:
#	- Actualiza Hugo (Eliminado por actualización diaria aparte)
#	- Sincroniza Google Drive con las carpetas locales
#	- Añade una cabecera a los archivos que no la tienen
#	- Actualiza los archivos de la nube a los nuevos con cabecera
#	- Genera la web estática
#	- Sube la web a GitHub
# Args: N/A
# Creation/Update: 20180901/20200801
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################

# Comprueba si hay contenido para actualizar

if rclone check --one-way Sherlockes_GD:/Sherblog/content/ /home/pi/sherblog/content/; then
    echo No hay cambios que actualizar...
else
    echo Actualizando los cambios...

    # Sincroniza el contenido de la nube de Google Drive con las carpetas locales
    rclone sync -v Sherlockes_GD:/Sherblog/content/ /home/pi/sherblog/content/
    rclone sync -v Sherlockes_GD:/Sherblog/static/ /home/pi/sherblog/static/
    rclone sync -v Sherlockes_GD:/Sherblog/layouts/ /home/pi/sherblog/layouts/

    # Parsea los vertices para generar un gpx y genera la web estática en Hugo
    cd ~/sherblog
    ./parse_gpx.sh
    /usr/local/bin/hugo

    # Sube los cambios generados en la web a GitHub
    cd ~/sherblog/sherlockes.github.io
    git add --all
    git commit -m "Update"
    git push -u origin master
fi


# Busca archivos sin cabecera para añadirle una genérica en "post"
cd ~/sherblog/content/post
grep -r -L "\-\-\-" * |
while read fname
do
  # Minutos que han de pasar desde la ultima modificación para encabezado
  minmin=70

  # Calculo de los minutos pasados desde la ultima moficicacion
  umodsg=$(date +%s -r "$fname")
  ahorasg=$(date +%s)
  minpasados=$(((ahorasg - umodsg)/60))
  echo Han pasado $minpasados de los $minmin minutos desde la modificación de "$fname"

  # Inserta la cabecera si han pasado más de 70 minutos
  if [ $minpasados -gt $minmin ]; then
    echo Colocando la cabecera a "$fname"
    cat cabecera.md "$fname" > temp && mv temp "$fname"
  fi

  # Sincroniza los archivos de la nube con los modificados en local
  rclone sync -v /home/pi/sherblog/content/post/ Sherlockes_GD:/Sherblog/content/post/

done

exit 0
