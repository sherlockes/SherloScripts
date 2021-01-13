#!/usr/bin/python3

########################################################################
# Script Name:  consigna.py
# Description:  Clase para calcular la consigna de Tª actual, posterior
#               y el tiempo que falta para cambiarla.
# Args: - Modo fuera
#       - Consigna fuera
#       - Modo manual
#       - Consigna manual
#       - Lista de horas
#       - Lista de temperaturas
#       - Lista de personas
#       - Decremento de Tª con casa vacía
# Creation/Update: 20201230/20201230
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
########################################################################


from datetime import datetime
from datetime import timedelta

import logging
import os


class Consigna:
    def __init__(self,modo_fuera,consigna_fuera,hora_manual,consigna_manual,min_manual,lista_horas,lista_temp,personas,dec_casa_vacia):

        ahora = datetime.now()
        self.min_restan = 0
    

        def modo_manual():
            minutos_manual = round((ahora - hora_manual).seconds/60)
            return True if minutos_manual < min_manual else False
        
        def casa_vacia():
            for usuario in personas:
                response = os.system("ping " + usuario + " -c 1 > /dev/null 2>&1")
                if response == 0:
                    salida = False
                    logging.info("Control de ausencias: La casa no está vacía.")
                    break
                else:
                    salida = True
                    logging.info(f"Control de ausencias: No hay nadie, se baja {dec_casa_vacia}ºC.")
            return salida

        def consigna_programa(momento):
            salida = float(lista_temp[len(lista_horas)-1])
            for i in lista_horas:
                hora = datetime.strptime(i, '%H:%M')
                hora = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
                if hora > momento: break
                salida = float(lista_temp[lista_horas.index(i)])
            return salida
        
        def consigna_programa_siguiente(momento):
            # Busca la siguiente consigna en la matriz horas
            for i in lista_horas:
                siguiente = float(lista_temp[lista_horas.index(i)])
                hora = datetime.strptime(i, '%H:%M')
                hora = ahora.replace( hour=hora.hour, minute=hora.minute, second=0 )
                if hora > momento: break
                siguiente = float(lista_temp[0])
                hora = datetime.strptime(lista_horas[0], '%H:%M')
                manana = ahora + timedelta(days=1)
                hora = manana.replace( hour=hora.hour, minute=hora.minute, second=0)

            # Cambio de consigna de Tª
            minutos_cambio = round(((hora - ahora).seconds)/60)

            salida = [siguiente, minutos_cambio]
            return salida

        if modo_fuera:
            # Modo "fuera de casa" activado
            self.min_restan = 600
            self.actual = consigna_fuera
            fin_fuera = ahora + timedelta(minutes=self.min_restan)
            self.siguiente = consigna_programa(fin_fuera)
            logging.info(f"Consigna - Modo fuera de casa ({consigna_fuera}ºC)")
        elif modo_manual():
            # Modo "manual" activado
            self.min_restan = min_manual - round((ahora - hora_manual).seconds/60)
            self.actual = consigna_manual
            fin_manual = hora_manual + timedelta(hours=1)
            self.siguiente = consigna_programa(fin_manual)
            logging.info(f"Consigna - Manual a {consigna_manual}ºC faltan {self.min_restan} min para poner {self.siguiente}ºC")
        else:
            # Modo "programa"
            consigna_programa = consigna_programa(ahora)
            consigna_siguiente = consigna_programa_siguiente(ahora)
            logging.info(f"Consigna - Programada de {consigna_programa}ºC")
            logging.info(f"Consigna - Siguiente programa de {consigna_siguiente[0]}ºC dentro de {consigna_siguiente[1]} minutos.")
            self.actual = consigna_programa if not casa_vacia() else consigna_programa - dec_casa_vacia
            self.min_restan = consigna_siguiente[1]
            self.siguiente = consigna_siguiente[0]

    
        
        