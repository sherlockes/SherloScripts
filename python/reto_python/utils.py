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

class list_images():
    def __init__(self, path):
        if not path.exists():
            os.makedirs(path)
        for afile in path.iterdir():
            if not afile.is_dir() and mimetypes.guess_type(afile)[0] == 'image/jpeg':
                print(afile.name)