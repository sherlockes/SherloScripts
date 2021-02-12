#!/usr/bin/python3

##################################################################
# Script Name: mqtt.py
# Description: Recibe la Tª del esp8266 mediante mqtt
# Args: N/A
# Creation/Update: 20210212/20210212
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import paho.mqtt.client as mqtt
from etc.sqlite_2 import Sqlite
from pathlib import Path
import os

	# Callback fires when conected to MQTT broker.
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Conectado al servidor MQTT")
    else:
        print("Algo ha fallado en la conexión MQTT")

    # Subscribe (or renew if reconnect).
    client.subscribe('temp_humidity')

# Callback fires when a published message is received.
def on_message(client, userdata, msg):
	# Decode temperature and humidity values from binary message paylod.
    t,h = [float(x) for x in msg.payload.decode("utf-8").split(',')]
    # print(f'Hay una temperatura de {t}ºC y una humedad del {h}%')

    datos_sqlite.salon_nuevo(t,h)

#############################################################
##  Clase e iniciar el archivo de base de datos de SqLite  ##
#############################################################

ruta_db = os.path.join(Path.home(),"termostato.db")
datos_sqlite = Sqlite(ruta_db)


######################################
##  Iniciar el cliente y loop MQTT  ##
######################################

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect('localhost', 1883, 60)

# Processes MQTT network traffic, callbacks and reconnections. (Blocking)
client.loop_forever()
