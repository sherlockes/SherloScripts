#!/usr/bin/python3

#############################################################
##  Clase e iniciar el archivo de base de datos de SqLite  ##
#############################################################

from etc.sqlite import Sqlite
import os
from pathlib import Path

datos_sqlite = Sqlite("termostato.db")

#datos_sqlite.minutos_dia("2021-01-17")

datos_sqlite.inercia()



