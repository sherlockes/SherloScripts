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

dir_base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
dir_act = os.path.dirname(os.path.realpath(__file__))

carpeta = dir_act.split("/")
carpeta.reverse()
carpeta = str(carpeta[0])
carpeta = carpeta.replace(" ", "_")
print(carpeta)

files = os.listdir(dir_act)

for f in files:
    if f.endswith('.jpg'):
        with open(f, 'rb') as image_file:
            foto = Image(image_file)
        
        if foto.has_exif:
            año = foto.datetime_original.split(" ")[0].split(":")[0]
            mes = foto.datetime_original.split(" ")[0].split(":")[1]
            dia = foto.datetime_original.split(" ")[0].split(":")[2]
            
            num = 1
        
            while True:
                numero = '{0:03}'.format(num)
                nombre = año + mes + dia + "_" + carpeta + "_" + numero +".jpg"
                archivo = os.path.join(dir_act, nombre)

                if os.path.isfile(archivo):
                    num += 1
                else:
                    break
            
            numero = '{0:03}'.format(num)
            nombre_nuevo = año + mes + dia + "_" + carpeta + "_" + numero +".jpg"
            archivo_viejo = os.path.join(dir_act, f)
            os.rename(archivo_viejo, nombre_nuevo)