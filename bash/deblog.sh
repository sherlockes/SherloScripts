#!/bin/bash

###################################################################
#Script Name: deblog.sh
#Description: Generación de entorno de desarrollo para sherblog.pro
#Args: N/A
#Creation/Update: 20211214/20211214
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

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
    echo "-- 3. Salir"
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
	3) salir ;;
	*) echo -e "...Error..." && sleep 2
    esac
}

clonar_github(){
    clear
    
    echo "Eliminando las carpetas generadas..."
    rm -rf ~/sherblog_dev

    echo "Creando arbol de directorios..."
    mkdir ~/sherblog_dev

    echo "Clonando contenido de GitHub..."
    cd ~/sherblog_dev
    git clone https://github.com/sherlockes/sherblog.git blog/

    lanzar_servidor
}

clonar_rpi(){
    clear
    
    echo "Eliminando las carpetas generadas..."
    rm -rf ~/sherblog_dev

    echo "Creando arbol de directorios..."
    mkdir ~/sherblog_dev

    echo "Clonando contenido de la Raspberry..."
    cd ~/sherblog_dev
    rsync -avzhe ssh --exclude '.git' rpi:~/sherblog/ blog/

    lanzar_servidor
}

lanzar_servidor(){
    echo "Publicando y arrancando el servidor de Hugo..."
    xdg-open http://localhost:1313
    cd blog
    hugo server
}

salir(){
    echo "Eliminando las carpetas generadas..."

    rm -rf ~/sherblog_dev
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



