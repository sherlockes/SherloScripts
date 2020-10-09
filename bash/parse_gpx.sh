#!/bin/bash

#####################################################################
# Script Name: parse_gpx.sh
# Description: Crea un archivo gpx con las cordenadas de los vértices
#              a partir de los archivos *.md de la web en Hugo
# Args: N/A
# Creation/Update: 20200511/20201009
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
#####################################################################

# Cabecera genérica de los archivos gpx
cabecera='<?xml version="1.0"?>
<gpx creator="GPS Visualizer http://www.gpsvisualizer.com/" version="1.1" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">'

# Ruta donde se va a guardar el archivo generado
vertices_gpx='/home/pi/sherblog/static/gpx/mis_vertices.gpx'

# Borra el archivo si ya existe
rm $vertices_gpx

# Incluye la cabecera en el nuevo archivo
echo "$cabecera" >> $vertices_gpx

# Cambia al directorio en el que están los archivos con los vértices
cd /home/pi/sherblog/content/vertices/

# Busca en todos los archivos *.md del directorio
for I in `ls *.md`
do
    # Extraemos el nombre del archivo sin extensión
    nombre=$(echo "$I" | cut -f 1 -d '.')
    # Extraemos el valor de latitud y longitud borrando el espacio inicial
    vertice_lon=$(grep "vertice_lon" $I | cut -f 2 -d ':' | cut -c2-)
    vertice_lat=$(grep "vertice_lat" $I | cut -f 2 -d ':' | cut -c2-)
    # Generamos el nodo para el waypoint
    echo '<wpt lat='$vertice_lat' lon='$vertice_lon'>' >> $vertices_gpx
    echo '<name>'$nombre'</name>' >> $vertices_gpx
    echo '</wpt>' >> $vertices_gpx
done

# Incluye el cierre de la cabecera gpx
echo '</gpx>' >> $vertices_gpx
