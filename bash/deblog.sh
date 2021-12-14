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
	1) rclone_list ;;
	2) des_montar "VideoNas" ;;
	3) Google_Photos ;;
	4) SherloScripts ;;
	5) copy_rclone_config ;;
	6) exit 0;;
	7) exit 0;;
	*) echo -e "...Error..." && sleep 2
    esac
}


echo "Creando arbol de directorios..."
mkdir ~/sherblog_dev

echo "Clonando contenido de GitHub..."
cd ~/sherblog_dev
git clone https://github.com/sherlockes/sherblog.git blog/

echo "Publicando y arrancando el servidor de Hugo..."
cd blog
hugo server

echo "Eliminando las carpetas generadas..."

rm -rf ~/sherblog_dev
echo "Script terminado¡¡¡"

#mkdir dev
#rsync -avzhe ssh --exclude '.git' rpi:~/sherblog/ ~/Sherblog/dev/
#cd dev
#hugo server
