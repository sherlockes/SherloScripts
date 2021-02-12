#!/usr/bin/python3

########################################################################
# Script Name:  sqlite.py
# Description:  Clase para guardar los datos en una basede datos sqlite
# Args:
# Creation/Update: 202101312/20210206
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
########################################################################

## Métodos
# nuevo_dato(t_ext,t_int,consigna,rele) - Inserta nuevo dato en la tabla "datos_temp"
# nueva media(meida_ext, media_int, minutos) Interta nuevo dato en la tabla "datos_dia" para el día actual
# media(campo) - Calcula la media del día actual para la columna deseada en la tabla "datos_temp"
# anterior_dato - Devuelve el último datos guardado en la tabla "datos_temp"
# calculo_minutos - 


import sqlite3
import os

from sqlite3 import Error
from datetime import datetime
import logging

class Sqlite:
    def __init__(self,path):
        try:
            self.con = sqlite3.connect(path,detect_types=sqlite3.PARSE_DECLTYPES | sqlite3.PARSE_COLNAMES)
        except Error:
            logging.warning("No se ha podido conectar a la base de datos")

        # Crear tablas si no existen
        self.cursor = self.con.cursor()
        self.cursor.execute("CREATE TABLE IF NOT EXISTS datos_temp(hora date PRIMARY KEY, exterior real, interior real, consigna real, rele)")
        self.cursor.execute("CREATE TABLE IF NOT EXISTS datos_dia(dia date PRIMARY KEY, media_ext real, media_int real, minutos)")
        self.cursor.execute("CREATE TABLE IF NOT EXISTS datos_set(t_ext real PRIMARY KEY, inercia_on real, rampa_on real, inercia_off real, rampa_off real)")
        self.cursor.execute("CREATE TABLE IF NOT EXISTS datos_salon(hora timestamp PRIMARY KEY, temp, hume)")

    def salon_nuevo(self,temp,hume):
        # Limita la tabla a 500 registros (~ 4 horas)
        consulta = f"DELETE FROM datos_salon WHERE ROWID IN (SELECT ROWID FROM datos_salon ORDER BY ROWID DESC LIMIT -1 OFFSET 1000)"
        self.cursor.execute(consulta)

        # Graba el nuevo registro
        consulta = f"INSERT INTO datos_salon VALUES(datetime('now','localtime'), {temp},{hume})"
        self.cursor.execute(consulta)
        
        self.con.commit()

    def salon_datos(self,datos):
        consulta = f"select hora, temp from datos_salon order by hora desc limit {datos}"
        self.cursor.execute(consulta)
        datos = self.cursor.fetchall()
        return datos

    def salon_temp(self,datos):
        consulta = f"select hora, temp from datos_salon order by hora desc limit {datos}"
        self.cursor.execute(consulta)
        datos = self.cursor.fetchall()
        temps =[]
        for i in datos:
            temps.append(i[1])
        return temps
    
    def salon_media(self,valores):
        consulta = f"select avg(temp) from datos_salon where ROWID in (SELECT rowid from datos_salon order by hora desc limit {valores})"
        self.cursor.execute(consulta)
        datos = self.cursor.fetchone()
        return datos[0]







