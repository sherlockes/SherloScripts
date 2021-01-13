#!/usr/bin/python3

import os

from etc.sqlite import Sqlite

from datetime import datetime

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np



ruta_db = os.path.join(Path.home(),"termostato.db")
datos = Sqlite(ruta_db)

datax = []
datay = []
datayy = []

for registro in datos.prueba():
    hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
    datax.append(hora)
    datay.append(registro[1])
    datayy.append(registro[2])

datax.reverse()
datay.reverse()
datayy.reverse()

x = np.array(datax)
y = np.array(datay)
yy = np.array(datayy)

plt.title('Consigna y valor real en Zaragoza')
plt.plot(x, y, label = "Tª Real")
plt.plot(x, yy, label = "Consigna")
plt.xlabel('Horas')
plt.ylabel('Temperaturas')
plt.gcf().autofmt_xdate()
plt.legend()
plt.show()
