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

import Adafruit_DHT as dht
import gspread
import requests
import ast
from datetime import datetime
from datetime import date
import telegram
import os

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

sonoff_ip = "192.168.1.10"
url = 'http://' + sonoff_ip + ':8081/zeroconf/switch'
url_info = 'http://' + sonoff_ip + ':8081/zeroconf/info'
rele_info = {"deviceid": "1000a501ef", "data": {}}
url = 'http://192.168.1.10:8081/zeroconf/switch'
rele_on = {"deviceid": "1000a501ef", "data": {"switch":"on"}}
rele_off = {"deviceid": "1000a501ef", "data": {"switch":"off"}}

# Comprobar si el relé está online y comprobar el estado
response = os.system("ping -c 1 " + sonoff_ip)
if response == 0:
    print("El relé está conectado a la red")

    # Estado actual del rele
    consulta=requests.post(url_info, json = rele_info)
    rele_estado = consulta.json()["data"]["switch"]

    if consulta.json()["error"] == 0:
        print(f"Estado del relé - OK ({rele_estado})")
    else:
        telegram.enviar("Algo falla en el relé de la calefacción")
        print(f"Estado del relé - KO")
else:
    print("ATENCIÓN!!! El relé no está conectado a la red")
    telegram.enviar("ATENCIÓN!!! El relé de la calefacción no está conectado a la red.")


#####################
## Lazo de control ##
#####################

histeresis = 0.3

if temp_real < temp_consigna - histeresis and rele_estado == "off":
    print("Se va a encerder el relé")
    consulta = requests.post(url, json = rele_on )
    if consulta.json()["error"] == 0:
        estado = "on"
    else:
        estado = "ERROR en relé"
        telegram.enviar("No ha sido posible encender el rele de la calefacción")
elif temp_real > temp_consigna + histeresis and rele_estado == "on":
    print("Se va a apagar el relé")
    consulta = requests.post(url, json = rele_off)
    if consulta.json()["error"] == 0:
        estado = "off"
    else:
        estado = "ERROR en relé"
        telegram.enviar("No ha sido posible apagar el rele de la calefacción")
else:
    estado = rele_estado


#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################

hoja_datos = libro_gsheet.worksheet("datos")

tiempo_ant = datetime.strptime(hoja_datos.acell('A2').value, '%Y/%m/%d %H:%M:%S')
temp_ant_consigna = float(hoja_datos.acell('C2').value.replace(",", "."))
temp_ant_real = float(hoja_datos.acell('D2').value.replace(",", "."))
temp_ant_estado = hoja_datos.acell('F2').value
hum_ant_real = float(hoja_datos.acell('E2').value.replace(",", "."))

print(f"Anterior -> Tª consigna: {temp_ant_consigna} - Tª real:{temp_ant_real}ºC - Calef:{temp_ant_estado} - Humedad:{hum_ant_real}%")
print(f"Actual   -> Tª consigna: {temp_consigna} - Tª real:{temp_real}ºC - Calef:{estado} - Humedad:{hum_real}%")

variacion = abs(temp_real - temp_ant_real) + abs(temp_consigna - temp_ant_consigna)
print(f"Hay una variación de {variacion}")
ahora = datetime.now().strftime('%Y/%m/%d %H:%M:%S')

if variacion  < 0.2 and estado == temp_ant_estado:
    print("Nada ha cambiado (La humedad no cuenta...)")
else:
    hoja_datos.append_row([ahora,temp_ext_real,temp_consigna,temp_real,hum_real,estado])
    hoja_datos.sort((1, 'des'), (2, 'des'), range='A2:AA106000')