#!/usr/bin/env python3
# -*- coding: utf-8 -*-

##################################################################
# Script Name: configurator.py
# Description: Clase de configuración
# Args: N/A
# Creation/Update: 20220404/20220404
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
################################################################

import os
import toml

class Configurator():
    def __init__(self, path, config):
        if not path.exists():
            os.makedirs(path)
        
        self.config_file = path / config
        
        if not self.config_file.exists():
            idata = {}
            idata["directorio"] = "/home/sherlockes/Descargas"
            with open(self.config_file, 'w') as file_writer:
                toml.dump(idata, file_writer)

    def read(self):
        idata = toml.load(self.config_file)
        return idata