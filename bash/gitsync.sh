#!/bin/bash

###################################################################
# Script Name: GITSYNC.SH
# Description: Actualiza un repo de github
# Args: N/A
# Creation/Update: 20260609/20260609
# Author: www.sherblog.es
# Email: sherlockes@gmail.com
###################################################################

# Configuración por defecto de Git
REMOTE_NAME="origin"
BRANCH_NAME="main"

# 1. Capturar la ruta (si se pasa un argumento, la usa; si no, usa el directorio actual)
REPO_DIR="${1:-.}"

# Convertir a ruta absoluta para que los mensajes sean claros
REPO_DIR=$(cd "$REPO_DIR" 2>/dev/null && pwd)

# Verificar si el directorio existe
if [ -z "$REPO_DIR" ]; then
    echo "❌ Error: El directorio especificado no existe."
    exit 1
fi

# Cambiar al directorio del repositorio
cd "$REPO_DIR" || exit 1
echo "📂 Trabajando en el repositorio: $REPO_DIR"

# 2. Comprobar si realmente es un repositorio de Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ Error: '$REPO_DIR' no es un repositorio de Git válido."
    exit 1
fi

# 3. Verificar la conexión SSH con GitHub
echo "🔄 Comprobando conexión SSH con GitHub..."
ssh -T git@github.com -o ConnectTimeout=5 > /dev/null 2>&1
if [ $? -eq 255 ]; then
    echo "❌ Error: No se pudo establecer conexión SSH con GitHub."
    exit 1
fi

# 4. Traer las últimas referencias del remoto
echo "🔄 Descargando últimas referencias de '$REMOTE_NAME'..."
git fetch $REMOTE_NAME 2>/dev/null

# 5. Obtener los hashes de los commits
LOCAL=$(git rev-parse @ 2>/dev/null)
REMOTE=$(git rev-parse "$REMOTE_NAME/$BRANCH_NAME" 2>/dev/null)
BASE=$(git merge-base @ "$REMOTE_NAME/$BRANCH_NAME" 2>/dev/null)

# Validar que la rama remota exista antes de comparar
if [ -z "$REMOTE" ]; then
    echo "❌ Error: No se pudo encontrar la rama '$BRANCH_NAME' en el remoto '$REMOTE_NAME'."
    exit 1
fi

echo "---"
echo "💻 Local:  ${LOCAL:0:7}"  # Mostramos solo los primeros 7 caracteres del hash
echo "🌐 Remoto: ${REMOTE:0:7}"
echo "---"

# 6. Lógica de comparación y acción
if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ Todo actualizado. Sin cambios pendientes."
    
elif [ "$LOCAL" = "$BASE" ]; then
    echo "⬇️ El remoto tiene cambios nuevos. Haciendo PULL..."
    git pull $REMOTE_NAME $BRANCH_NAME

elif [ "$REMOTE" = "$BASE" ]; then
    echo "⬆️ Tienes cambios locales nuevos. Haciendo PUSH..."
    git push $REMOTE_NAME $BRANCH_NAME

else
    echo "⚠️ ¡Alerta! Las ramas han divergido de forma manual."
    echo "Revisa el estado con 'git status'."
    exit 1
fi
