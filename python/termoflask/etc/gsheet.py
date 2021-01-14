#!/usr/bin/python3

##################################################################
# Script Name: gsheet.py
# Description: Clase para capturar datos de la web de la AEMET 
#               a partir del nº de estación
# Args: N/A
# Creation/Update: 20201217/20201217
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import gspread

class Gsheet:
    def __init__(self,archivo):
        self.online = True
        try:
            self.con = gspread.service_account()
            self.archivo = self.con.open(archivo)
        except:
            self.online = False
        
    # Leer una celda numérica y pasar el valor en float
    def leer_celda(self,hoja,celda):
        self.hoja = self.archivo.worksheet(hoja)
        return float(self.hoja.acell(celda).value.replace(",", "."))

    def escribir_celda(self,hoja,celda,valor):
        self.hoja = self.archivo.worksheet(hoja)
        self.hoja.update(celda, valor)

    # Leer una fila entera
    def leer_fila(self,hoja,fila):
        self.hoja = self.archivo.worksheet(hoja)
        return self.hoja.row_values(fila)

    # Escribir y ordenar una fila
    def escribir_fila(self,hoja,datos):
        self.hoja = self.archivo.worksheet(hoja)
        self.hoja.append_row(datos)
        self.hoja.sort((1, 'des'), (2, 'des'), range='A2:AA106000')

