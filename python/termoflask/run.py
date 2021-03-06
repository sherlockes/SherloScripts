#!/usr/bin/python3

##################################################################
# Script Name: run.py
# Description: Web en Flask para manejo del termostato 
# Args: N/A
# Creation/Update: 20201204/20201230
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

from flask import Flask, render_template, request, redirect, url_for
from etc.plot import Plot
from datetime import datetime
import json
import os


app = Flask(__name__)
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0

@app.route("/", methods=["GET", "POST"])
def index():
    # Prepara la gráfica para mostrar
    Plot()
    # Carga el archivo "config.json" de configuración
    with open(os.environ['HOME']+'/config.json', 'r') as archivo_json:
        data = archivo_json.read()

    datos_json = json.loads(data)

    if request.method == 'POST':
        ahora = datetime.now()
        hora_manual = ahora.strftime('%Y/%m/%d %H:%M:%S')
        
        if datos_json["cons_manual"] != float(request.form['rangeInput']):
            datos_json["cons_manual"] = float(request.form['rangeInput'])
            datos_json["consigna"] = datos_json["cons_manual"]
            datos_json["hora_manual"] = hora_manual

        try:
            request.form['modo_fuera']
            datos_json["modo_fuera"] = True
        except:
            datos_json["modo_fuera"] = False

        # Graba los parámetros de configuración en el archivo "config.json"
        with open(os.environ['HOME']+'/config.json', "w") as archivo_json:
            json.dump(datos_json, archivo_json, indent = 4)
            
        return redirect(url_for('index'))

    return render_template("index.html", 
        consigna_manual=datos_json["cons_manual"],
        consigna=datos_json["consigna"],
        aemet_temp=datos_json["aemet_temp"],
        aemet_hora=datos_json["aemet_hora"],
        rele_total_on=datos_json["rele_total_on"],
        modo_fuera=datos_json["modo_fuera"],
        real_temp=datos_json["ultima_temp"]
    )
