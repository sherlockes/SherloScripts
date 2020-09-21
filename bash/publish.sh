#!/bin/bash

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
# Creation/Update: 20180901/20200921
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
############################################################################


dir_post=~/sherblog/content/post
mins_mod=15

add_header(){ 
    lines_total=$(wc -l $1 | awk '{print $1}')
    lines_content=$(expr $lines_total - 2)
    echo $1 tiene $lines_total líneas con un contenido de $lines_content líneas.
    echo Colocando la cabecera a $1
    # Asigna la primera línea a "short_title", elimina los espacios y los convierte en guión bajo.
    short_title=$(head -n 1 $1 | sed 's/ /_/g') 
    # Elimina los espacios y los convierte en guión bajo
    #short_title="$(echo $short_title | sed 's/ /_/g')"

    echo El título será: $short_title
    long_title=$(sed '2q;d' $1) # Asigna la segunda línea a "long_title"
    echo El título largo será: $long_title
    all_content=$(tail -$lines_content $1)
    summary=$(echo $all_content| cut -d'.' -f 1)"."
    echo El resumen será: $summary
    content=$(echo $all_content| cut -d'.' -f2-)
    echo El contenido será: $content

    file_name="$(date +%Y%m%d)_$short_title.md"
    thumbnail="images/$(date +%Y%m%d)_$short_title_00.jpg"
    echo $thumbnail
    echo El nombre del archivo será: $file_name

    echo "---" >> $file_name
    echo "title: \"$long_title\"" >> $file_name
    echo "date: \"$(date +%Y-%m-%d)\"" >> $file_name
    echo "creation: \"$(date +%Y-%m-%d)\"" >> $file_name
    echo "descrption: \"$long_title\"" >> $file_name
    echo "thumbnail: \"/images/$(date +%Y%m%d)_"$short_title"_00.jpg\"" >> $file_name
    echo "disable_comments: true" >> $file_name
    echo "authorbox: false" >> $file_name
    echo "toc: true" >> $file_name
    echo "mathjax: false" >> $file_name
    echo "categories:" >> $file_name
    echo "  - \"uncategorized\"" >> $file_name
    echo "tags:" >> $file_name
    echo "  - \"untagged\"" >> $file_name
    echo "draft: true" >> $file_name
    echo "weight: 5" >> $file_name
    echo "---" >> $file_name
    echo $summary >> $file_name
    echo "<!--more-->" >> $file_name
    echo $content >> $file_name
    echo "[Image_01]: /images/$(date +%Y%m%d)_"$short_title"_01.jpg"
}

min_time(){
    echo "Calculando el tiempo desde la última modificación de $1 ..."
    last_mod_sg=$(date +%s -r $1)
    now_sg=$(date +%s)
    mins_last_mod=$(((now_sg - last_mod_sg)/60))

    if [ $mins_last_mod -gt $mins_mod ]
    then
	return 0
    else
	return 1
    fi
    
}

scan_posts(){

    #Cambio al directorio de contenidos
    cd $dir_post

    #Busca archivos sin cabecera para añadirle una genérica
    grep -r -L "\-\-\-" * |
    while read fname
    do
        #Inserta la cabecera si ha pasado el tiempo mínimo y borra el original
        if min_time "$fname"
        then
	    add_header "$fname"
        rm $fname
        else
	    echo No ha pasado el tiempo suficiente para "$fname"
        fi
    done
}

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

scan_posts

# Sincroniza los archivos de la nube con los modificados en local
rclone sync -v /home/pi/sherblog/content/ Sherlockes_GD:/Sherblog/content/

exit 0
