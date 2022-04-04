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

from pathlib import Path
from xdg import xdg_config_home
from configurator import Configurator
from utils import list_images


def main(app, config):
    path = Path(xdg_config_home()) / app
    configurator = Configurator(path, config)
    data = configurator.read()
    print(data['directorio'])
    list_images(Path(data['directorio']))

if __name__ == '__main__':
    APP = "diogenes"
    config = f"{APP}.conf"
    main(APP, config)