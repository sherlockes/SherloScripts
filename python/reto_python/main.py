#!/usr/bin/env python3
# -*- coding: utf-8 -*-

##################################################################
# Script Name: main.py
# Description: Reto Python de atareao.es
# Args: N/A
# Creation/Update: 20220218/20220404
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
##################################################################

import os
from pathlib import Path
from xdg import xdg_config_home
from configurator import Configurator
from utils import list_images

# https://github.com/atareao/reto-python

def main(app, config):
    path = Path(xdg_config_home()) / app
    configurator = Configurator(path, config)
    data = configurator.read()

    
    if len(data['directorios'])>0:
        for carpeta in data['directorios'].values():
            print('===', carpeta['in'], '===')
            list_images(Path(carpeta["in"]))

if __name__ == '__main__':
    APP = "diogenes"
    config = f"{APP}.conf"
    main(APP, config)