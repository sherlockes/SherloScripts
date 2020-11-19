#!/usr/bin/python3
##################################################################
# Script Name: termo.py
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
import json

print(f"Ejecutado a las {datetime.now().hour}:{datetime.now().minute}")

#######################################################
##  Carga el archivo "config.json" de configuración  ##
#######################################################
with open('/home/pi/config.json', 'r') as archivo_json:
    data=archivo_json.read()

datos_json = json.loads(data)

########################################################################
##  Capturar datos de la web de la AEMET a partir del nº de estación  ##
########################################################################
estacion_aemet = "9434P"
url_aemet = "http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_" + estacion_aemet + "_datos-horarios.csv?k=arn&l=" + estacion_aemet + "&datos=det&w=0&f=temperatura&x=h24"

# Inicia la variable aemet_hora
if "aemet_hora" in datos_json:
    print("Se ha recuperado la variable aemet_hora")
    aemet_hora = datetime.strptime(datos_json["aemet_hora"], '%Y/%m/%d %H:%M:%S')
else:
    print("No existe la variable aemet_hora, se asigna la actual")
    aemet_hora = datetime.now()
    datos_json["aemet_hora"] = aemet_hora.strftime('%Y/%m/%d %H:%M:%S')

tiempo_aemet = datetime.now() - aemet_hora

# Si han pasado 20' desde la ultima medida o no existe vuelve a coger la temperatura exterior
if int(tiempo_aemet.seconds/60) > 20 or not "aemet_temp" in datos_json:
    aemet_datos = requests.get(url_aemet, allow_redirects=True).text.replace('"', "").splitlines()
    aemet_temp = float(aemet_datos[4].split(",")[1])
    datos_json["aemet_temp"] = aemet_temp
    aemet_hora = datetime.now()
    datos_json["aemet_hora"] = aemet_hora.strftime('%Y/%m/%d %H:%M:%S')
    print(f"Se ha almacenado la temperatura exterior  ({aemet_temp}ºC)")
else:
    aemet_temp = datos_json["aemet_temp"]
    print(f"Se ha guardado la variable hace menos de 20'({aemet_temp}ºC)")


##########################################################################
##  Capturar datos de Tª y humedad del sensor conectado a la raspberry  ##
##########################################################################
datos_dht = dht.read_retry(dht.DHT22,4)

while datos_dht[0] > 100:
    time.sleep(5)
    datos_dht = dht.read_retry(dht.DHT22,4)
    
real_hume = round(datos_dht[0],2)
real_temp = round(datos_dht[1],2)

####################################################################
##  Clase e Reniciar el archivo de Gsheet  ##
####################################################################

class Gsheet:
    def __init__(self,archivo):
        self.con = gspread.service_account()
        self.archivo = self.con.open(archivo)
    
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
        return self.hoja.row_values(fila)

    # Escribir y ordenar una fila
    def escribir_fila(self,hoja,datos):
        self.hoja = self.archivo.worksheet(hoja)
        self.hoja.append_row(datos)
        self.hoja.sort((1, 'des'), (2, 'des'), range='A2:AA106000')


gsheet_datos = Gsheet("shermostat")

# Estableca las consignas de Temperatura actual y anterior
consigna_temp_act = float(gsheet_datos.leer_celda("consigna","A1"))
consigna_temp_ant = float(gsheet_datos.leer_celda("datos","C2"))
consigna_temp_var = consigna_temp_act - consigna_temp_ant

print("Calculando el programa...")
horas = gsheet_datos.leer_fila("config",2)
temperaturas = gsheet_datos.leer_fila("config",3)

ahora = datetime.now()
for i in horas:
    consigna_temp_sig = float(temperaturas[horas.index(i)])
    hora = datetime.strptime(i, '%H:%M')
    hora = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
    if hora > ahora:
        break
    consigna_temp_sig = temperaturas[0]
    hora = datetime.strptime(horas[0], '%H:%M')
    manana = ahora + timedelta(days=1)
    hora = manana.replace( hour=hora.hour, minute=hora.minute, second=0)

