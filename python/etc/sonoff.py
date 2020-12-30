#!/usr/bin/python3

########################################################################
# Script Name:  sonoff.py
# Description:  Clase para controlar el relé Sonoff mini
# Args: 
# Creation/Update: 20201230/20201230
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
########################################################################

import requests
import os
import logging

from etc.telegram import Telegram

#####################################################
## Parámetros de configuración para el Sonoff Mini ##
#####################################################

sonoff_ip = "192.168.1.10"
url = 'http://' + sonoff_ip + ':8081/zeroconf/switch'
url_info = 'http://' + sonoff_ip + ':8081/zeroconf/info'
rele_info = {"deviceid": "1000a501ef", "data": {}}

rele_on = {"deviceid": "1000a501ef", "data": {"switch":"on"}}
rele_off = {"deviceid": "1000a501ef", "data": {"switch":"off"}}


class Sonoff:
    def __init__(self):
        # Comprobar si el relé está online y comprobar el estado
        response = os.system("ping " + sonoff_ip + " -c 1 > /dev/null 2>&1")
        if response == 0:
            mensaje = "Sonoff: Relé está conectado a red. "

            # Estado actual del rele
            consulta=requests.post(url_info, json = rele_info)
            rele_estado = consulta.json()["data"]["switch"]

            if consulta.json()["error"] == 0:
                mensaje += "Estado del relé - OK (" + rele_estado  + ")"
                self.estado = rele_estado
            else:
                Telegram("Algo falla en el relé de la calefacción")
                mensaje += "Estado del relé - KO"
        else:
            mensaje = "ATENCIÓN!!! El relé no está conectado a la red"
            Telegram("ATENCIÓN!!! El relé de la calefacción no está conectado a la red.")

        logging.info(mensaje)

    def encender(self):
        consulta = requests.post(url, json = rele_on )
        if consulta.json()["error"] == 0:
            self.estado = "on"
            print("Se ha encendido la calefacción")
        else:
            self.estado = "ERROR en relé"
            Telegram("No ha sido posible encender el rele de la calefacción")     

    def apagar(self):
        consulta = requests.post(url, json = rele_off)
        if consulta.json()["error"] == 0:
            self.estado = "off"
            print("Se ha apagado la calefacción")
        else:
            self.estado = "ERROR en relé"
            Telegram("No ha sido posible apagar el rele de la calefacción") 

    
        
        