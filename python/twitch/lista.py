#!/usr/bin/env python3
# -*- coding: utf-8 -*-

##################################################################
# Script Name: lista.py
# Description: Clase de lista
# Args: N/A
# Creation/Update: 20220406/20220406
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
################################################################

import os
import subprocess
import json


class Lista:

    """ Lista los ultimos vídeos de un canal """

    def __init__(self, canal, ubicacion):
        self.canal = canal
        self.ruta_canal =  ubicacion + canal + '/'
        self.ruta_ultimos = ubicacion + canal + '/ultimos_id.txt'

        existe_canal = os.path.isdir(self.ruta_canal)

        # Crea la carpeta del canal si no existe
        if not existe_canal:
            print("Creando la carpeta del canal")
            os.mkdir(self.ruta_canal)

        # Info de los últimos vídeos
        output = subprocess.check_output("python3 twitch-dl.pyz videos " + self.canal + " -j", shell=True)
        self.videos_ultimos = json.loads(output.decode('utf-8'))

        # Info de los vídeos ya vistos
        self.leer_vistos()

        # Comparar últimos con ya vistos
        self.videos_no_vistos = []
        for i in self.videos_ultimos['videos']:
            visto = False
            for x in self.videos_vistos:
                if (x['id'] == i['id']):
                    visto = True
                    continue
            if not visto:
                self.videos_no_vistos.append(i)

    def leer_vistos(self):
        with open(self.ruta_ultimos, 'r') as filehandle:
            self.videos_vistos = json.load(filehandle)

    def grabar(self):
        with open(self.ruta_ultimos, 'w') as filehandle:
            json.dump(self.videos_ultimos['videos'], filehandle)

    def no_vistos(self):
        return(self.videos_no_vistos)