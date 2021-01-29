#!/usr/bin/python3

##################################################################
# Script Name: sherlo_aemet.py
# Description: Clase para capturar datos de la web de la AEMET 
#               a partir del nº de estación
# Args: N/A
# Creation/Update: 20201214/20201214
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import requests
import json
from datetime import datetime
import logging
import pandas as pd




class Aemet:

    def __init__(self,estacion,intervalo = 1):
        self.intervalo = intervalo
        self.estacion = estacion
        self.url = "http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_" + str(self.estacion) + "_datos-horarios.csv?k=arn&l=" + str(self.estacion) + "&datos=det&w=0&f=temperatura&x=h24"

        ##########################################################
        ##  Carga el archivo "cfg_aemet.json" de configuración  ##
        ##########################################################
        try:
            with open('cfg_aemet.json', 'r') as archivo_json:
                data = archivo_json.read()
        except:
            data = {"aemet_hora": "2020/12/12 12:25:02"}
            with open('cfg_aemet.json', 'w') as f:
                json.dump(data, f, indent=2)
            
            logging.info(f"Se ha creado un nuevo archivo de configuración para Aemet")

            with open('cfg_aemet.json', 'r') as archivo_json:
                data = archivo_json.read()

        self.datos_json = json.loads(data)


        # aemet_hora (Ultima toma de Tª de la AEMET)
        if "aemet_hora" in self.datos_json:
            aemet_hora = datetime.strptime(self.datos_json["aemet_hora"], '%Y/%m/%d %H:%M:%S')
            logging.info(f"Aemet - Ultima toma a las {aemet_hora.hour}:{aemet_hora.minute}")
        else:
            aemet_hora = datetime.now()
            self.datos_json["aemet_hora"] = aemet_hora.strftime('%Y/%m/%d %H:%M:%S')
            logging.info(f"Aemet - Sin toma - {aemet_hora.strftime('%Y/%m/%d %H:%M:%S')}")

        # Si han pasado los minutos del intervalo desde la ultima medida o no existe vuelve a coger la temperatura exterior

        if round((datetime.now() - aemet_hora).seconds/60) > intervalo or not "aemet_temp" in self.datos_json:
            # Intento de acceder a la web de la AEMET
            try:
                self.online = True
                self.datos = requests.get(self.url, allow_redirects=True).text.replace('"', "").splitlines()
            except:
                self.online = False
                logging.warning("Aemet - No hay conexión con la web de la AEMET.")

  
            aemet_hora = datetime.now()
            self.hora = aemet_hora.strftime('%Y/%m/%d %H:%M:%S')
            self.datos_json["aemet_hora"] = self.hora
            self.temp_actual = self.t_actual()
            self.datos_json["aemet_temp"] = self.temp_actual
            self.temp_media = self.t_media()
            self.datos_json["aemet_media"] = self.temp_media

            logging.info(f"Aemet - Se guarda {self.temp_actual}ºC a las {aemet_hora.hour}:{aemet_hora.minute}")

            with open('cfg_aemet.json', 'w') as archivo_json:
                json.dump(self.datos_json, archivo_json, indent = 2)
        else:
            logging.info(f"Aemet - No han pasado todavía {self.intervalo} minutos desde la última toma.")
            self.temp_actual = self.datos_json["aemet_temp"]
            self.temp_media = self.datos_json["aemet_media"]
            self.hora = self.datos_json["aemet_hora"]


    def t_actual(self):
        # Extrae la última temperatura de la estación
        if self.online:
            try:
                return float(self.datos[4].split(",")[1])
            except:
                self.online = False
                return "error"
        else:
            return "error"

    def t_media(self):
        if self.online:
            temp = 0.0
            num = 0
            for i in range(4,len(self.datos)):
                try:
                   temp += float(self.datos[i].split(",")[1])
                except:
                    break
                num += 1
            return round(temp / (num-4),1)
        else:
            return "error"


class Json:
    def __init__(self,archivo):
        self.archivo = archivo

        try:
            with open(archivo, 'r') as archivo_json:
                data = archivo_json.read()
        except:
            data = {"aemet_hora": "2020/12/12 12:25:02","aemet_temp":15,"aemet_media":15}
            with open(archivo, 'w') as f:
                json.dump(data, f, indent=2)
            
            logging.info(f"Se ha creado un nuevo archivo de configuración para Aemet")

            with open(archivo, 'r') as archivo_json:
                data = archivo_json.read()

        self.datos_json = json.loads(data)

    def guardar(self):
        with open(self.archivo, 'w') as archivo_json:
                json.dump(self.datos_json, archivo_json, indent = 2)


class Aemet2:
    def __init__(self,estacion):

        archivo = Json('cfg_aemet.json')

        url = "http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_" + str(estacion) + "_datos-horarios.csv?k=arn&l=" + str(estacion) + "&datos=det&w=0&f=temperatura&x=h24"

        try:
            self.online = True
            df = pd.read_csv(url,encoding = "ISO-8859-1",skiprows=3)
        except:
            self.online = False
            logging.warning("Aemet - No hay conexión con la web de la AEMET.")

        campos = df.columns.values
        hora = campos[0]
        temp = campos[1]
        
        self.hora = datetime.strptime(df.iloc[0][hora], '%d/%m/%Y %H:%M')
        self.temp_media = round(df[temp].mean(),1)
        self.temp = df.iloc[0][campos[1]]

        archivo.datos_json["aemet_hora"] = self.hora.strftime('%Y/%m/%d %H:%M:%S')
        archivo.datos_json["aemet_temp"] = self.temp
        archivo.datos_json["aemet_media"] = self.temp_media
        
        archivo.guardar()