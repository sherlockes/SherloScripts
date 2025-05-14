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
URL="https://raw.githubusercontent.com/sherlockes/SherloScripts/refs/heads/master/pi-hole/regex_blocklist.txt"
TMP_LIST="/tmp/youtube_blocklist.txt"
DB="/etc/pihole/gravity.db"


################################
####      Dependencias      ####
################################



################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################

if [[ "$ACTION" != "block" && "$ACTION" != "unblock" ]]; then
    echo "Uso: $0 block|unblock"
    exit 1
fi

# Descargar la lista desde GitHub
curl -s -o "$TMP_LIST" "$URL" || {
    echo "Error al descargar la lista desde $URL"
    exit 1
}

while read line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    if [[ "$line" == regex:* ]]; then
        REGEX="${line#regex:}"

        if [[ "$ACTION" == "block" ]]; then
            # Verificar si ya existe
            EXISTS=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM domainlist WHERE type=3 AND domain = '$REGEX';")
            if [[ "$EXISTS" -eq 0 ]]; then
                echo "Añadiendo regex: $REGEX"
                sudo pihole --regex "$REGEX"
            else
                echo "Ya existe regex: $REGEX"
            fi
        else
            echo "Eliminando regex: $REGEX"
            sudo sqlite3 "$DB" "DELETE FROM domainlist WHERE type=3 AND domain = '$REGEX';"
        fi
    else
        DOMAIN="$line"

        if [[ "$ACTION" == "block" ]]; then
            EXISTS=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM domainlist WHERE type=1 AND domain = '$DOMAIN';")
            if [[ "$EXISTS" -eq 0 ]]; then
                echo "Añadiendo dominio: $DOMAIN"
                sudo pihole deny "$DOMAIN"
            else
                echo "Ya existe dominio: $DOMAIN"
            fi
        else
            echo "Eliminando dominio: $DOMAIN"
            sudo sqlite3 "$DB" "DELETE FROM domainlist WHERE type=1 AND domain = '$DOMAIN';"
        fi
    fi
done < "$TMP_LIST"

# Recargar listas si se ha hecho "unblock"
if [[ "$ACTION" == "unblock" ]]; then
    sudo pihole reloadlists
fi

# Limpiar temporal
rm -f "$TMP_LIST"



