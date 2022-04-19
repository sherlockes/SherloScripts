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
from pathlib import Path

class Configurator:
    def __init__(self, path, filename):
        self.path = path
        self.filename = filename
        self.check()

    def check(self):
        # Crea la ruta si no existe
        if not self.path.exists():
            os.makedirs(self.path)
        config_file = self.path / self.filename

        # Crea el archivo de configuración si no existe
        if not config_file.exists():
            idata = {}
            idata["directorios"] = {}
            with open(config_file, 'w') as file_writer:
                toml.dump(idata, file_writer)

        # Crea las carpetas del archivo de configuración si no existen
        if config_file.exists():
            data = self.read()
            if len(data['directorios'])>0:
                for carpeta in data['directorios'].values():
                    for x in ["in", "out"]:
                        ruta = Path(carpeta[x])
                        if not os.path.isdir(ruta):
                            os.mkdir(ruta)

    def read(self):
        config_file = self.path / self.filename
        return toml.load(config_file)

    def save(self, conf):
        config_file = self.path / self.filename
        with open(config_file, 'w') as file_writer:
            toml.dump(conf, file_writer)