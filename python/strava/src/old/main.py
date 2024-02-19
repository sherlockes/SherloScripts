from stravalib import Client
import webbrowser
import re
import time
import requests


# Reemplaza estos valores con tus propias credenciales de aplicación de Strava
client_id = '114649'
client_secret = 'd4cd648ec65ca55d5ee5ef435b7768286f01457f'

# Crea una instancia de Client
client = Client()

# Obtén la URL de autorización
url = client.authorization_url(client_id=client_id, redirect_uri='http://localhost:8080/authorization')

# Imprime la URL y visita en tu navegador para autorizar la aplicación
#print(f'Ve a esta URL y autoriza la aplicación: {url}')

# Abre el navegador web predeterminado con la URL especificada
webbrowser.open(url)

# Pausa el script durante 5 segundos
time.sleep(5)

print('Se ha abierto el navegador, copia todo el contenido de la barra de direcciones')

# Después de autorizar la aplicación, obtén el código de autorización de la URL de redirección
# Deberías tener un servidor que escuche en la URL de redirección y capture el código de autorización

# Introduce el código de autorización
authorization_url = input(f"Pega la url aquí: ")

# Define la URL que contiene el código de autorización y el alcance
url = 'http://localhost:8080/authorization?state=&code=249c1f2540ce5cfafa96bb6e334f4d2c7717c1ac&scope=read,activity:read'

# Utiliza una expresión regular para buscar el código de autorización y el alcance
match = re.search(r'code=([^&]+)&scope=([^&]+)', authorization_url)

if match:
    authorization_code = match.group(1)  # Extrae el código de autorización
    scope = match.group(2)  # Extrae el alcance (scope)
    print(f'Código de autorización: {authorization_code}')
    print(f'Alcance (Scope): {scope}')
else:
    print('No se encontraron el código de autorización y el alcance en la URL.')


# Intercambia el código de autorización por un token de acceso
access_token = client.exchange_code_for_token(
    client_id=client_id,
    client_secret=client_secret,
    code=authorization_code
)

# Ahora puedes usar el token de acceso para hacer solicitudes a la API de Strava
athlete = client.get_athlete()
print(f'Nombre del atleta: {athlete.firstname} {athlete.lastname}')

# Obtiene la última actividad del atleta
latest_activity = next(client.get_activities(limit=1))

# Imprime algunos detalles de la última actividad
print(f'Id de la actividad: {latest_activity.id}')
print(f'Nombre de la actividad: {latest_activity.name}')
print(f'Tiempo de inicio: {latest_activity.start_date}')
print(f'Distancia: {latest_activity.distance} metros')


# Descarga la última actividad

# Reemplaza 'ID_de_la_actividad' y 'tu_token_de_acceso' con los valores correctos
activity_id = latest_activity.id
access_token = authorization_code

# URL de la actividad en la API de Strava
activity_url = f'https://www.strava.com/api/v3/activities/{activity_id}/streams/time,latlng'
print(f'Esta es la actividad: {activity_url}')

# Agrega el token de acceso a los encabezados de la solicitud
headers = {'Authorization': f'Bearer {access_token}'}

# Realiza la solicitud GET para obtener los datos de la actividad
response = requests.get(activity_url, headers=headers)

# Verifica si la solicitud fue exitosa
if response.status_code == 200:
    # Guarda los datos de la actividad en un archivo GPX
    with open(f'{activity_id}.gpx', 'wb') as gpx_file:
        gpx_file.write(response.content)
    print(f'Se ha descargado el archivo GPX de la actividad {activity_id}.')
else:
    print(f'Error al descargar el archivo GPX. Código de estado: {response.status_code}')

