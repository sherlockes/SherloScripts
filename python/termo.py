#!/usr/bin/python3

##################################################################
# Script Name: termo.py
# Description: Termostato inteligente a partir de una sonda dh22
#              Y de un relé sonoff integrado mediante google sheets
# Args: N/A
# Creation/Update: 20201104/20201218
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

# Estado del relé
if "rele_estado" in datos_json:
    if datos_json["rele_estado"] == "":
        datos_json["rele_estado"] = "off"
else:
    datos_json["rele_estado"] = "off"

# Hora del ultimo cambio
if "rele_hora_cambio" in datos_json:
    if datos_json["rele_hora_cambio"] == "":
        datos_json["rele_hora_cambio"] = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
else:
    datos_json["rele_hora_cambio"] = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
rele_hora_cambio = datetime.strptime(datos_json["rele_hora_cambio"], '%Y/%m/%d %H:%M:%S')

# Tiempo total encendida
if not "rele_total_on" in datos_json:
    datos_json["rele_total_on"] = 0

# Variable para habilitar el modo de fuera de casa y la consigna de Tª en este modo
if "modo_fuera" in datos_json:
    if datos_json["modo_fuera"] == "":
        datos_json["modo_fuera"] = False
else:
    datos_json["modo_fuera"] = False

if "cons_fuera" in datos_json:
    if datos_json["cons_fuera"] == "":
        datos_json["cons_fuera"] = 16
else:
    datos_json["cons_fuera"] = 16

# Variable para decrementar la Tª de la casa cuando no hay nadie
if "dec_casa_vacia" in datos_json:
    if datos_json["dec_casa_vacia"] == "":
        datos_json["dec_casa_vacia"] = 1
else:
    datos_json["dec_casa_vacia"] = 1


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

####################################################################
##  Clase e Reniciar el archivo de Gsheet  ##
####################################################################

gsheet_datos = Gsheet("shermostat")

#################################################################
##  Establece las consignas de Temperatura actual y posterior  ##
#################################################################
ahora = datetime.now()

if gsheet_datos.online:
    horas = gsheet_datos.leer_fila("config",2)
    datos_json["horas"] = horas
    temperaturas = gsheet_datos.leer_fila("config",3)
    datos_json["temperaturas"] = temperaturas
    consigna_temp_ant = float(gsheet_datos.leer_celda("datos","C2"))
else:
    horas = datos_json["horas"]
    temperaturas = datos_json["temperaturas"]
    consigna_temp_ant = datos_json["consigna"]

def consigna_programa():
    salida = float(temperaturas[len(horas)-1])
    for i in horas:
        hora = datetime.strptime(i, '%H:%M')
        hora = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
        if hora > ahora:
            break
        salida = float(temperaturas[horas.index(i)])
    return salida

def consigna_programa_siguiente():
    # Busca la siguiente consigna en la matriz horas
    for i in horas:
        siguiente = float(temperaturas[horas.index(i)])
        hora = datetime.strptime(i, '%H:%M')
        hora = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
        if hora > ahora:
            break
        siguiente = float(temperaturas[0])
        hora = datetime.strptime(horas[0], '%H:%M')
        manana = ahora + timedelta(days=1)
        hora = manana.replace( hour=hora.hour, minute=hora.minute, second=0)

    # Cambio de consigna de Tª
    minutos_cambio = round(((hora - ahora).seconds)/60)

    salida = [siguiente, minutos_cambio]
    return salida

def consigna_manual():
    hora_manual = datetime.strptime(datos_json["hora_manual"], '%Y/%m/%d %H:%M:%S')
    if round((ahora - hora_manual).seconds/60) < 60:
        print(f"Establecida consigna manual hasta dentro de {60 - round((ahora - hora_manual).seconds/60)} minutos.")
        return True
    else:
        return False

def casa_vacia():
    for usuario in datos_json["personas"]:
        response = os.system("ping " + usuario + " -c 1 > /dev/null 2>&1")
        if response == 0:
            salida = False
            break
        else:
            salida = True
    return salida


# Establecimiento de la consigna de Tª

print("Programa: ", end="")

if datos_json["modo_fuera"]:
    # Activa el modo fuera de casa si está seleccionado en el json
    consigna_temp_act = datos_json["cons_fuera"]
    print(f" Esta habilitado el modo FUERA con una consigna de {consigna_temp_act}ºC")
elif not datos_json["modo_fuera"] and datos_json["consigna"] == datos_json["cons_fuera"]:
    # Recupera la consigna al volver del modo fuera de casa
    consigna_temp_act = consigna_programa()
elif consigna_manual():
    consigna_temp_act = datos_json["cons_manual"]
else:
    consigna_temp_act = consigna_programa()
    datos_json["cons_manual"] = consigna_temp_act

consigna_temp_var = consigna_temp_act - consigna_temp_ant

