#!/bin/bash

###################################################################
#Script Name: deblog.sh
#Description: Generación de entorno de desarrollo para sherblog.pro
#Args: N/A
#Creation/Update: 20211214/20220125
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################


blog_dev="$(pwd)/sherlockes.gitlab.io"
blog_repo="git@gitlab.com:sherlockes/sherlockes.gitlab.io.git"


# -------------------------------------------------------
# Función para mostrar las diferentes opciones en pantalla
# -------------------------------------------------------
show_menus() {
    clear
    echo "------------------------------------------------"	
    echo "--------------  www.sherblog.pro  --------------"
    echo "------------------------------------------------"
    echo "-- 1. Clonado repositorio"
    echo "-- 2. Actualizar repositorio"
    echo "-- 3. Guardar repositorio"
    echo "-- 4. Lanzar el servidor de Hugo"
    echo "-- 5. Borrar y salir"
    echo "------------------------------------------------"
}

# -------------------------------------------------------
# Función para captar tecla y ejecutar función
# -------------------------------------------------------
read_options(){
    local choice
    read -p "Selecciona una opción [ 1 - 8] " choice
    case $choice in
	1) clonar_git ;;
	2) actualizar_repo ;;
	3) guardar_repo ;;
	4) lanzar_servidor ;;
	5) salir ;;
	*) echo -e "...Error..." && sleep 2
    esac
}

# -------------------------------------------------------
# Función para clonar el repositorio en la carpeta dev
# -------------------------------------------------------
clonar_git(){
    clear
    
    echo "Eliminando las carpetas generadas..."
    rm -rf $blog_dev

    echo "Creando arbol de directorios..."
    mkdir $blog_dev

    echo "Clonando contenido de GitHub..."
    git clone --recurse-submodules $blog_repo $blog_dev

    lanzar_servidor
}

# -------------------------------------------------------
# Actualizar el contenido de desarrollo en el dir local
# -------------------------------------------------------
actualizar_repo(){
    clear
    
    echo "Actualizando el contenido del repositorio..."
    cd $blog_dev
    git fetch
}

# -------------------------------------------------------
# Guardar el contenido de desarrollo en el dir local
# -------------------------------------------------------
guardar_repo(){
    clear
    
    echo "Guardando los cambio en el repositorio..."
    cd $blog_dev
    git add .
    git commit -m "Update"
    git push
}

# -------------------------------------------------------
# Lanzar el servidor de Hugo
# -------------------------------------------------------
lanzar_servidor(){
    echo "Publicando y arrancando el servidor de Hugo..."
    xdg-open http://localhost:1313
    echo $blog_dev
    cd $blog_dev
    hugo server --baseURL=http://localhost:1313
}

# -------------------------------------------------------
# Salir y borrar el contenido temporal
# -------------------------------------------------------
salir(){
    echo "Eliminando las carpetas generadas..."
    sleep 1
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



