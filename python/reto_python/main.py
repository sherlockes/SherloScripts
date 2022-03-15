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

import os
import re
from pathlib import Path
from gi.repository import GLib

def main():
    try:
        downloads_dir = GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_DOWNLOAD)
        files = os.listdir(downloads_dir)
        print("Directorio:" + downloads_dir)
        print("-----------------------------------------------")
        for f in files:
            if os.path.isfile(os.path.join(downloads_dir, f)):
                x=re.compile(r'.+\.jpe*g$', re.IGNORECASE)
                y=re.compile(r'[^0-9]+\.jpe*g$', re.IGNORECASE)
                if y.match(f):
                    print (f.upper())
                elif x.match(f):
                    print (f.lower())
    except Exception as exception:
        print(exception)


def main2():
    try:
        downloads_dir = Path(GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_DOWNLOAD))
        print(f"\nDirectorio: {downloads_dir}")
        print("-----------------------------------------------")
        if downloads_dir.is_dir():
            for afile in [x for x in downloads_dir.iterdir() if not x.is_dir()]:
                x=re.compile(r'.+\.jpe*g$', re.IGNORECASE)
                y=re.compile(r'[^0-9]+\.jpe*g$', re.IGNORECASE)
                if y.match(afile.name):
                    print (afile.name.upper())
                elif x.match(afile.name):
                    print (afile.name.lower())
                        


    except Exception as exception:
        print(exception)


if __name__ == "__main__":
    main()
