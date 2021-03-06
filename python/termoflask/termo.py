#!/usr/bin/python3

##################################################################
# Script Name: termo.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201230
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import requests
import ast
from datetime import datetime
from datetime import timedelta
from datetime import date
import json
from pathlib import Path

import os
import time

from etc.aemet import Aemet
from etc.dht22 import Dht22
from etc.gsheet import Gsheet
from etc.telegram import Telegram
from etc.consigna import Consigna
from etc.sonoff import Sonoff
from etc.sqlite import Sqlite

import logging
logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%Y%m%d %H:%M', level=logging.INFO)

logging.info(f"Inicio - Ejecutando {os.path.realpath(__file__)}")

#######################################################
##  Carga el archivo "config.json" de configuración  ##
#######################################################
with open('/home/pi/config.json', 'r') as archivo_json:
    data = archivo_json.read()

datos_json = json.loads(data)

##########################################
## Inicialización de variables general  ##
##########################################

def inic_var(var,valor):
    if var in datos_json:
        if datos_json[var] == "":
            datos_json[var] = valor
    else:
        datos_json[var] = valor

variables = {
    "rele_estado": "off",
    "rele_hora_cambio": datetime.now().strftime('%Y/%m/%d %H:%M:%S'),
    "histeresis": 0.2,
    "inercia": 750,
    "inercia_rango": 1.013,
    "consigna": 21.0,
    "rele_total_on": 0,
    "cons_manual": 21.0,
    "hora_manual": "2020/12/30 16:45:32",
    "min_manual": 60,
    "modo_fuera": False,
    "cons_fuera": 16,
    "dec_casa_vacia": 1,
    "horas": ["7:45","9:00","12:30","18:00","22:30"],
    "temperaturas": ["22","20.5","21.5","22.5","20.5"]
}

for x in variables:
    inic_var(x,variables[x])

rele_hora_cambio = datetime.strptime(datos_json["rele_hora_cambio"], '%Y/%m/%d %H:%M:%S')

##############################################################################################
##  Capturar datos de la web de la AEMET a partir del nº de estación e intervalo de tiempo  ##
##############################################################################################

exterior = Aemet("9434P",20)
datos_json["aemet_hora"] = exterior.hora
datos_json["aemet_temp"] = exterior.temp_actual
datos_json["aemet_media"] = exterior.temp_media

##########################################################################
##  Capturar datos de Tª y humedad del sensor conectado a la raspberry  ##
##########################################################################

interior = Dht22(4,3)
datos_json["ultima_temp"] = interior.temp
datos_json["ultima_hume"] = interior.hume

#############################################################
##  Clase e iniciar el archivo de base de datos de SqLite  ##
#############################################################

ruta_db = os.path.join(Path.home(),"termostato.db")
datos_sqlite = Sqlite(ruta_db)

#################################################################
##  Establece las consignas de Temperatura actual y posterior  ##
#################################################################

hora_manual = datetime.strptime(datos_json["hora_manual"], '%Y/%m/%d %H:%M:%S')
consigna = Consigna(datos_json["modo_fuera"],datos_json["cons_fuera"],hora_manual,datos_json["cons_manual"],datos_json["min_manual"],datos_json["horas"],datos_json["temperaturas"],datos_json["personas"],datos_json["dec_casa_vacia"])

consigna_temp_ant = datos_json["consigna"]
consigna_temp_act = consigna.actual
consigna_temp_sig = consigna.siguiente
consigna_temp_var = consigna_temp_act - consigna_temp_ant

datos_json["consigna"] = consigna_temp_act

######################
## Cálculo de datos ##
######################

var_tiempo = datetime.now() - datos_sqlite.hora_ant
var_temp_tiempo = round((60*(interior.temp - datos_sqlite.tint_ant))/var_tiempo.seconds,2)

#####################
## Lazo de control ##
#####################

rele = Sonoff()
rele_estado = rele.estado
rele_tiempo_actual = datos_sqlite.ultimo_cambio()

if interior.temp < (consigna_temp_act - datos_json["histeresis"]) and rele.estado == "off":
    rele.encender()
elif (interior.temp + 0.5) > consigna_temp_act and rele.estado == "on" and rele_tiempo_actual > 18:
    rele.apagar()
elif (interior.temp + 0.35) > consigna_temp_act and rele.estado == "on" and rele_tiempo_actual > 14:
    rele.apagar()
elif (interior.temp + 0.25) > consigna_temp_act and rele.estado == "on" and rele_tiempo_actual > 8:
    rele.apagar()
elif (interior.temp + 0.15) > consigna_temp_act and rele.estado == "on":
    rele.apagar()
else:
    estado = rele.estado

datos_json["rele_estado"] = rele.estado
datos_json["rele_total_on"] = datos_sqlite.minutos_dia()

################################################
## Graba los datos en la base de datos sqlite ##
################################################
if exterior.temp_actual == "error":
    datos_sqlite.anterior_dato()
    temp_exterior = datos_sqlite.text_ant
else:
    temp_exterior = exterior.temp_actual

datos_sqlite.nuevo_dato(temp_exterior,interior.temp,consigna.actual,rele.estado)

ahora = datetime.now()

if ahora.minute > 54: datos_sqlite.parametros()
if ahora.hour == 0 and ahora.minute < 5: datos_sqlite.calculo_minutos()
    
#######################################################################
## Graba los parámetros de configuración en el archivo "config.json" ##
#######################################################################

with open("/home/pi/config.json", "w") as archivo_json:
    json.dump(datos_json, archivo_json, indent = 4)
