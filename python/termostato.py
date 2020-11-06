#!/usr/bin/python3
##################################################################
# Script Name: termostato.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201106
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import Adafruit_DHT as dht
import gspread
import requests
import ast
from datetime import datetime
from datetime import date

# fecha y hora local
now = datetime.now()
hora = now.strftime("%H:%M")
fecha = now.strftime("%Y%m%d")

# Coje la consigna de Temperatura de Google sheets
# del archivo "shermostat", la hoja "consigna" y la celda "A1"
conexion = gspread.service_account()
libro_gsheet = conexion.open("shermostat")
hoja_consigna = libro_gsheet.worksheet("consigna")
temp_consigna = float(hoja_consigna.acell('A1').value)

# Coge la temperatura y humedad del DHT22 conectado a la Raspberry
# Lo redondea a 2 decimales
sensor = dht.DHT22
pin = 4
humidity, temperature = dht.read_retry(sensor, pin)
temp_real = round(temperature,2)
hum_real = round(humidity,2)

# Parámetros de configuración para el Sonoff Mini
url = 'http://192.168.1.10:8081/zeroconf/switch'
json_on = {"deviceid": "1000a501ef", "data": {"switch":"on"}}
json_off = {"deviceid": "1000a501ef", "data": {"switch":"off"}}

# Lazo de control
histeresis = 0.5

if temp_real < temp_consigna - histeresis:
    x = requests.post(url, json = json_on )
    respuesta = ast.literal_eval(x.text)
    if respuesta['error'] == 0:
        estado = "ON"
    else:
        estado = "ERROR en relé"
elif temp_real > temp_consigna + histeresis:
    x = requests.post(url, json = json_off)
    respuesta = ast.literal_eval(x.text)
    if respuesta['error'] == 0:
        estado = "OFF"
    else:
        estado = "ERROR en relé"
else:
    estado = "=="


#print(f"Tª consigna: {temp_consigna} - Tª real:{temp_real}ºC - Calef:{estado}")

# Graba los datos en una hoja de Google Sheets si han variado
hoja_datos = libro_gsheet.worksheet("datos")
temp_ultima_consigna = float(hoja_datos.acell('C2').value)
temp_ultima_real = float(hoja_datos.acell('D2').value)
temp_ultima_estado = hoja_datos.acell('E2').value

if temp_real != temp_ultima_real or temp_consigna != temp_ultima_consigna or estado != temp_ultima_estado:
    hoja_datos.append_row([fecha,hora,temp_consigna,temp_real,estado])
    hoja_datos.sort((1, 'des'), (2, 'des'), range='A2:E106000')