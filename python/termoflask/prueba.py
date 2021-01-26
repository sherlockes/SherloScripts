#!/usr/bin/python3

#############################################################
##  Clase e iniciar el archivo de base de datos de SqLite  ##
#############################################################

from etc.sqlite import Sqlite
import os
from pathlib import Path
import logging

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%Y%m%d %H:%M', level=logging.INFO)

datos_sqlite = Sqlite("termostato.db")

#print(datos_sqlite.minutos_dia())

#datos_sqlite.parametros()

#datos_sqlite.calculo_minutos()

print(datos_sqlite.ultimo_cambio())





