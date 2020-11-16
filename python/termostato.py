#!/usr/bin/python3
##################################################################
# Script Name: termostato.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201116
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


histeresis = 0.3
inercia = 1200
tiempoON = 0.0
hora_on = datetime.now()

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
        self.datos = requests.get(self.url, allow_redirects=True).text.replace('"', "").splitlines()
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
        self.humedad = round(humidity,2)
        self.temperatura = round(temperature,2)
        return round(temperature,2), round(humidity,2)

####################################################################
##  Clase para leer y escribir sobre un archivo de google sheets  ##
####################################################################

class Gsheet:
    def __init__(self,archivo):
        self.con = gspread.service_account()
        self.archivo = self.con.open(archivo)
        self.consigna_act = float(self.leer_celda("consigna","A1"))
        self.consigna_ant = float(self.leer_fila("datos",2)[2])

    def actualizar(self):
        self.consigna_act = float(self.leer_celda("consigna","A1"))
        self.consigna_ant = float(self.leer_fila("datos",2)[2])
    
    # Leer una celda numérica y pasar el valor en float
    def leer_celda(self,hoja,celda):
        self.hoja = self.archivo.worksheet(hoja)
        return float(self.hoja.acell(celda).value.replace(",", "."))

    def escribir_celda(self,hoja,celda,valor):
        self.hoja = self.archivo.worksheet(hoja)
        self.hoja.update(celda, valor)

    # Leer una fila entera
    def leer_fila(self,hoja,fila):
        self.hoja = self.archivo.worksheet(hoja)
        return self.hoja.row_values(2)

    # Escribir y ordenar una fila
    def escribir_fila(self,hoja,datos):
        self.hoja = self.archivo.worksheet(hoja)
        self.hoja.append_row(datos)
        self.hoja.sort((1, 'des'), (2, 'des'), range='A2:AA106000')

    # Calcula la Tº del cambio y los minutos restantes.
    def programa(self):
        print("Calculando el programa...")
        horas = self.archivo.worksheet("config").row_values(2)
        temperaturas = self.archivo.worksheet("config").row_values(3)

        ahora = datetime.now()
        for i in horas:
            self.consigna_sig = temperaturas[horas.index(i)]
            hora = datetime.strptime(i, '%H:%M')
            hora = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
            if hora > ahora:
                break
            self.consigna_sig = temperaturas[0]
            hora = datetime.strptime(horas[0], '%H:%M')
            manana = ahora + timedelta(days=1)
            hora = manana.replace( hour=hora.hour, minute=hora.minute, second=0)

        self.minutos_cambio = round(((hora - ahora).seconds)/60)
        print(f"Consigna actual de {str(self.consigna_act)}, faltan {str(self.minutos_cambio)} minutos para cambiar a {str(self.consigna_sig)}ºC.")

        

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
    global tiempoON
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

    # Tª que va a ganar por la inercia de la calefacción
    if tiempoON > inercia:
        gan_temp = inercia * 0.03
    elif tiempoON > inercia + 300:
        gan_temp = inercia * 0.06
    elif tiempoON > inercia + 600:
        gan_temp = inercia * 0.09
    else:
        gan_temp = inercia * 0.01

    if (temp_real + gan_temp) < temp_consigna - histeresis and rele_estado == "off":
        print("Se va a encerder el relé")
        consulta = requests.post(url, json = rele_on )
        if consulta.json()["error"] == 0:
            estado = "on"
            hora_on = datetime.now()
            tiempoON = 0
        else:
            estado = "ERROR en relé"
            telegram.enviar("No ha sido posible encender el rele de la calefacción")
    elif temp_real > temp_consigna + histeresis and rele_estado == "on":
        print("Se va a apagar el relé")
        consulta = requests.post(url, json = rele_off)
        if consulta.json()["error"] == 0:
            estado = "off"
            telegram.enviar(f"La calefacción ha estado {tiempoON/60} minutos en marcha")
        else:
            estado = "ERROR en relé"
            telegram.enviar("No ha sido posible apagar el rele de la calefacción")
    else:
        if rele_estado == "on":
            tiempoON = datetime.now()-hora_on

        estado = rele_estado


    
    return estado

#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################
def grabar_datos():
    tiempo = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
    tiempo_ant = datetime.strptime(datos.leer_fila("datos",2)[0], '%Y/%m/%d %H:%M:%S')
    temp_ant_consigna = float(datos.leer_fila("datos",2)[2])
    temp_ant_real = float(datos.leer_fila("datos",2)[3])
    hum_ant_real = float(datos.leer_fila("datos",2)[4])
    temp_ant_estado = datos.leer_fila("datos",2)[5]
    var_temp = abs(temp_real - temp_ant_real) + abs(temp_consigna - temp_ant_consigna)
    var_tiempo = datetime.now() - tiempo_ant
    var_temp_tiempo = round((60*(temp_real - temp_ant_real))/var_tiempo.seconds,2)
    if abs(var_temp_tiempo) < 0.01:
        var_temp_tiempo = 0

    print(f"Anterior -> Tª consigna: {temp_ant_consigna} - Tª real:{temp_ant_real}ºC - Calef:{temp_ant_estado} - Humedad:{hum_ant_real}%")
    print(f"Actual   -> Tª consigna: {temp_consigna} - Tª real:{temp_real}ºC - Calef:{estado} - Humedad:{hum_real}%")
   
    if var_temp  < 0.1 and estado == temp_ant_estado:
        print("Nada ha cambiado (La humedad no cuenta...)")
    else:
        datos.escribir_fila("datos",[tiempo,captura_aemet.temperatura(),temp_consigna,temp_real,hum_real,estado,var_temp_tiempo,tiempoON])
        print("Se ha guardado el dato.")

    
##################################
####    Programa Principal    ####
##################################

time.sleep(30)

# Coge la temperatura exterior de la web de la AEMET
captura_aemet = Aemet("9434P")

# Inicia el sensor de humedad y Tª de la Raspberry
captura_sensor = Sensor(dht.DHT22,4)


# Inicia la hoja de cálculo de google Sheets
datos = Gsheet("shermostat")

while True:

    captura_aemet.temperatura()
    captura_sensor.valores()
    temp_real = captura_sensor.temperatura
    hum_real = captura_sensor.humedad
    datos.actualizar()
    datos.programa()
    temp_consigna = datos.leer_celda("consigna","A1")

    if datos.minutos_cambio < inercia/60 and abs(datos.consigna_act - datos.consigna_sig) > 0:
        datos.consigna_act = datos.consigna_sig
        datos.escribir_celda("consigna","A1",datos.consigna_sig)
        print("Se ha actualizado la temperatura.")
        telegram.enviar(f"Se ha cambiado la Tª de {datos.consigna_act}ºC a {datos.consigna_sig}ºC")

    estado = calcular_estado_rele()

    grabar_datos()

    if estado == "on":
        time.sleep(30)
    else:
        time.sleep(300)
    print("--------------------------------")
