##################################################################
# Script Name: tiempo.py
# Description: Obsención del tiempo en zaragoza a través de AEMET
# Args: N/A
# Creation/Update: 20201020/20201020
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################
import requests
import time


from urllib.request import urlopen
from xml.etree.ElementTree import parse

estaciones = [["Zaragoza","9434P"],["Aeropuerto","9434"],["Quinto","9510X"],["Valmadrid","9501X"]]

for est in estaciones:
    # Creación de la url a partir de la identificación de la estación
    url="http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_"+est[1]+"_datos-horarios.csv?k=arn&l="+est[1]+"&datos=det&w=0&f=temperatura&x=h24"
    
    # Llamada a url - convertir a texto - eliminar las " - dividir horas por líneas
    datos = requests.get(url, allow_redirects=True).text.replace('"', "").splitlines()
    
    ubicacion=datos[0]

    i=4
    while i < 14:
        # Extracción de datos pra la ultima hora
        valores=datos[i].split(",")
        dia=valores[0].split(" ")[0]
        hora=valores[0].split(" ")[1]
        temperatura=valores[1]
        velocidad=valores[2]
        direccion=valores[3]

        # Si no hay datos para esta hora busca en la anterior
        if temperatura == "":
            i += 1
        else:
            break

    print(f"{dia} a las {hora} en {ubicacion}: Tª {temperatura}, Viento de {velocidad} m/s de dirección {direccion}")

url2="http://www.aemet.es/xml/municipios_h/localidad_h_50222.xml"

#datos2 = requests.get(url2, allow_redirects=True).text

var_url = urlopen(url2)
xmldoc = parse(var_url)

for item in xmldoc.iterfind('prediccion'):
    print(item)
    title = item.findtext('dia')

    print(title.values)


