#!/usr/bin/python3
import sys
import Adafruit_DHT as dht

sensor = dht.DHT22
pin = 4
humidity, temperature = dht.read_retry(sensor, pin)
print('Temp={0:0.1f} *C,  Hum={1:0.1f} %'.format(temperature, humidity))
sys.exit(0)