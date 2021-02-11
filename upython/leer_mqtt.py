##################################################################
# Script Name: main.py
# Description: Conexión y lectura de datos mediante mqtt
# Args: N/A
# Creation/Update: 202102011/20210211
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import machine
import utime
import ubinascii
from umqttsimple import MQTTClient
from ahora import ahora

# Configuración y conexión a mqtt
mqtt_server = '192.168.1.203'
client_id = ubinascii.hexlify(machine.unique_id())
topic_sub = 'temp_humidity'
topic_pub = b'rele'

def connect_and_subscribe():
  client = MQTTClient(client_id, mqtt_server)
  client.set_callback(sub_cb)
  client.connect()
  client.subscribe(topic_sub)
  print('Connected to %s MQTT broker, subscribed to %s topic' % (mqtt_server, topic_sub))
  return client

def restart_and_reconnect():
  print('Failed to connect to MQTT broker. Reconnecting...')
  time.sleep(10)
  machine.reset()
  
def sub_cb(topic, msg):
    
  msg = msg.decode('utf-8')
  if topic == b'rele' and msg == 'on':
    print('Hay que poner el rele a "%s"' % msg)
  if topic == b'temp_humidity':
    temp = float(msg.split(",")[0])
    hume = int(msg.split(",")[1])
    dato=[ahora(),temp,hume]
    print(dato)
    
try:
  client = connect_and_subscribe()
except OSError as e:
  restart_and_reconnect()
  

def fecha(sgs):
    ahora = utime.localtime(sgs)
    año = ahora[0]
    mes = ahora[1]
    #print(mes.len())
    return '%s-%s-%s %s:%s:%s' % (ahora[0], ahora[1], ahora[2], ahora[3], ahora[4], ahora[5])

while True:
  try:
    new_message = client.check_msg()
    if new_message != None:
      client.publish('rele', b'received')
    utime.sleep(1)
  except OSError as e:
    restart_and_reconnect()
