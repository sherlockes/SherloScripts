##################################################################
# Script Name: reto_1.py
# Description: Primera parte del reto Python de atareao.es
# Args: N/A
# Creation/Update: 20220218/20220218
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
##################################################################

import os
from gi.repository import GLib

downloads_dir = GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_DOWNLOAD)

files = os.listdir(downloads_dir)

print("Directorio:" + downloads_dir)

for f in files:
    if os.path.isfile(os.path.join(downloads_dir, f)):
        print(f)
