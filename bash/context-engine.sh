#!/bin/bash

###################################################################
#Script Name: context-engine.sh
#Description: Generador de contexto optimizado con Git y estadísticas
#Args: N/A
#Creation/Update: 20260401/20260408
#Author: www.sherblog.es                                             
#Email: sherlockes@gmail.com                               
###################################################################

OUTPUT="ai_context.txt"
IGNORE_DIRS=(".git" "node_modules" "dist" "assets" "img")
SAMPLE_DIRS=("logs" "data" "texts" "backup")
MAX_SIZE=102400 # 100KB

echo "Generando contexto maestro..."

# --- 0. Detección de entorno ---
IS_GIT=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# --- 1. MANUAL DE INSTRUCCIONES (System Prompt) ---
# Esto es lo primero que leerá la IA
{
    echo "SISTEMA: Actúa como un experto desarrollador Full Stack y arquitecto de software."
    echo "CONTEXTO: A continuación se proporciona la estructura y el código fuente de un proyecto."
    echo "INSTRUCCIONES:"
    echo "  1. Analiza la arquitectura y las dependencias."
    echo "  2. No respondas con código todavía, solo confirma que has recibido el contexto."
    echo "  3. Espera a mis instrucciones específicas para realizar cambios, buscar bugs o añadir funciones."
    echo "---"
    echo "PROYECTO: $(basename "$PWD")"
    echo "FECHA: $(date '+%Y-%m-%d %H:%M')"
    echo "---"
} > $OUTPUT

# --- 2. Estructura del Proyecto ---
echo -e "\n--- ESTRUCTURA COMPLETA (Excluyendo ocultos) ---" >> $OUTPUT
if command -v tree >/dev/null 2>&1; then
    tree >> $OUTPUT 
else
    find . -maxdepth 2 -not -path '*/.*' >> $OUTPUT
fi

# --- 3. Procesar Carpetas de MUESTRA ---
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

# --- 4. Procesar CÓDIGO FUENTE (Filtrado estricto + Texto puro) ---
echo -e "\n--- CÓDIGO FUENTE ---" >> $OUTPUT

if [ "$IS_GIT" = "true" ]; then
    FILES_TO_PROCESS=$(git ls-files --cached --others --exclude-standard)
else
    find_cmd="find . -type f"
    for dir in "${IGNORE_DIRS[@]}"; do find_cmd="$find_cmd -not -path \"*/$dir/*\""; done
    for dir in "${SAMPLE_DIRS[@]}"; do find_cmd="$find_cmd -not -path \"*/$dir/*\""; done
    FILES_TO_PROCESS=$(eval "$find_cmd")
fi

echo "$FILES_TO_PROCESS" | while read -r file; do
    if [[ "$file" == *"$OUTPUT" ]] || [[ "$file" == *"ctx"* ]] || [[ "$file" == *"context-engine"* ]]; then continue; fi
    
    skip=false
    for d in "${IGNORE_DIRS[@]}" "${SAMPLE_DIRS[@]}"; do
        if [[ "$file" == "$d/"* ]] || [[ "$file" == */"$d/"* ]]; then
            skip=true; break
        fi
    done
    [ "$skip" = "true" ] && continue
    [ ! -f "$file" ] && continue

    # Filtro de Binarios
    MIME_TYPE=$(file --mime-type -b "$file" 2>/dev/null || echo "text/plain")
    if [[ ! "$MIME_TYPE" == text/* ]] && [[ ! "$MIME_TYPE" == "application/json" ]] && [[ ! "$MIME_TYPE" == "application/javascript" ]]; then
        continue
    fi

    FILE_SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
    echo -e "\n--- FILE: $file ---" >> $OUTPUT
    
    if [ "$FILE_SIZE" -le "$MAX_SIZE" ]; then
        cat "$file" >> $OUTPUT
    else
        echo "[AVISO: Archivo de $(($FILE_SIZE / 1024))KB. Solo se muestran las primeras 100 líneas]" >> $OUTPUT
        head -n 100 "$file" >> $OUTPUT
        echo -e "\n[... Contenido truncado por tamaño ...]" >> $OUTPUT
    fi
done

# --- 5. Estadísticas y Auto-copy ---
CHARS=$(wc -m < "$OUTPUT")
TOKENS=$((CHARS / 4))

echo -e "\n--- ESTADÍSTICAS ---"
echo "¡Hecho! Contexto preparado con $TOKENS tokens aprox."

if [[ "$OSTYPE" == "darwin"* ]]; then
    pbcopy < "$OUTPUT"
    echo "📋 Copiado al portapapeles (macOS)."
elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard < "$OUTPUT"
    echo "📋 Copiado al portapapeles (Linux)."
elif command -v clip.exe >/dev/null 2>&1; then
    cat "$OUTPUT" | clip.exe
    echo "📋 Copiado al portapapeles (Windows/WSL)."
fi
