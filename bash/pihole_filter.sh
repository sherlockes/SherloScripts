#!/bin/bash

###################################################################
#Script Name: pihole_filter.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20250514/20250514
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

ACTION="$1"
GROUP_NAME="$2"
URL="https://raw.githubusercontent.com/sherlockes/SherloScripts/refs/heads/master/pi-hole/regex_blocklist.txt"
TMP_LIST="/tmp/youtube_blocklist.txt"
DB="/etc/pihole/gravity.db"


################################
####      Dependencias      ####
################################

# Verificar dependencias
REQUIRED_CMDS=("curl" "sqlite3" "pihole" "sudo")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' no está instalado o no está en el PATH."
        exit 1
    fi
done

# Verificar permisos de base de datos
if ! sudo test -r "$DB"; then
    echo "Error: No se puede leer la base de datos $DB"
    exit 1
fi

################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################

# Verificar acción
if [[ "$ACTION" != "block" && "$ACTION" != "unblock" ]]; then
    echo "Uso: $0 block|unblock [nombre_del_grupo]"
    exit 1
fi

# Descargar la lista desde GitHub
curl -s -o "$TMP_LIST" "$URL" || {
    echo "Error al descargar la lista desde $URL"
    exit 1
}

# Si se pasó nombre de grupo, obtener o crear ID
GROUP_ID=""
if [[ -n "$GROUP_NAME" ]]; then
    GROUP_ID=$(sudo sqlite3 "$DB" "SELECT id FROM 'group' WHERE name = '$GROUP_NAME';")
    if [[ -z "$GROUP_ID" ]]; then
        echo "Creando grupo '$GROUP_NAME'"
        sudo sqlite3 "$DB" "INSERT INTO 'group' (enabled, name) VALUES (1, '$GROUP_NAME');"
        GROUP_ID=$(sudo sqlite3 "$DB" "SELECT id FROM 'group' WHERE name = '$GROUP_NAME';")
    fi
fi

while read line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    if [[ "$line" == regex:* ]]; then
        ENTRY="${line#regex:}"
        TYPE=3
    else
        ENTRY="$line"
        TYPE=1
    fi

    if [[ "$ACTION" == "block" ]]; then
        EXISTS=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM domainlist WHERE type=$TYPE AND domain = '$ENTRY';")
        if [[ "$EXISTS" -eq 0 ]]; then
            echo "Añadiendo: $ENTRY"
            sudo sqlite3 "$DB" "INSERT INTO domainlist (type, domain, enabled) VALUES ($TYPE, '$ENTRY', 1);"
            ENTRY_ID=$(sudo sqlite3 "$DB" "SELECT last_insert_rowid();")
            if [[ -n "$GROUP_ID" ]]; then
                sudo sqlite3 "$DB" "INSERT INTO domainlist_by_group (domainlist_id, group_id) VALUES ($ENTRY_ID, $GROUP_ID);"
            fi
        else
            echo "Ya existe: $ENTRY"
        fi
    else
        echo "Eliminando: $ENTRY"
        ENTRY_IDs=$(sudo sqlite3 "$DB" "SELECT id FROM domainlist WHERE type=$TYPE AND domain = '$ENTRY';")
        for ID in $ENTRY_IDs; do
            sudo sqlite3 "$DB" "DELETE FROM domainlist_by_group WHERE domainlist_id = $ID;"
            sudo sqlite3 "$DB" "DELETE FROM domainlist WHERE id = $ID;"
        done
    fi
done < "$TMP_LIST"

if [[ "$ACTION" == "unblock" ]]; then
    sudo pihole reloadlists
fi

rm -f "$TMP_LIST"




