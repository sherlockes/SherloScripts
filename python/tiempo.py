##################################################################
# Script Name: tiempo.py
# Description: Obsención del tiempo en zaragoza a través de AEMET
# Args: N/A
# Creation/Update: 20201020/20201020
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################
import requests

url_aeropuerto="http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_9434_datos-horarios.csv?k=arn&l=9434&datos=det&w=0&f=temperatura&x=h24"
url_zgz='http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_9434P_datos-horarios.csv?k=arn&l=9434P&datos=det&w=0&f=temperatura&x='

myfile = requests.get(url_aeropuerto, allow_redirects=True)

open('./datos.csv', 'wb').write(myfile.content)

with open(r'./datos.csv',encoding="ISO-8859-1") as f:
    data = f.readlines()[4]

data = data.replace('"', "")
datos = data.split(",")
dia=datos[0].split(" ")[0]
hora = datos[0].split(" ")[1]

print(f"Los datos son del {dia} a las {hora}")
print("Temperatura:",datos[1])
print("Velocidad:",datos[2])
print("Dirección:", datos[3])