# Cambio de consigna de Tª
minutos_cambio = round(((hora - ahora).seconds)/60)
if consigna_temp_act < consigna_temp_sig and minutos_cambio < datos_json["inercia"]/60:
    print(f"Se cambia la consigna de Tª de {str(consigna_temp_act)} a {str(consigna_temp_sig)}ºC.")
    consigna_temp_act = consigna_temp_sig
elif consigna_temp_act > consigna_temp_sig and minutos_cambio < (datos_json["inercia"]/60)/3:
    print(f"Se cambia la consigna de Tª de {str(consigna_temp_act)} a {str(consigna_temp_sig)}ºC.")
    consigna_temp_act = consigna_temp_sig
else:
    print(f"Consigna actual de {consigna_temp_act}, faltan {str(minutos_cambio)} minutos para cambiar a {str(consigna_temp_sig)}ºC.")

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

if real_temp < (consigna_temp_act - datos_json["histeresis"]) and rele_estado == "off":
    print("Se va a encerder el relé")
    consulta = requests.post(url, json = rele_on )
    if consulta.json()["error"] == 0:
        estado = "on"
        datos_json["rele_hora_on"] = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
    else:
        estado = "ERROR en relé"
        telegram.enviar("No ha sido posible encender el rele de la calefacción")
elif real_temp > consigna_temp_act + datos_json["histeresis"] and rele_estado == "on":
    print("Se va a apagar el relé")
    consulta = requests.post(url, json = rele_off)
    if consulta.json()["error"] == 0:
        estado = "off"
        rele_hora_on = datetime.strptime(datos_json["rele_hora_on"], '%Y/%m/%d %H:%M:%S')
        rele_tiempo_on = datetime.now()-rele_hora_on
        datos_json["rele_hora_on"] = ""
        telegram.enviar(f"La calefacción ha estado {round(rele_tiempo_on.segundos/60)} minutos en marcha")
    else:
        estado = "ERROR en relé"
        telegram.enviar("No ha sido posible apagar el rele de la calefacción")
else:
    estado = rele_estado


#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################

tiempo = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
tiempo_ant = datetime.strptime(gsheet_datos.leer_fila("datos",2)[0], '%Y/%m/%d %H:%M:%S')
temp_ant_consigna = float(gsheet_datos.leer_fila("datos",2)[2])
real_temp_ant = float(gsheet_datos.leer_fila("datos",2)[3])
hum_ant_real = float(gsheet_datos.leer_fila("datos",2)[4])
temp_ant_estado = gsheet_datos.leer_fila("datos",2)[5]
var_temp = abs(real_temp - real_temp_ant) + abs(consigna_temp_act - consigna_temp_ant)
var_tiempo = datetime.now() - tiempo_ant
var_temp_tiempo = round((60*(real_temp - real_temp_ant))/var_tiempo.seconds,2)
if abs(var_temp_tiempo) < 0.01:
    var_temp_tiempo = 0

print(f"Anterior -> Tª consigna: {consigna_temp_ant} - Tª real:{real_temp_ant}ºC - Calef:{temp_ant_estado} - Humedad:{hum_ant_real}%")
print(f"Actual   -> Tª consigna: {consigna_temp_act} - Tª real:{real_temp}ºC - Calef:{estado} - Humedad:{real_hume}%")

if var_temp  < 0.1 and estado == temp_ant_estado:
    print("Nada ha cambiado (La humedad no cuenta...)")
else:
    gsheet_datos.escribir_celda("consigna","A1",consigna_temp_act)
    gsheet_datos.escribir_fila("datos",[tiempo,aemet_temp,consigna_temp_act,real_temp,real_hume,estado,var_temp_tiempo])
    print("Se ha guardado el dato.")

#######################################################################
## Graba los parámetros de configuración en el archivo "config.json" ##
#######################################################################
with open("config.json", "w") as archivo_json:
    json.dump(datos_json, archivo_json, indent = 4)

