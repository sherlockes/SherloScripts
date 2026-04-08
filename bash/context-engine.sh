#!/bin/bash

###################################################################
#Script Name: context-engine.sh
#Description: Generador de contexto para proyectos con AI
#Args: N/A
#Creation/Update: 20260401/20260408
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

OUTPUT="ai_context.txt"
# 1. LISTA DE CARPETAS A IGNORAR COMPLETAMENTE
IGNORE_DIRS=(".git" "node_modules" "dist" "assets" "img")

# 2. LISTA DE CARPETAS DE "SOLO MUESTRA"
SAMPLE_DIRS=("logs" "data" "texts" "backup")

echo "Generando contexto optimizado..."

# --- Preparar el filtro de exclusión ---
EXCLUDE_ARGS=""
for dir in "${IGNORE_DIRS[@]}"; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS -not -path \"*/$dir/*\" -not -path \"*/$dir\""
done

# --- 1. Cabecera y Estructura ---
echo "--- PROYECTO: $(basename "$PWD") ---" > $OUTPUT
echo "--- FECHA: $(date '+%Y-%m-%d %H:%M') ---" >> $OUTPUT
echo -e "\n--- ESTRUCTURA (Resumida) ---" >> $OUTPUT

# Intentamos usar tree, y si no, usamos find con los filtros de IGNORE_DIRS
if command -v tree >/dev/null 2>&1; then
    tree -I "$(IFS="|"; echo "${IGNORE_DIRS[*]}")" >> $OUTPUT
else
    # ESTA ES LA LÍNEA QUE HEMOS MEJORADO:
    eval "find . -maxdepth 2 $EXCLUDE_ARGS" >> $OUTPUT
fi

# --- 2. Procesar Carpetas de MUESTRA ---
echo -e "\n--- ARCHIVOS DE MUESTRA ---" >> $OUTPUT
for s_dir in "${SAMPLE_DIRS[@]}"; do
    if [ -d "$s_dir" ]; then
        FIRST_FILE=$(find "$s_dir" -type f | head -n 1)
        if [ -n "$FIRST_FILE" ]; then
            echo -e "\n[MUESTRA de la carpeta $s_dir]: $FIRST_FILE" >> $OUTPUT
            cat "$FIRST_FILE" >> $OUTPUT
            echo -e "\n--- Fin de muestra ---" >> $OUTPUT
        fi
    fi
done

# --- 3. Procesar resto de archivos RELEVANTES ---
echo -e "\n--- CÓDIGO FUENTE ---" >> $OUTPUT

find_cmd="find . -type f"
for dir in "${IGNORE_DIRS[@]}"; do
    find_cmd="$find_cmd -not -path \"*/$dir/*\""
done
for dir in "${SAMPLE_DIRS[@]}"; do
    find_cmd="$find_cmd -not -path \"*/$dir/*\""
done
find_cmd="$find_cmd -not -name \"$OUTPUT\" -not -name \"context-engine.sh\""

eval "$find_cmd -exec echo -e \"\n--- FILE: {} ---\" \; -exec cat {} \;" >> $OUTPUT

echo "¡Hecho! El archivo '$OUTPUT' ahora está limpio de carpetas ocultas."
