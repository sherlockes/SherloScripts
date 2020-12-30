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

import os
import time

from etc.aemet import Aemet
from etc.dht22 import Dht22
from etc.gsheet import Gsheet
from etc.telegram import Telegram
from etc.consigna import Consigna
from etc.sonoff import Sonoff

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

interior = Dht22(4)
datos_json["ultima_temp"] = interior.temp
datos_json["ultima_hume"] = interior.hume

####################################################################
##  Clase e Reniciar el archivo de Gsheet  ##
####################################################################

gsheet_datos = Gsheet("shermostat")

#################################################################
##  Establece las consignas de Temperatura actual y posterior  ##
#################################################################
ahora = datetime.now()

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

if gsheet_datos.online:

    tiempo = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
    tiempo_ant = datetime.strptime(gsheet_datos.leer_fila("datos",2)[0], '%Y/%m/%d %H:%M:%S')
    temp_ant_consigna = float(gsheet_datos.leer_fila("datos",2)[2])
    real_temp_ant = float(gsheet_datos.leer_fila("datos",2)[3])
    hum_ant_real = float(gsheet_datos.leer_fila("datos",2)[4])
    temp_ant_estado = gsheet_datos.leer_fila("datos",2)[5]
    var_temp = abs(interior.temp - real_temp_ant) + abs(consigna_temp_act - consigna_temp_ant)
    var_tiempo = datetime.now() - tiempo_ant
    var_temp_tiempo = round((60*(interior.temp - real_temp_ant))/var_tiempo.seconds,2)
    if abs(var_temp_tiempo) < 0.01:
        var_temp_tiempo = 0

    # Incrementa la inercia si la Tª supera el rango de inercia con la caldera encendida
    if interior.temp > datos_json["inercia_rango"] * (datos_json["consigna"] + datos_json["histeresis"]) and datos_json["rele_estado"] == "on":
        if datos_json["inercia"] <= 1800:
            datos_json["inercia"] += 25
        print("Se ha aumentado la inercia térmica de la caldera")
        Telegram("Se ha aumentado la inercia térmica de la caldera")
else:
    var_temp_tiempo = 0

#####################
## Lazo de control ##
#####################

rele = Sonoff()
rele_estado = rele.estado

# Enciende la calefacción si la temp real está por debajo de la histéresis
if interior.temp < (consigna_temp_act - datos_json["histeresis"]) and rele.estado == "off":
    rele.encender()   
# Apaga la calefacción si la real mas la esperada por inercia está por encima
elif interior.temp + (var_temp_tiempo * (datos_json["inercia"]/60))> consigna_temp_act + datos_json["histeresis"] and rele.estado == "on":
    rele.apagar()
else:
    estado = rele.estado

# Calculo de la variable "rele_hora_cambio" y del tiempo de encendido
rele_tiempo_on = 0

if rele.estado != datos_json["rele_estado"]:

    if rele.estado == "on":
        rele_tiempo_off = datetime.now() - rele_hora_cambio
        rele_tiempo_off = round((rele_tiempo_off.seconds)/60)
        
        # Disminuye la inercia si ha estado poco tiempo apagada
        if rele_tiempo_off < 15 and datos_json["inercia"] >= 300:
            datos_json["inercia"] -= 25
            print("Se ha disminuido la inercia")
            Telegram("Se ha disminuido la inercia de la calefacción")
    
    if rele.estado == "off":
        rele_tiempo_on = datetime.now()-rele_hora_cambio
        rele_tiempo_on = round((rele_tiempo_on.seconds)/60)
        #Telegram(f'La calefacción ha estado {rele_tiempo_on} minutos encendida.')
        datos_json["rele_total_on"] += rele_tiempo_on
    
    #Telegram(f'Ha cambiado el estado de la calefacción a {estado}')
    datos_json["rele_hora_cambio"] = datetime.now().strftime('%Y/%m/%d %H:%M:%S')

datos_json["rele_estado"] = rele.estado

# Enviar el total de minutos en el ultimo informe del día
if datetime.now().hour == 23 and datetime.now().minute >= 54:
    if estado == "on":
        datos_json["rele_total_on"] += 5
    Telegram(f'Hoy la calefacción ha estado {datos_json["rele_total_on"]} minutos encendida con {exterior.temp_media}ºC de media exterior.')
    datos_json["rele_total_on"] = 0


#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################
if gsheet_datos.online:
    print(f"Dato ant: Tª consigna: {consigna_temp_ant} - Tª real:{real_temp_ant}ºC - Calef:{temp_ant_estado} - Humedad:{hum_ant_real}%")
    print(f"Dato act: Tª consigna: {consigna_temp_act} - Tª real:{interior.temp}ºC - Calef:{estado} - Humedad:{interior.hume}%")

    print("Datos GSheet: ", end="")
    # Guarda la consigna (Si ha variado)
    datos_json["consigna"] = consigna_temp_act
    if consigna_temp_var != 0:
        gsheet_datos.escribir_celda("consigna","A1",consigna_temp_act)
        print(f"Nueva consigna a {consigna_temp_act}ºC, ", end="")

    # Guarda los datos (Si han variado o la calefacción está en marcha)
    if var_temp  < 0.1 and estado == temp_ant_estado:
        print("Nada ha cambiado (La humedad no cuenta...)")
    elif var_temp >= 0.1 or rele_estado == "on":
        gsheet_datos.escribir_celda("consigna","A1",consigna_temp_act)
        gsheet_datos.escribir_fila("datos",[tiempo,exterior.temp_actual,consigna_temp_act,interior.temp,interior.hume,rele_estado,var_temp_tiempo,rele_tiempo_on])
        print("Se han guardado los datos actuales.")
else:
    print(f"Dato act: Tª consigna: {consigna_temp_act} - Tª real:{interior.temp}ºC - Calef:{estado} - Humedad:{interior.hume}%")

#######################################################################
## Graba los parámetros de configuración en el archivo "config.json" ##
#######################################################################

with open("/home/pi/config.json", "w") as archivo_json:
    json.dump(datos_json, archivo_json, indent = 4)