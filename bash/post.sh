#!/bin/bash

###################################################################
#Script Name: post.sh
#Description: - Genera un Post de Hugo de un archivo sin formato
#             - Ubicado en "/home/pi/sherblog" de la Raspberry
#             - Llamado por "publish.sh"
#Args: N/A
#Creation/Update: 20191022/20200915
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

dir_post=~/sherblog/content/post
mins_mod=15

add_header(){
    
    
    lines_total=$(wc -l $1 | awk '{print $1}')
    lines_content=$(expr $lines_total - 2)
    echo $1 tiene $lines_total líneas con un contenido de $lines_content líneas.
    echo Colocando la cabecera a $1
    short_title=$(head -n 1 $1) # Asigna la primera línea a "short_title"
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
    echo "thumbnail: \"$(date +%Y%m%d)_"$short_title"_00.jpg\"" >> $file_name
    echo "disable_comments: true" >> $file_name
    echo "authorbox: false" >> $file_name
    echo "toc: true" >> $file_name
    echo "mathjax: false" >> $file_name
    echo "categories:" >> $file_name
    echo "  - \"uncategorized\"" >> $file_name
    echo "tags:" >> $file_name
    echo "  - \"untagged\"" >> $file_name
    echo "draft: false" >> $file_name
    echo "weight: 5" >> $file_name
    echo "---" >> $file_name
    echo $summary >> $file_name
    echo "<!--more--\>" >> $file_name
    echo $content >> $file_name
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



