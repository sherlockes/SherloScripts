##################################################################
# Script Name: main.py
# Description: Lectura de temperatura y envío a través de MQTT
# Args: N/A
# Creation/Update: 20210205/20210215
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import machine
from machine import Pin
from time import sleep
import dht 
from etc.umqttsimple import MQTTClient
import ubinascii

import network

# Conexión al wifi
ssid = 'nombre_de_la_red'
password = 'contraseña'

station = network.WLAN(network.STA_IF)
station.active(True)
station.connect(ssid, password)

while station.isconnected() == False:
  pass

print('Wifi connection successful')

# Configuración mqtt
mqtt_server = '192.168.1.203'
client_id = ubinascii.hexlify(machine.unique_id())
topic_pub_temp = b'temp_humidity'

def connect_mqtt():
  global client_id, mqtt_server
  client = MQTTClient(client_id, mqtt_server)
  client.connect()
  print('Connected to %s MQTT broker' % (mqtt_server))
  return client

def restart_and_reconnect():
  print('Failed to connect to MQTT broker. Reconnecting...')
  sleep(10)
  machine.reset()
  
try:
  client = connect_mqtt()
except OSError as e:
  restart_and_reconnect()
  
# Captura de datos del AM2302 En el GIO4 (Pin D2)
sensor = dht.DHT22(machine.Pin(4))

def read_sensor():
  try:
    sleep(2)
    sensor.measure()
    temp = sensor.temperature()
    hum = sensor.humidity()
    print('Temperatura: %.1f C' %temp)
    print('Humedad: %.0f %%' %hum)
    msg = (b'{0:.1f},{1:.0f}'.format(temp, hum))
    return msg
  except OSError as e:
    print("error")
    machine.reset()
    msg = (b'{0:3.1f},{1:3.1f}'.format(0, 0))
    return msg


# Bucle principal
while True:
  try:
    client.publish(topic_pub_temp, read_sensor())
  except OSError as e:
    restart_and_reconnect()
    
  sleep(30)
        
        
