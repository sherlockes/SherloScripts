#!/bin/bash

###################################################################
#Script Name: deblog.sh
#Description: Generación de entorno de desarrollo para sherblog.pro
#Args: N/A
#Creation/Update: 20211214/20220110
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

blog_dev=~/sherblog_dev
blog_repo="https://github.com/sherlockes/sherblog.git"
host_prod="rpi"
blog_prod="rpi:~/sherblog/"
publish_command='./SherloScripts/bash/publish.sh'
content_local=~/Google_Drive/Sherblog/content/

# -------------------------------------------------------
# Función para mostrar las diferentes opciones en pantalla
# -------------------------------------------------------
show_menus() {
    clear
    echo "------------------------------------------------"	
    echo "--------------  www.sherblog.pro  --------------"
    echo "------------------------------------------------"
    echo "-- 1. Clonado desde repositorio de GitHub"
    echo "-- 2. Clonado desde Raspberry"
    echo "-- 3. Copiar el contenido (Post y Vértices)"
    echo "-- 4. Copiar configuración"
    echo "-- 5. Salir"
    echo "------------------------------------------------"
}

# -------------------------------------------------------
# Función para captar tecla y ejecutar función
# -------------------------------------------------------
read_options(){
    local choice
    read -p "Selecciona una opción [ 1 - 8] " choice
    case $choice in
	1) clonar_github ;;
	2) clonar_rpi ;;
	3) guardar_contenido ;;
	4) guardar_config ;;
	5) salir ;;
	*) echo -e "...Error..." && sleep 2
    esac
}

# -------------------------------------------------------
# Función para clonar el repositorio en la carpeta dev
# -------------------------------------------------------
clonar_github(){
    clear
    
    echo "Eliminando las carpetas generadas..."
    rm -rf $blog_dev

    echo "Creando arbol de directorios..."
    mkdir $blog_dev

    echo "Clonando contenido de GitHub..."
    git clone $blog_repo $blog_dev

    lanzar_servidor
}

# -------------------------------------------------------
# Función para clonar el dir de produción en el de dev
# -------------------------------------------------------
clonar_rpi(){
    clear
    
    echo "Eliminando las carpetas generadas..."
    rm -rf $blog_dev

    echo "Creando arbol de directorios..."
    mkdir $blog_dev

    echo "Clonando contenido de la Raspberry..."
    rsync -aqzhe ssh --exclude '.git' $blog_prod $blog_dev

    lanzar_servidor
}

# -------------------------------------------------------
# Guardar el contenido de desarrollo en el dir local
# -------------------------------------------------------
guardar_contenido(){
    clear
    
    echo "Actualizando el contenido del Blog..."
    cd $blog_dev
    rsync -aqzhe ssh --exclude '.git' "$blog_dev/content/" $content_local
    echo "Publicando los cambios..."
    ssh $host_prod $publish_command
}

# -------------------------------------------------------
# Guardar la configuración en el dir de produción
# -------------------------------------------------------
guardar_config(){
    clear
    
    echo "Actualizando la configuración del Blog..."
    cd $blog_dev
    rsync -aqzhe ssh --exclude '.git' --exclude 'content' "$blog_dev/" $blog_prod
    echo "Publicando los cambios..."
    ssh rpi './SherloScripts/bash/publish.sh'
}

# -------------------------------------------------------
# Lanzar el servidor de Hugo
# -------------------------------------------------------
lanzar_servidor(){
    echo "Publicando y arrancando el servidor de Hugo..."
    xdg-open http://localhost:1313
    cd $blog_dev
    hugo server
}

# -------------------------------------------------------
# Salir y borrar el contenido temporal
# -------------------------------------------------------
salir(){
    echo "Eliminando las carpetas generadas..."
    rm -rf $blog_dev
    echo "Script terminado¡¡¡"
    exit 0
}

# ----------------------------------------------
# Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Bucle Principal
# ------------------------------------

while true
do
    sleep 1
    show_menus
    read_options
done



