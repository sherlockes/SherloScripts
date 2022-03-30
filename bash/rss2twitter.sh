#!/bin/bash

###################################################################
#Script Name: rss2twiter.sh
#Description: Generación de Tweet cuando hay un nuevo post del blog
#Args: N/A
#Creation/Update: 20220326/20220330
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

ruta=~/temp

rss_url="https://sherblog.pro/index.xml"
tweetsh_url="https://raw.githubusercontent.com/piroor/tweet.sh/trunk/tweet.sh"

# Crea la ruta de descarga si no existe
if [[ ! -e $ruta ]]; then mkdir $ruta; fi

# Instala xmllint si no está disponible
if ! which xmllint >/dev/null; then sudo apt install -y libxml2-utils; fi

# Instala nkf si no está disponible
if ! which nkf >/dev/null; then sudo apt install -y nkf; fi

# Descarga tweet.sh si no está en la ruta
if [[ ! -e $ruta/tweet.sh ]]
then
    curl --fail --silent --show-error $tweetsh_url --output $ruta/tweet.sh
    chmod +x $ruta/tweet.sh
fi

# Función para obtener de un xml 
obtener_xml() {
    salida="$(xmllint --xpath "//$2[$4]/$3" $1 | sed -E "s/<$3>([^<]*)<\/$3>/\1;/g" | rev | cut -c2- | rev)"
    echo "$salida"
}

# Carga el ultimo link guardado del archivo rss descargado anteriormente
link_ultimo=$(obtener_xml $ruta/rss.xml "item" "link" "1")

# Descarga el archivo rss del blog
curl --fail --silent --show-error $rss_url --output $ruta/rss.xml
link_actual=$(obtener_xml $ruta/rss.xml "item" "link" "1")

# Compara el ultimo link con el actual
if [[ $link_ultimo != $link_actual ]]
then
    bash $ruta/tweet.sh post $link_actual
    echo "publicando un enlace"
fi

