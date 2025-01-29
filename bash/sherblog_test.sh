#!/bin/bash

###################################################################
#Script Name: sherblog_test.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250105/20250105
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

set -e  # Detener el script en caso de error

echo "=== Configuración del entorno de pruebas para Hugo ==="

################################
####       Variables        ####
################################

REPO_URL="https://github.com/sherlockes/sherlockes.github.io.git"
TEST_DIR="$HOME/hugo-test"
HUGO_SCRIPT="./hugo.sh"

################################
####      Dependencias      ####
################################

# Crear la carpeta de pruebas o borrar si existe
if [ -d "$TEST_DIR" ]; then
    echo "La carpeta $TEST_DIR ya existe. Se borrará su contenido."
    read -p "¿Estás seguro de que deseas continuar? (s/n): " CONFIRM
    if [[ "$CONFIRM" != "s" ]]; then
        echo "Operación cancelada."
        exit 1
    fi
    rm -rf "$TEST_DIR"/* "$TEST_DIR"/.[!.]* "$TEST_DIR"/..?*
else
    echo "Creando la carpeta $TEST_DIR..."
    mkdir -p "$TEST_DIR"
fi

# Comprobar si Hugo está instalado
if [[ -f "$HUGO_SCRIPT" ]]; then
    source "$HUGO_SCRIPT"
else
    echo "Error: El archivo $HUGO_SCRIPT no se encuentra en el directorio actual."
fi

################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################

# Clonar el repositorio
echo "Clonando el repositorio en $TEST_DIR..."
git clone "$REPO_URL" "$TEST_DIR"

# Eliminar el origen de Git
echo "Eliminando el origen de Git del entorno de pruebas..."
cd "$TEST_DIR"
git remote remove origin
rm -rf .git

# Iniciar el servidor de desarrollo de Hugo con fast render deshabilitado
echo "Iniciando el servidor de desarrollo de Hugo (fast render deshabilitado)..."
hugo server -D --disableFastRender --bind "0.0.0.0" --baseURL "http://localhost:1313"

echo "=== Entorno de pruebas configurado con éxito ==="

