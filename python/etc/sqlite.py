#!/usr/bin/python3

########################################################################
# Script Name:  sqlite.py
# Description:  Clase para guardar los datos en una basede datos sqlite
# Args:
# Creation/Update: 202101312/20210112
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
########################################################################

import sqlite3
import os

from sqlite3 import Error
from datetime import datetime
import logging

class Sqlite:
    def __init__(self,path):
        try:
            self.con = sqlite3.connect(path)
        except Error:
            logging.warning("No se ha podido conectar a la base de datos")

        # Crear tablas si no existen
        cursorObj = self.con.cursor()
        cursorObj.execute("CREATE TABLE IF NOT EXISTS datos_temp(hora date PRIMARY KEY, exterior real, interior real, consigna real, rele)")
        cursorObj.execute("CREATE TABLE IF NOT EXISTS datos_dia(dia date PRIMARY KEY, media_ext real, media_int real, minutos)")

    def nuevo_dato(self,exterior,interior,consigna,rele):
        cursorObj = self.con.cursor()
        consulta = f"INSERT INTO datos_temp VALUES(datetime('now'), {exterior},{interior},{consigna},'{rele}')"
        cursorObj.execute(consulta)
        self.con.commit()

    def nueva_media(self,exterior,interior,minutos):
        cursorObj = self.con.cursor()
        consulta = f"INSERT INTO datos_dia VALUES(datetime('now'), {exterior},{interior},{minutos})"
        cursorObj.execute(consulta)
        self.con.commit()

    def media(self,columna):
        cursorObj = self.con.cursor()
        media=f"SELECT AVG({columna}) FROM datos_temp WHERE hora BETWEEN datetime('now', 'start of day') AND datetime('now', 'localtime')"
        cursorObj.execute(media)
        return round(cursorObj.fetchone()[0],1)