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

        # Caldular datos anteriores
        self.anterior_dato()

    def nuevo_dato(self,exterior,interior,consigna,rele):
        cursorObj = self.con.cursor()
        consulta = f"INSERT INTO datos_temp VALUES(datetime('now','localtime'), {exterior},{interior},{consigna},'{rele}')"
        cursorObj.execute(consulta)
        self.con.commit()

    def nueva_media(self,exterior,interior,minutos):
        cursorObj = self.con.cursor()
        consulta = f"INSERT INTO datos_dia VALUES(date('now'), {exterior},{interior},{minutos}) ON CONFLICT(dia) DO UPDATE SET media_ext=excluded.media_ext, media_int=excluded.media_int, minutos=excluded.minutos"
        cursorObj.execute(consulta)
        self.con.commit()

    def media(self,columna):
        cursorObj = self.con.cursor()
        consulta=f"SELECT AVG({columna}) FROM datos_temp WHERE hora BETWEEN datetime('now', 'start of day') AND datetime('now', 'localtime')"
        cursorObj.execute(consulta)
        return round(cursorObj.fetchone()[0],1)

    def anterior_dato(self):
        cursorObj = self.con.cursor()
        consulta = f"SELECT * FROM datos_temp ORDER BY hora DESC LIMIT 1"
        cursorObj.execute(consulta)
        dato = cursorObj.fetchone()
        self.hora_ant = datetime.strptime(dato[0], '%Y-%m-%d %H:%M:%S')
        self.text_ant = round(float(dato[1]),1)
        self.tint_ant = round(float(dato[2]),1)
        self.tcon_ant = round(float(dato[3]),1)
        self.rele_ant = dato[4]

    def prueba(self):
        cursorObj = self.con.cursor()
        cursorObj.execute("SELECT hora, interior, consigna from datos_temp order by hora desc limit 300")
        return cursorObj.fetchall()