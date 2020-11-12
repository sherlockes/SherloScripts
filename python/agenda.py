#!/usr/bin/python3
##################################################################
# Script Name: termostato.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201111
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################
import json
from datetime import datetime
from datetime import timedelta

archivo_config='config.json'

""" config = {"consigna":21,"horas":[ "8:00", "10:00", "15:15",  "18:30", "22:30"], "temperaturas":[21.5,20.5,21.5,22,21]}



with open(archivo_config, 'w') as f:
    json.dump(config, f)
 """

with open(archivo_config, 'r') as f:
    config = json.load(f)

#edit the data
ahora = datetime.now()


for i in config["horas"]:
    hora = datetime.strptime(i, '%H:%M')
    paso = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
    if paso > ahora:
        break
    hora = datetime.strptime(config["horas"][0], '%H:%M')
    paso = ahora + timedelta(days=1)
    paso = paso.replace( hour=hora.hour, minute=hora.minute, second=0)


print((paso - ahora).seconds)
    





# Tiempo restante hasta el siguiente intervalo (en segundos)
tiempo_restante = (paso - ahora).seconds

# write it back to the file
with open(archivo_config, 'w') as f:
    json.dump(config, f)