# Calcula el siguiente cambio de Temperatura
if not datos_json["modo_fuera"]:
    
    consigna_temp_sig = consigna_programa_siguiente()[0]
    minutos_cambio = consigna_programa_siguiente()[1]

    if consigna_temp_act < consigna_temp_sig and minutos_cambio < datos_json["inercia"]/60 and not datos_json["consigna"] == consigna_temp_sig:
        print(f"Se cambia la consigna de Tª de {str(consigna_temp_act)} a {str(consigna_temp_sig)}ºC.")
        Telegram(f"Se cambia la consigna de Tª de {str(consigna_temp_act)} a {str(consigna_temp_sig)}ºC.")
        consigna_temp_act = consigna_temp_sig
    elif consigna_temp_act > consigna_temp_sig and minutos_cambio < (datos_json["inercia"]/60)/3 and not datos_json["consigna"] == consigna_temp_sig:
        print(f"Se cambia la consigna de Tª de {str(consigna_temp_act)} a {str(consigna_temp_sig)}ºC.")
        Telegram(f"Se cambia la consigna de Tª de {str(consigna_temp_act)} a {str(consigna_temp_sig)}ºC.")
        consigna_temp_act = consigna_temp_sig
    else:
        print(f"Consigna actual de {consigna_temp_act}, faltan {str(minutos_cambio)} minutos para cambiar a {str(consigna_temp_sig)}ºC.")

    # Bajar "dec_casa_vacia" si no hay nadie en casa
    print("Control de ausencia: ", end="")
    if casa_vacia():
        dec_casa_vacia = datos_json["dec_casa_vacia"]
        consigna_temp_act -= dec_casa_vacia
        print(f"Casa vacía, se baja {dec_casa_vacia}ºC, queda a {consigna_temp_act}ºC")
    else:
        print("La casa no está vacía, seguimos calentando...")
            

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

#####################################################
## Parámetros de configuración para el Sonoff Mini ##
#####################################################

sonoff_ip = "192.168.1.10"
url = 'http://' + sonoff_ip + ':8081/zeroconf/switch'
url_info = 'http://' + sonoff_ip + ':8081/zeroconf/info'
rele_info = {"deviceid": "1000a501ef", "data": {}}

rele_on = {"deviceid": "1000a501ef", "data": {"switch":"on"}}
rele_off = {"deviceid": "1000a501ef", "data": {"switch":"off"}}

#####################
## Lazo de control ##
#####################

# Comprobar si el relé está online y comprobar el estado
response = os.system("ping " + sonoff_ip + " -c 1 > /dev/null 2>&1")
if response == 0:
    print("Sonoff: El relé está conectado a la red. ", end="" )

    # Estado actual del rele
    consulta=requests.post(url_info, json = rele_info)
    rele_estado = consulta.json()["data"]["switch"]

    if consulta.json()["error"] == 0:
        print(f"Estado del relé - OK ({rele_estado})")
        datos_json["rele_estado"] = rele_estado
    else:
        Telegram("Algo falla en el relé de la calefacción")
        print(f"Estado del relé - KO")
else:
    print("ATENCIÓN!!! El relé no está conectado a la red")
    Telegram("ATENCIÓN!!! El relé de la calefacción no está conectado a la red.")


# Enciende la calefacción si la temp real está por debajo de la histéresis
if interior.temp < (consigna_temp_act - datos_json["histeresis"]) and rele_estado == "off":
    consulta = requests.post(url, json = rele_on )
    if consulta.json()["error"] == 0:
        estado = "on"
        print("Se ha encendido la calefacción")
    else:
        estado = "ERROR en relé"
        Telegram("No ha sido posible encender el rele de la calefacción")     
# Apaga la calefacción si la real mas la esperada por inercia está por encima
elif interior.temp + (var_temp_tiempo * (datos_json["inercia"]/60))> consigna_temp_act + datos_json["histeresis"] and rele_estado == "on":
    consulta = requests.post(url, json = rele_off)
    if consulta.json()["error"] == 0:
        estado = "off"
        print("Se ha apagado la calefacción")
    else:
        estado = "ERROR en relé"
        Telegram("No ha sido posible apagar el rele de la calefacción")
else:
    estado = rele_estado

# Calculo de la variable "rele_hora_cambio" y del tiempo de encendido
rele_tiempo_on = 0

if estado != datos_json["rele_estado"]:

    if estado == "on":
        rele_tiempo_off = datetime.now() - rele_hora_cambio
        rele_tiempo_off = round((rele_tiempo_off.seconds)/60)
        
        # Disminuye la inercia si ha estado poco tiempo apagada
        if rele_tiempo_off < 15 and datos_json["inercia"] >= 300:
            datos_json["inercia"] -= 25
            print("Se ha disminuido la inercia")
            Telegram("Se ha disminuido la inercia de la calefacción")
    
    if estado == "off":
        rele_tiempo_on = datetime.now()-rele_hora_cambio
        rele_tiempo_on = round((rele_tiempo_on.seconds)/60)
        Telegram(f'La calefacción ha estado {rele_tiempo_on} minutos encendida.')
        datos_json["rele_total_on"] += rele_tiempo_on
    
    #Telegram(f'Ha cambiado el estado de la calefacción a {estado}')
    datos_json["rele_hora_cambio"] = datetime.now().strftime('%Y/%m/%d %H:%M:%S')

datos_json["rele_estado"] = estado

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