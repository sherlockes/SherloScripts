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
        cursorObj.execute("CREATE TABLE IF NOT EXISTS datos_set(t_ext real PRIMARY KEY, inercia_on real, rampa_on real, inercia_off real, rampa_off real)")

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
        cursorObj.execute("SELECT hora, interior, consigna, exterior from datos_temp order by hora desc limit 300")
        return cursorObj.fetchall()

    def minutos_dia(self,dia):
        cursorObj = self.con.cursor()
        #consulta = f"select hora, rele from datos_temp where hora BETWEEN datetime('{dia}', 'start of day') AND datetime('{dia}', '+1 day')"
        consulta = "SELECT hora, rele FROM  datos_temp WHERE hora BETWEEN JulianDay('now') AND JulianDay('now','+1 day','-0.001 second')"
        cursorObj.execute(consulta)
        registros = cursorObj.fetchall()
        total_min = 0
        i = 0
        
        for registro in registros:

            if i > 0 and registro[1] == "on":
                hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                hora_ant = datetime.strptime(registros[i-1][0], '%Y-%m-%d %H:%M:%S')
                total_min += (hora - hora_ant).seconds/60

            i+=1

        print(round(total_min))

    def inercia(self):
        cursorObj = self.con.cursor()
        cursorObj.execute("SELECT hora, interior, rele, consigna from datos_temp order by hora desc limit 300")
        datos = cursorObj.fetchall()

        estado_inicio = datos[0][2]
        estado =  estado_inicio
        i = 0

        for registros in datos:
            if registros[2] != estado:
                estado = registros[2]
                if registros[2] != estado_inicio:
                    fin_ultimo_estado_completo = datos[i-1][0]
                    print(f"Hora de finalización: {fin_ultimo_estado_completo}")
                else:
                    inicio_ultimo_estado_completo = datos[i-1][0]
                    print(f"Hora de inicio: {inicio_ultimo_estado_completo}")
                    break

            i += 1

        # Calcular media exterior
        cursorObj.execute(f"select avg(exterior) from datos_temp where hora BETWEEN '{inicio_ultimo_estado_completo}' and '{fin_ultimo_estado_completo}' order by hora")
        datos = cursorObj.fetchall()
        media_exterior = round(datos[0][0])

        # Calcular inercias
        cursorObj.execute(f"select * from datos_temp where hora BETWEEN '{inicio_ultimo_estado_completo}' and '{fin_ultimo_estado_completo}' order by hora")
        datos = cursorObj.fetchall()

        if datos[0][4] == "on":
            print("calculando la inercia de encendido")
            i = 0
            for registro in datos:
                if registro[2] > datos[0][2]:
                    hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                    hora_ant = datetime.strptime(datos[i-1][0], '%Y-%m-%d %H:%M:%S')
                    hora_inercia = hora - hora_ant
                    hora_inercia = hora_ant + hora_inercia/2
                    print(hora_inercia)
                i += 1
            
            hora_on = datetime.strptime(datos[0][0], '%Y-%m-%d %H:%M:%S')
            inercia = hora_inercia - hora_on
            inercia = round(inercia.seconds/60)
            

            # Guardar el dato
            print(f"La inercia de encendido es de {inercia} minutos con una temperatura exterior de {media_exterior}ºC.")
            
            cursorObj.executescript(f"""
                INSERT OR IGNORE INTO datos_set(t_ext) VALUES({media_exterior});
                UPDATE datos_set SET inercia_on={inercia} WHERE t_ext={media_exterior};   
            """)

    def parametros(self):
        cursorObj = self.con.cursor()
        cursorObj.execute("SELECT * from datos_temp order by hora asc limit 2000")
        registros = cursorObj.fetchall()


        # Cálculo de lcos ciclos de enciendido y apagado
        i = 0
        ciclo_on=[]
        ciclo_off=[]

        hora_on = datetime.strptime(registros[0][0], '%Y-%m-%d %H:%M:%S')
        hora_off = datetime.strptime(registros[0][0], '%Y-%m-%d %H:%M:%S')
            
        for registro in registros:
            
            if i > 0 and registros[i-1][4] == "off" and registro[4] == "on":
                hora_on = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                tiempo_off = hora_on - hora_off

                if tiempo_off.seconds/60 > 45:
                    ciclo_off.append(hora_off)
            
            if i > 0 and registros[i-1][4] == "on" and registro[4] == "off":
                hora_off = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                tiempo_on = hora_off - hora_on
                
                if tiempo_on.seconds/60 > 21:
                    ciclo_on.append(hora_on)
            i += 1

        # Cálculo de la pendiente de enfriamiento a partir de los ciclos de apagado     
        for ciclo in ciclo_off:
            i = 0
            buscando_max = False
            buscando_min = False
            for registro in registros:
                hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                if hora == ciclo:
                    temp = registro[2]
                    buscando_max = True
                if buscando_max and registro[2] < temp:
                    hora_ini = hora
                    temp_max = registro[2]
                    buscando_max = False
                    buscando_min = True
                if buscando_min and registro[4] == "on":
                    hora_fin = hora
                    temp_min = registro[2]
                    temp_ext = round(registro[1])
                    buscando_min = False

            if hora_fin > hora_ini:
                tiempo = hora_fin - hora_ini
                pendiente = round((temp_max - temp_min) / (tiempo.seconds/3600),2)
                pendiente_ant = self.obtener("datos_set","rampa_off","t_ext",temp_ext)
                if pendiente_ant != None:
                    pendiente = (pendiente_ant + pendiente_ant)/2
                if pendiente > 0.1 and (tiempo.seconds)/60 > 30:
                    print(f"Un ciclo empieza a las {hora_ini} con {temp_max}ºC y baja hasta las {hora_fin} con {temp_min}ºC ({pendiente}ºC/h")
                    cursorObj.executescript(f"""
                        INSERT OR IGNORE INTO datos_set(t_ext) VALUES({temp_ext});
                        UPDATE datos_set SET rampa_off={pendiente} WHERE t_ext={temp_ext};   
                    """)
        
        # Cálculo de la pendiente de calentamiento a partir de los ciclos de encendido     
        for ciclo in ciclo_on:
            i = 0
            buscando_max = False
            buscando_min = False

            for registro in registros:
                hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                if hora == ciclo:
                    temp = registro[2]
                    buscando_min = True
                
                if buscando_min and registro[2] > temp:
                    inercia = hora - ciclo
                    print(inercia)
                    buscando_min = False


    
    def obtener(self,tabla,campo,coincidencia,valor):
        cursorObj = self.con.cursor()
        cursorObj.execute(f"SELECT {campo} from {tabla} where {coincidencia} = {valor}")
        datos = cursorObj.fetchone()
        if datos == None:
            return None
        else:
            return datos[0]





