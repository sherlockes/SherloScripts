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

    def obtener(self,tabla,campo,coincidencia,valor):
        cursorObj = self.con.cursor()
        cursorObj.execute(f"SELECT {campo} from {tabla} where {coincidencia} = {valor}")
        datos = cursorObj.fetchone()
        if datos == None:
            return None
        else:
            return datos[0]

    def nuevo_dato(self,exterior,interior,consigna,rele):
        cursorObj = self.con.cursor()
        consulta = f"INSERT INTO datos_temp VALUES(datetime('now','localtime'), {exterior},{interior},{consigna},'{rele}')"
        cursorObj.execute(consulta)
        self.con.commit()
    
    def nuevo_ajuste(self,t_ext,campo,valor):
        valor_ext = self.obtener("datos_set",campo,"t_ext",t_ext)

        if valor_ext != None:
            valor_med = (valor + valor_ext)/2
            logging.info(f"Ya existe el valor de ajuste de {campo} para {t_ext}ºC, se hace la media con {valor_ext} resultando {valor_med}")
        else:
            valor_med = valor
            logging.info(f"Queda guardado el valor de ajuste de {campo} para {t_ext}ºC a {valor_med}")

        valor_med = round(valor_med,2)

        cursorObj = self.con.cursor()
        cursorObj.executescript(f"""
                INSERT OR IGNORE INTO datos_set(t_ext) VALUES({t_ext});
                UPDATE datos_set SET {campo}={valor_med} WHERE t_ext={t_ext};   
            """)
        

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

    def ultimo_cambio(self):
        cursorObj = self.con.cursor()
        consulta = "select hora, rele from datos_temp order by hora DESC limit 300"
        cursorObj.execute(consulta)
        datos = cursorObj.fetchall()
        estado_actual = datos[0][1]
        i=0
        for dato in datos:
            if dato[1] != estado_actual:
                tiempo = datetime.now() - datetime.strptime(datos[i-1][0], '%Y-%m-%d %H:%M:%S')
                tiempo = round(tiempo.seconds/60)
                return(tiempo)
            i += 1
    
    def calculo_minutos(self):
        # Calcular los días guardados en la base de datos, aprox últimos diez días
        cursorObj = self.con.cursor()
        cursorObj.execute("select hora from datos_temp order by hora desc LIMIT 2500")
        registros = cursorObj.fetchall()
        dias = []
        for fecha in registros:
            dia = datetime.strptime(fecha[0], '%Y-%m-%d %H:%M:%S')
            dia = dia.strftime('%Y-%m-%d')
            dia = str(dia)

            if dia not in dias: dias.append(dia)
        
        for x in dias: self.minutos_dia(x)

    def minutos_dia(self,dia ="now"):
        # Cálculo de los minutos encendida
        cursorObj = self.con.cursor()
        consulta = f"select hora, rele from datos_temp where hora BETWEEN datetime('{dia}', 'start of day') AND datetime('{dia}', '+1 day')"
        cursorObj.execute(consulta)
        registros = cursorObj.fetchall()
        total_min = 0
        i = 0
        
        for registro in registros:

            if i > 0 and registros[i-1][1] == "on":
                hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                hora_ant = datetime.strptime(registros[i-1][0], '%Y-%m-%d %H:%M:%S')
                total_min += (hora - hora_ant).seconds/60            

            i+=1
        
        total_min = round(total_min)

        if dia == "now":
            return(total_min)
        else:
            # Obtención de las medias interior y exterior
            consulta = f"select hora, avg(interior), avg(exterior) from datos_temp where hora BETWEEN datetime('{dia}', 'start of day') AND datetime('{dia}', '+1 day')"
            cursorObj.execute(consulta)
            registros = cursorObj.fetchone()
            media_int = round(registros[1],1)
            media_ext = round(registros[2])

            # Convertir formato de la fecha
            
            fecha = datetime.strptime(dia, '%Y-%m-%d')
            fecha = fecha.strftime('%Y-%m-%d')
            fecha = str(fecha)

            # Grabar los resultados
            cursorObj = self.con.cursor()
            consulta = f"INSERT INTO datos_dia VALUES('{fecha}',{media_ext},{media_int},{total_min}) ON CONFLICT(dia) DO UPDATE SET media_ext=excluded.media_ext, media_int=excluded.media_int, minutos=excluded.minutos"
            cursorObj.execute(consulta)
            self.con.commit()

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
        logging.info("Calculando rampas e inercias...")
        cursorObj = self.con.cursor()
        cursorObj.execute("SELECT * from datos_temp order by hora asc limit 500")
        registros = cursorObj.fetchall()

        logging.info("Calculando los ciclos de encendido y apagado...")
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
        logging.info("Cálculo de la rampa de enfriamiento para enfriamientos prolongados")
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
                if pendiente > 0.1 and (tiempo.seconds)/60 > 30:
                    self.nuevo_ajuste(temp_ext,"rampa_off",pendiente)
        
        # Cálculo de la pendiente de calentamiento a partir de los ciclos de encendido     
        for ciclo in ciclo_on:
            i = 0
            buscando_max = False
            buscando_min = False
            buscando_off = False

            for registro in registros:
                hora = datetime.strptime(registro[0], '%Y-%m-%d %H:%M:%S')
                temp_ext = round(registro[1])
                if hora == ciclo:
                    temp = registro[2]
                    buscando_min = True
                
                if buscando_min and registro[2] > temp:
                    inercia = hora - ciclo
                    inercia = round(inercia.seconds/60)
                    self.nuevo_ajuste(temp_ext,"inercia_on",inercia)
                    temp = registro[2]
                    buscando_min = False
                    buscando_off = True

                if buscando_off and registro[4] == "off":
                    var_temp = round((registro[2] - temp),2)
                    var_tiempo = hora - ciclo
                    var_tiempo = round(var_tiempo.seconds/3600,2)
                    
                    if var_tiempo > 0:
                        rampa_on = round((var_temp/var_tiempo),2)
                        self.nuevo_ajuste(temp_ext,"rampa_on",rampa_on)
                    buscando_off = False
                    buscando_max = True

                if buscando_max and registro[2] > registros[i+1][2]:
                    inercia = hora - ciclo
                    inercia = round(inercia.seconds/60)
                    self.nuevo_ajuste(temp_ext,"inercia_off",inercia)
                    buscando_max = False

                i += 1
                    

    def prueba(self):
        cursorObj = self.con.cursor()
        cursorObj.execute("SELECT hora, interior, consigna, exterior from datos_temp order by hora desc limit 300")
        return cursorObj.fetchall()





