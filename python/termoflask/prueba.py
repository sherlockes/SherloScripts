#!/usr/bin/python3

#############################################################
##  Clase e iniciar el archivo de base de datos de SqLite  ##
#############################################################
import logging

import os
from pathlib import Path

import os

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%Y%m%d %H:%M', level=logging.INFO)

import sqlite3
import os

from datetime import datetime

from etc.sqlite_2 import Sqlite



#############################################################
##  Clase e iniciar el archivo de base de datos de SqLite  ##
#############################################################

ruta_db = os.path.join(Path.home(),"termostato.db")
sqlite = Sqlite(ruta_db)


print(f"El ultimo valor de Tª es de {sqlite.salon_media(1)}")
print(f"El ultimo minuto Tª es de {sqlite.salon_media(3)}")
print(f"El ultimo ciclo Tª es de {sqlite.salon_media(10)}")



import pandas as pd
x = pd.Series(range(50))
print(x)
y = pd.Series(sqlite.salon_temp(50))
print(y)
print(type(sqlite.salon_temp(58)))
print(x.corr(y))







