#!/usr/bin/env python3
##################################################################
# Script Name: scr_gpx_strava.py
# Description: Descarga actividades de Strava
# Args: N/A
# Creation/Update: 20231102/20231104
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
##################################################################
import requests
from flask import Flask, request
from dotenv import load_dotenv
from datetime import datetime
import webbrowser
import logging
from stravalib.client import Client
import os

usuario = os.getlogin()  # Obtener el nombre de usuario activo
ruta_strava = os.path.join("/home", usuario, "strava")

# Ruta para guardar los archivos
#ruta_strava = '/home/sherlockes/strava/'

# Configura el registro a un archivo
log_filename = ruta_strava + "flask_log.txt"
logging.basicConfig(filename=log_filename, level=logging.INFO)

# Carga las variables del archivo ".env" con el siguiente contenido
# CLIENT_ID=*******
# CLIENT_SECRET=*************************

# Especifica la ubicación del archivo .env
ruta_archivo_env = ruta_strava + '.env'
load_dotenv(ruta_archivo_env)

year = 2023  # Cambia este año al que desees obtener
start_date = datetime(year, 1, 1)
end_date = datetime.now()

# Variables para las llaves de Strava
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')

# Variable para almacenar el código de autorización
authorization_code = None

# iniciacion del cliente de Stravalib y servidor Flask
client = Client()
app = Flask(__name__)


# URL de autorización de Strava
strava_authorization_url = "https://www.strava.com/oauth/authorize?" + \
    "client_id=" + client_id + "&" + \
    "redirect_uri=http://localhost:5000/authorization&" + \
    "response_type=code&scope=read,activity:read_all"


# Realiza la solicitud a la URL de autorización de Strava
def initiate_authorization():
    print('Abriendo el navegador para autorizar la aplicación...')
    webbrowser.open(strava_authorization_url, new=2)
    print('Esperando autorización...')


# Configura tu cliente Stravalib para descargar las actividaes del último año
def info_gpx():
    print(f"Buscando actividades para descargar ...")

    for activity in client.get_activities(after=start_date, before=end_date):
        # print("{0.start_date} {0.id} {0.moving_time} {0.total_elevation_gain}".format(activity))
        # Reemplaza 'ID_DE_ACTIVIDAD' con la ID de la actividad a descargar
        activity_id = "{0.id}".format(activity)
        # Descarga el gpx a la carpeta Tracks si no existe ya
        if os.path.exists(os.path.join("tracks", activity_id+".gpx")):
            print(f"El archivo '{activity_id}.gpx' ya existe.")
        else:
            # Define la URL de la actividad GPX
            gpx_url = f'https://www.strava.com/activities/{activity_id}/export_gpx'
            # Configura las cabeceras de autenticación
            headers = {'Authorization': f'Bearer {access_token}'}
            # Realiza una solicitud GET para descargar el archivo GPX
            response = requests.get(gpx_url, headers=headers)
            if response.status_code == 200:
                with open(f'{ruta_strava}tracks/{activity_id}.gpx', 'wb') as gpx_file:
                    gpx_file.write(response.content)
                    print(f"Archivo GPX de la actividad {activity_id} descargado.")
            else:
                print(f"Error al descargar {activity_id}. Error: {response.status_code}")

# Configura tu cliente Stravalib para generar un xml con las actividaes del último año
def info_xml():
    print(f"Buscando actividades para indexar ...")
    # Obtener las actividades del último año
    activities = client.get_activities(after=start_date, before=end_date)

    # Generar el archivo XML
    xml_data = '<?xml version="1.0" encoding="UTF-8"?>\n<activities>\n'
    for activity in activities:
        xml_data += f'\t<activity>\n'
        xml_data += f'\t\t<date>{activity.start_date}</date>\n'
        xml_data += f'\t\t<distance>{activity.distance}</distance>\n'
        xml_data += f'\t\t<time>{activity.elapsed_time}</time>\n'
        xml_data += f'\t\t<id>{activity.id}</id>\n'
        xml_data += f'\t\t<elevation_gain>{activity.total_elevation_gain}</elevation_gain>\n'
        xml_data += f'\t</activity>\n'
        xml_data += '</activities>'

    # Escribir el XML en un archivo
    with open(ruta_strava + 'actividades.xml', 'w') as file:
        file.write(xml_data)

    print('Archivo XML generado exitosamente.')

# Ruta de redirección en el servidor Flask
@app.route('/authorization')
def get_authorization_code():
    global authorization_code
    authorization_code = request.args.get('code')
    # Imprime el código de autorización
    if authorization_code:
        print(f'Código de autorización: {authorization_code}')
        # Intercambia el código de autorización por un token de acceso
        global access_token
        access_token = client.exchange_code_for_token(
            client_id=client_id,
            client_secret=client_secret,
            code=authorization_code
        )
        info_xml()
        info_gpx()
    else:
        print("No se ha obtenido el código de autorización.")
    print("Pulsa Ctrl+C para terminar")
    return "Autorización exitosa. Puedes cerrar esta ventana."


# Programa principal
if __name__ == '__main__':
    # Llama a la función para iniciar la autorización
    initiate_authorization()

    # Inicia el servidor Flask en el puerto 5000
    app.run(port=5000)
