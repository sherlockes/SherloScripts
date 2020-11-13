#!/usr/bin/python3
##################################################################
# Script Name: termostato.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201113
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



###################################################################################
##  Clase para capturar datos de la web de la AEMET a partir del nº de estación  ##
###################################################################################
class Aemet:

    def __init__(self,estacion):
        self.estacion = estacion
        self.url = "http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_" + str(self.estacion) + "_datos-horarios.csv?k=arn&l=" + str(self.estacion) + "&datos=det&w=0&f=temperatura&x=h24"
        self.datos = requests.get(self.url, allow_redirects=True).text.replace('"', "").splitlines()
    
    def temperatura(self):
        # Ultima temperatura en la estación de la web de la AEMET
        return float(self.datos[4].split(",")[1])

#####################################################################
##  Clase para capturar datos del sensor conectado a la raspberry  ##
#####################################################################
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

####################################################################
##  Clase para leer y escribir sobre un archivo de google sheets  ##
####################################################################

class Gsheet:
    def __init__(self,archivo):
        self.con = gspread.service_account()
        self.archivo = self.con.open(archivo)
    
    # Leer una celda numérica y pasar el valor en float
    def leer_celda(self,hoja,celda):
        self.hoja = self.archivo.worksheet(hoja)
        return float(self.hoja.acell(celda).value.replace(",", "."))

    # Leer una ila entera
    def leer_fila(self,hoja,fila):
        self.hoja = self.archivo.worksheet(hoja)
        return self.hoja.row_values(2)

    # Escribir y ordenar una fila
    def escribir_fila(self,hoja,datos):
        self.hoja = self.archivo.worksheet(hoja)
        self.hoja.append_row(datos)
        self.hoja.sort((1, 'des'), (2, 'des'), range='A2:AA106000')


####################################################################################
####    Clase para calcular el tiempo restante hasta el siguiente programa    ####
####################################################################################

class Siguiente:
    def __init__(self, archivo):
        self.dirbase = os.path.dirname(__file__)
        self.archivo = os.path.join(self.dirbase, archivo)
        with open(self.archivo, 'r') as f:
            self.config = json.load(f)

    def calcular(self):
        ahora = datetime.now()

        for i in self.config["horas"]:
            self.temperatura = self.config["temperaturas"][self.config["horas"].index(i)]
            hora = datetime.strptime(i, '%H:%M')
            paso = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
            if paso > ahora:
                break
            hora = datetime.strptime(self.config["horas"][0], '%H:%M')
            paso = ahora + timedelta(days=1)
            paso = paso.replace( hour=hora.hour, minute=hora.minute, second=0)

        self.minutos = round(((paso - ahora).seconds)/60)



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


#####################
## Lazo de control ##
#####################

def calcular_estado_rele():

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
    
    return estado



#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################
def grabar_datos():
    tiempo = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
    tiempo_ant = datetime.strptime(datos.leer_fila("datos",2)[0], '%Y/%m/%d %H:%M:%S')
    temp_ant_consigna = float(datos.leer_fila("datos",2)[2].replace(",", "."))
    temp_ant_real = float(datos.leer_fila("datos",2)[3].replace(",", "."))
    hum_ant_real = float(datos.leer_fila("datos",2)[4].replace(",", "."))
    temp_ant_estado = datos.leer_fila("datos",2)[5]
    var_temp = abs(temp_real - temp_ant_real) + abs(temp_consigna - temp_ant_consigna)
    var_tiempo = datetime.now() - tiempo_ant
    var_temp_tiempo = round((60*(temp_real - temp_ant_real))/var_tiempo.seconds,3)

    print(f"Anterior -> Tª consigna: {temp_ant_consigna} - Tª real:{temp_ant_real}ºC - Calef:{temp_ant_estado} - Humedad:{hum_ant_real}%")
    print(f"Actual   -> Tª consigna: {temp_consigna} - Tª real:{temp_real}ºC - Calef:{estado} - Humedad:{hum_real}%")
   
    if var_temp  < 0.2 and estado == temp_ant_estado:
        print("Nada ha cambiado (La humedad no cuenta...)")
    else:
        datos.escribir_fila("datos",[tiempo,captura_aemet.temperatura(),temp_consigna,temp_real,hum_real,estado,var_temp_tiempo])

    
##################################
####    Programa Principal    ####
##################################

captura_aemet = Aemet("9434P")
captura_sensor = Sensor(dht.DHT22,4)
temp_real = captura_sensor.valores()[0]
hum_real = captura_sensor.valores()[1]
datos = Gsheet("shermostat")
temp_consigna = datos.leer_celda("consigna","A1")
sig_prog = Siguiente('config.json')
sig_prog.calcular()
print("Faltan " + str(sig_prog.minutos) + " minutos para cambiar de temperatura a " + str(sig_prog.temperatura) +"ºC.")
estado = calcular_estado_rele()
grabar_datos()

for i in range(1, 7):
    if estado == "off":
        break
    temp_real = captura_sensor.valores()[0]
    hum_real = captura_sensor.valores()[1]
    estado = calcular_estado_rele()
    grabar_datos()
    time.sleep(30)

