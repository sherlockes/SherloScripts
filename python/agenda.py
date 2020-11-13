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
from datetime import timedelta
from datetime import date
import json
import telegram
import os
import time

class Aemet:

    def __init__(self,estacion):
        self.estacion = estacion
        self.url = "http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_" + str(self.estacion) + "_datos-horarios.csv?k=arn&l=" + str(self.estacion) + "&datos=det&w=0&f=temperatura&x=h24"
        self.datos = requests.get(self.url, allow_redirects=True).text.replace('"', "").splitlines()
    
    def temperatura(self):
        # Ultima temperatura en la estación de la web de la AEMET
        return float(self.datos[4].split(",")[1])

class Sensor:
    def __init__(self,sensor,pin):
        self.sensor = sensor
        self.pin = pin

    def valores(self):
        humidity, temperature = dht.read_retry(self.sensor,self.pin)

        while humidity > 100:
            time.sleep(5)
            humidity, temperature = dht.read_retry(self.sensor,self.pin)
        
        return round(temperature,2), round(humidity,2)

captura_aemet = Aemet("9434P")
print(captura_aemet.temperatura())

class Gsheet:
    def __init__(self,archivo):
        self.con = gspread.service_account()
        self.archivo = self.con.open(archivo)
    
    def leer_celda(self,hoja,celda):
        self.hoja = self.archivo.worksheet(hoja)
        return float(self.hoja.acell(celda).value.replace(",", "."))

datos = Gsheet("shermostat")
print(datos.leer_celda("consigna","A1"))

# Coje la consigna de Temperatura de Google sheets
# del archivo "shermostat", la hoja "consigna" y la celda "A1"
conexion = gspread.service_account()
libro_gsheet = conexion.open("shermostat")
hoja_consigna = libro_gsheet.worksheet("consigna")
temp_consigna = float(hoja_consigna.acell('A1').value.replace(",", "."))