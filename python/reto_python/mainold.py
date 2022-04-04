#!/usr/bin/env python3
# -*- coding: utf-8 -*-

##################################################################
# Script Name: reto_1.py
# Description: Primera parte del reto Python de atareao.es
# Args: N/A
# Creation/Update: 20220218/20220218
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
##################################################################

import mimetypes
import os
import toml
from pathlib import Path
from xdg import xdg_config_home

APP = "diogenes"
CONFIG = f"{APP}.conf"


def check_conf():
    config_dir = Path(xdg_config_home()) / APP
    if not config_dir.exists():
        os.makedirs(config_dir)
    config_file = config_dir / CONFIG
    if not config_file.exists():
        idata = {}
        idata["directorio"] = "/home/sherlockes/Descargas"
        with open(config_file, 'w') as file_writer:
            toml.dump(idata, file_writer)


def read_conf():
    config_dir = Path(xdg_config_home()) / APP
    config_file = config_dir / CONFIG
    idata = toml.load(config_file)
    return idata


def list_images(directory):
    if not directory.exists():
        os.makedirs(directory)
    for afile in directory.iterdir():
        if not afile.is_dir() and mimetypes.guess_type(afile)[0] == 'image/jpeg':
            print(afile.name)

def main():
    check_conf()
    data = read_conf()
    list_images(Path(data['directorio']))

if __name__ == '__main__':
    main()
