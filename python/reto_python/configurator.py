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

class Configurator:
    def __init__(self, path, filename):
        self.path = path
        self.filename = filename
        self.check()

    def check(self):
        if not self.path.exists():
            os.makedirs(self.path)
        config_file = self.path / self.filename
        if not config_file.exists():
            idata = {}
            idata["directorio"] = "/home/lorenzo/Descargas"
            with open(config_file, 'w') as file_writer:
                toml.dump(idata, file_writer)

    def read(self):
        config_file = self.path / self.filename
        return toml.load(config_file)

    def save(self, conf):
        config_file = self.path / self.filename
        with open(config_file, 'w') as file_writer:
            toml.dump(conf, file_writer)