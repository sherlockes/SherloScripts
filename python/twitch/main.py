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
import sys
import subprocess
from lista import Lista
from pathlib import Path
from xdg import xdg_config_home
from configurator import Configurator

CANAL = 'jordillatzer'



def main(app, config):

    path = Path(xdg_config_home()) / app
    configurator = Configurator(path, config)

    sys.exit("Hasta aquí")
  

    # Comprueba nuevos vídeos en el canal
    lista = Lista(CANAL,UBICACION)

    # Comprueba que hay para descargar
    if not lista.no_vistos():
        print ("No hay nada para descargar")
    else:
        for i in lista.no_vistos():
            print(i['id'])
            subprocess.run("python3 twitch-dl.pyz download -q audio_only " + str(i['id']), shell=True)

if __name__ == '__main__':
    APP = "twitch2podcast"
    config = f"{APP}.conf"
    main(APP, config)






