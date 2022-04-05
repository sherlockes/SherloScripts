#!/usr/bin/env python3
# -*- coding: utf-8 -*-

##################################################################
# Script Name: configurator.py
# Description: Varias clases
# Args: N/A
# Creation/Update: 20220404/20220404
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
################################################################

import os
import mimetypes

mimetypes.init()


def list_images(directory):
    if not directory.exists():
        os.makedirs(directory)
    for afile in directory.iterdir():
        if not afile.is_dir() and mimetypes.guess_type(afile)[0] == 'image/jpeg':
            print(afile.name)