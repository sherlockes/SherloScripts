#!/usr/bin/python3

import os

from etc.sqlite import Sqlite

from pathlib import Path

ruta_db = os.path.join(Path.home(),"termostato.db")
datos = Sqlite(ruta_db)
#datos.nuevo_dato(exterior.temp_actual,interior.temp,consigna.actual,rele.estado)
datos.nueva_media(datos.media("exterior"),datos.media("interior"),222)

