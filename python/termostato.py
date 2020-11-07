#!/usr/bin/python3
##################################################################
# Script Name: termostato.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201107
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import Adafruit_DHT as dht
import gspread
import requests
import ast
from datetime import datetime
from datetime import date

######################
## Captura de datos ##
######################

# fecha y hora local
now = datetime.now()
hora = now.strftime("%H:%M:%S")
fecha = now.strftime("%Y%m%d")

# Ultima temperatura en Zaragoza de la web de la AEMET
estacion = "9034P"
url_aemet="http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_9434P_datos-horarios.csv?k=arn&l=9434P&datos=det&w=0&f=temperatura&x=h24"
datos = requests.get(url_aemet, allow_redirects=True).text.replace('"', "").splitlines()
temp_ext_real=float(datos[4].split(",")[1])

# Coje la consigna de Temperatura de Google sheets
# del archivo "shermostat", la hoja "consigna" y la celda "A1"
conexion = gspread.service_account()
libro_gsheet = conexion.open("shermostat")
hoja_consigna = libro_gsheet.worksheet("consigna")
temp_consigna = float(hoja_consigna.acell('A1').value.replace(",", "."))

# Coge la temperatura y humedad del DHT22 conectado a la Raspberry
# Lo redondea a 2 decimales
sensor = dht.DHT22
pin = 4
humidity, temperature = dht.read_retry(sensor, pin)
temp_real = round(temperature,2)
hum_real = round(humidity,2)

#####################################################
## Parámetros de configuración para el Sonoff Mini ##
#####################################################

url = 'http://192.168.1.10:8081/zeroconf/switch'
rele_on = {"deviceid": "1000a501ef", "data": {"switch":"on"}}
rele_off = {"deviceid": "1000a501ef", "data": {"switch":"off"}}

#####################
## Lazo de control ##
#####################

histeresis = 0.5

if temp_real < temp_consigna - histeresis:
    x = requests.post(url, json = rele_on )
    respuesta = ast.literal_eval(x.text)
    if respuesta['error'] == 0:
        estado = "ON"
    else:
        estado = "ERROR en relé"
elif temp_real > temp_consigna + histeresis:
    x = requests.post(url, json = rele_off)
    respuesta = ast.literal_eval(x.text)
    if respuesta['error'] == 0:
        estado = "OFF"
    else:
        estado = "ERROR en relé"
else:
    estado = "=="
#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################

hoja_datos = libro_gsheet.worksheet("datos")

temp_ant_consigna = float(hoja_datos.acell('D2').value.replace(",", "."))
temp_ant_real = float(hoja_datos.acell('E2').value.replace(",", "."))
temp_ant_estado = hoja_datos.acell('G2').value
hum_ant_real = float(hoja_datos.acell('E2').value.replace(",", "."))


if temp_real == temp_ant_real or temp_consigna == temp_ant_consigna or estado == temp_ant_estado:
    print("Nada ha cambiado")
else:
    hoja_datos.append_row([fecha,hora,temp_ext_real,temp_consigna,temp_real,hum_real,estado])
    hoja_datos.sort((1, 'des'), (2, 'des'), range='A2:E106000')


#print(f"Tª consigna: {temp_consigna} - Tª real:{temp_real}ºC - Calef:{estado}")