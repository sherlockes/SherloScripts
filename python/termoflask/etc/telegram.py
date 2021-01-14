#!/usr/bin/python3
########################################################################
# Script Name: telegram.py
# Description: Clase para mandar mensajes de telegram mediante un bot
# Args: N/A
# Creation/Update: 20201218/20201218
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
#########################################################################
import requests
from pathlib import Path
import configparser
from urllib.request import urlopen
from xml.etree.ElementTree import parse

class Telegram:
    def __init__(self, mensaje):
        # Carga el archivo de configuración "config.ini" ubicado en el directorio de usuario
        config_file=str(Path.home())+"/config.ini"
        config = configparser.ConfigParser()
        config.read(config_file)
        bot_token = config['telegram']['token']
        bot_chatID = config['telegram']['chat_id']

        send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&parse_mode=Markdown&text=' + mensaje
        requests.get(send_text)
        