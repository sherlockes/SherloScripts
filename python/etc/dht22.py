#!/usr/bin/python3

##################################################################
# Script Name: dht22.py
# Description: Clase para capturar temperatura y humedad de la
#              sonda conectada a la raspberry
# Args: Número del pin al que está conectada la sonda
# Creation/Update: 20201217/20201217
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import Adafruit_DHT as dht
import time
import logging

from etc.telegram import Telegram

class Dht22:
    def __init__(self,pin):
        self.pin = pin
        try:
            self.datos_dht = dht.read_retry(dht.DHT22,self.pin)
            
        except:
            self.online = False
            logging.warning("Ha fallado la sonda de temperatura¡¡¡¡")
            Telegram("Ha fallado la sonda de temperatura¡¡¡¡")

        while self.datos_dht[0] > 100:
            time.sleep(5)
            self.datos_dht = dht.read_retry(dht.DHT22,self.pin)
            
        self.hume = round(self.datos_dht[0],2)
        self.temp = round(self.datos_dht[1],2)