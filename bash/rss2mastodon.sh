#!/bin/bash

###################################################################
#Script Name: rss2mastodon.sh
#Description: Generación de Toot cuando hay un nuevo post del blog
#Args: N/A
#Creation/Update: 20221213/20221213
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

RUTA=~/temp
RSS_URL="https://sherblog.pro/index.xml"
INSTANCIA="https://emacs.ch"

# Carga los parámetros del archivo de configuración en el directorio de usuario
. ~/config.conf

################################
####      Dependencias      ####
################################

# Crea la RUTA de descarga si no existe
if [[ ! -e $RUTA ]]; then mkdir $RUTA; fi

# Instala xmllint si no está disponible
if ! which xmllint >/dev/null; then sudo apt install -y libxml2-utils; fi

# Instala nkf si no está disponible
if ! which nkf >/dev/null; then sudo apt install -y nkf; fi

################################
####       Funciones        ####
################################

# Función para obtener de un xml 
obtener_xml() {
    SALIDA="$(xmllint --xpath "//$2[$4]/$3" $1 | sed -E "s/<$3>([^<]*)<\/$3>/\1;/g" | rev | cut -c2- | rev)"
    echo "$SALIDA"
}

################################
####    Script principal    ####
################################

# Busca si hay diferencias entre el rss guardado y el publicado
if [ "$(diff $RUTA/rss.xml <(wget --quiet -O - $RSS_URL))" != "" ] 
then
    # Carga el ultimo link guardado del archivo rss descargado anteriormente
    LINK_ULTIMO=$(obtener_xml $RUTA/rss.xml "item" "link" "1")

    # Descarga el archivo rss del blog
    curl --fail --silent --show-error $RSS_URL --output $RUTA/rss.xml
    LINK_ACTUAL=$(obtener_xml $RUTA/rss.xml "item" "link" "1")


    
    # Compara el ultimo link con el actual
    if [[ $LINK_ULTIMO != $LINK_ACTUAL ]]
    then
	curl $INSTANCIA/api/v1/statuses -H "Authorization: Bearer $TOKENM" -F "status=Lo último de mi blog $LINK_ACTUAL"
	echo "publicando un enlace"
    fi
fi



