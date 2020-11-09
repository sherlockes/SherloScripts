#!/usr/bin/python3
########################################################################
# Script Name: telegram.py
# Description: librería para mandar mensajes de telegram mediante un bot
# Args: N/A
# Creation/Update: 20201109/20201109
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
#########################################################################
import requests
from pathlib import Path
import configparser
from urllib.request import urlopen
from xml.etree.ElementTree import parse

#####################################################################
############            Enviando por telegram            ############
#####################################################################

# Carga el archivo de configuración "config.ini" ubicado en el directorio de usuario
config_file=str(Path.home())+"/config.ini"
config = configparser.ConfigParser()
config.read(config_file)
bot_token = config['telegram']['token']
bot_chatID = config['telegram']['chat_id']

# Envia el mensaje de Telegram
def enviar(mensaje,token=bot_token,chatID=bot_chatID):
    send_text = 'https://api.telegram.org/bot' + token + '/sendMessage?chat_id=' + chatID + '&parse_mode=Markdown&text=' + mensaje
    requests.get(send_text)