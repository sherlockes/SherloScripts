#!/bin/bash

###########################################################################
# Script Name: Actualización de www.sherblog.pro en Gitlab.io
# Description:
#	- Sincroniza Google Drive con las carpetas locales
#	- Actualiza los archivos de la nube a los nuevos con cabecera
#	- Sube la web a GitLab
# Args: N/A
# Creation/Update: 20180901/20220125
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################


dir_post=~/sherblog/content/post
mins_mod=15
notificacion=~/SherloScripts/bash/telegram.sh
inicio=$( date +%s )

mensaje=$'Actualización del <a href="https://sherblog.pro">blog</a> mediante <a href="https://raw.githubusercontent.com/sherlockes/SherloScripts/master/bash/publish.sh">publish.sh</a>\n'
mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'

comprobar(){

    if [ $1 -eq 0 ]; then
	mensaje+=$'OK'
    else
	mensaje+=$'ERROR'
    fi
    mensaje+=$'\n'

}

# Comprueba si hay contenido para actualizar
if rclone check Sherlockes_GD:/Sherblog/content/ /home/pi/sherlockes.gitlab.io/content/; then
    echo No hay cambios que actualizar...
else
    echo Actualizando los cambios...
    mensaje+=$'Actualizando los archivos de la web...\n'

    # Sincroniza el contenido de la nube de Google Drive con las carpetas locales

    mensaje+='Sincronizando el directorio Content.....'
    rclone sync -v Sherlockes_GD:/Sherblog/content/ /home/pi/sherlockes.gitlab.io/content/
    comprobar $?

    mensaje+='Sincronizando el directorio Static.....'
    rclone sync -v Sherlockes_GD:/Sherblog/static/ /home/pi/sherlockes.gitlab.io/static/
    comprobar $?

    # Parsea los vertices para generar un gpx y genera la web estática en Hugo
    mensaje+='Generación del archivo GPX.....................'
    ~/SherloScripts/bash/parse_gpx.sh
    comprobar $?

    # Exporta la configuración del crontab a un archivo de texto
    mensaje+='Generación del archivo crontab.txt............'
    crontab -l > /home/pi/sherlockes.gitlab.io/static/files/crontab.txt
    comprobar $?

    # Sube los cambios generados en la web a GitHub
    mensaje+='Actualización de la web en Github.com....'
    cd ~/sherlockes.gitlab.io
    git add .
    git commit -m "Update"
    git push
    comprobar $?

    # Sincroniza el repo con google drive
    mensaje+='Actualización del contenido a Google Drive....'
    rclone sync -v /home/pi/sherlockes.gitlab.io/static/ Sherlockes_GD:/Sherblog/static/
    rclone sync -v /home/pi/sherlockes.gitlab.io/content/ Sherlockes_GD:/Sherblog/content/
    comprobar $?

    # Envia el mensaje de telegram con el resultado
    fin=$( date +%s )
    let duracion=$fin-$inicio
    mensaje+=$'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'
    mensaje+=$"Duración del Script:  $duracion segundos"
    
    $notificacion "$mensaje"
fi

exit 0
