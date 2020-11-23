#!/usr/bin/python3
##################################################################
# Script Name: renamer.py
# Description: Renombra las fotos de una carpeta según el día que
#              se tomaron (sólo formato *.jpg)
# Args: N/A
# Creation/Update: 20201123/20201123
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################
import os
from exif import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
print(BASE_DIR)

CURR_DIR = os.path.dirname(os.path.realpath(__file__))
print(CURR_DIR)

carpeta = CURR_DIR.split("/")
carpeta.reverse()
carpeta = carpeta[0]

files = os.listdir(CURR_DIR)

for f in files:
    if f.endswith('.jpg'):
        with open(f, 'rb') as image_file:
            my_image = Image(image_file)
    if my_image.has_exif:
        año = my_image.datetime_original.split(" ")[0].split(":")[0]
        mes = my_image.datetime_original.split(" ")[0].split(":")[1]
        dia = my_image.datetime_original.split(" ")[0].split(":")[2]
        
        num = 1
        
        
        for n in range(999):

            number = '{0:03}'.format(num)
            nombre = año + mes + dia + "_" + carpeta + "_" + number +".jpg"
            archivo = os.path.join(CURR_DIR, nombre)

            if os.path.isfile(archivo):
                num += 1
            else:
                break
        
        number = '{0:03}'.format(num)
        nombre_nuevo = año + mes + dia + "_" + carpeta + "_" + number +".jpg"
        archivo_viejo = os.path.join(CURR_DIR, f)

        os.rename(archivo_viejo, nombre_nuevo)