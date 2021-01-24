#!/usr/bin/python3

##################################################################
# Script Name: dht22.py
# Description: Clase para capturar temperatura y humedad de la
#              sonda conectada a la raspberry
# Args: Número del pin al que está conectada la sonda
# Creation/Update: 20201217/20210124
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import Adafruit_DHT as dht
import time
import logging

from etc.telegram import Telegram

class Dht22:
    def __init__(self,pin,intentos):
        self.pin = pin

        hume_total = 0
        temp_total = 0

        for x in range(intentos):
            try:
                datos_dht = dht.read_retry(dht.DHT22,self.pin)
                
            except:
                self.online = False
                logging.warning("Ha fallado la sonda de temperatura¡¡¡¡")
                Telegram("Ha fallado la sonda de temperatura¡¡¡¡")

            while datos_dht[0] > 100:
                time.sleep(5)
                datos_dht = dht.read_retry(dht.DHT22,self.pin)

            hume_total += datos_dht[0]
            temp_total += datos_dht[1]

            time.sleep(3)

        self.hume = round(hume_total/intentos,2)
        self.temp = round(temp_total/intentos,2)
        
        logging.info(f"Dht22 - Tª interior de {self.temp}ºC y humedad del {self.hume}%")
