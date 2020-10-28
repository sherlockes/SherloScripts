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
from datetime import date
import datetime
from statistics import mean
 
from urllib.request import urlopen
from xml.etree.ElementTree import parse

estaciones = [["Zaragoza","9434P","50297"],["Aeropuerto","9434","50272"],["Quinto","9510X","50222"],["Valmadrid","9501X","50275"]]


for est in estaciones:

    # Variables para parámetros
    temperatura=[]
    velviento=[]
    dirviento=[]

    hoy = str(date.today())
    hora = datetime.datetime.now().time().hour

    # Extracion de valores anteriores

    # Creación de la url a partir de la identificación de la estación
    url="http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_"+est[1]+"_datos-horarios.csv?k=arn&l="+est[1]+"&datos=det&w=0&f=temperatura&x=h24"

    # Llamada a url - convertir a texto - eliminar las " - dividir horas por líneas
    datos = requests.get(url, allow_redirects=True).text.replace('"', "").splitlines()

    ubicacion=datos[0]

    i=4
    while i < 23:
        # Extracción de datos para la ultima hora
        valores=datos[i].split(",")
        dia=valores[0].split(" ")[0]
        hora=valores[0].split(" ")[1].split(":")[0]

        # Si no hay datos para esta hora busca en la anterior
        if valores[1] != "":
            velviento.append(int(valores[2]))
            dirviento.append(valores[3])
            temperatura.append(int(round(float(valores[1]))))

        if hora == "00":
            temperatura.reverse()
            velviento.reverse()
            break

        i +=1

    ##########################################
    ########        Predicción        ########
    ##########################################

    # Parseo del xml de la predicción de la AEMET para el día de hoy
    url2="http://www.aemet.es/xml/municipios_h/localidad_h_"+ est[2] +".xml"
    xmldoc = parse(urlopen(url2))

    for item in xmldoc.iterfind("prediccion/dia"):
        fecha = item.get('fecha')
        orto =  item.get("orto")
        ocaso = item.get("ocaso")

        # Extracción de la velocidad del viento
        if fecha == hoy:
            for viento in item.iterfind("viento"):
                # Compara la hora de la predición con las ya escritas en la matriz correspondiente
                if int(viento.attrib['periodo']) == len(velviento):
                    velviento.append(int(viento.findtext('velocidad')))
                    dirviento.append(viento.findtext('direccion'))
            for tra in item.iterfind('temperatura'):
                if int(tra.attrib['periodo']) == len(temperatura):
                    temperatura.append(int(tra.text))
                

    # Cambiando los nombre por siglas...
    dirviento = ['N' if x=='Norte' else x for x in dirviento]
    dirviento = ['NO' if x=='Noroeste' else x for x in dirviento]
    dirviento = ['NE' if x=='Nordeste' else x for x in dirviento]
    dirviento = ['S' if x=='Sur' else x for x in dirviento]
    dirviento = ['SO' if x=='Sudoeste' else x for x in dirviento]
    dirviento = ['SE' if x=='Sudeste' else x for x in dirviento]
    dirviento = ['E' if x=='Este' else x for x in dirviento]
    dirviento = ['O' if x=='Oeste' else x for x in dirviento]
    dirviento = ['-' if x=='Calma' else x for x in dirviento]


    # Cálculo de valores actuales, mínimos y máximos
    hora = int(datetime.datetime.now().time().hour)

    tempactual=round(temperatura[hora])
    tempmax=round(max(temperatura))
    tempmin=round(min(temperatura))
    tempmedia=round(mean(temperatura))
    velactual=round(velviento[hora])
    velmedia=round(mean(velviento))
    velmax=round(max(velviento))
    velmin=round(min(velviento))

    print(f"{est[0]} - {hoy} a las {hora}")
    print(f"Temperatura > Actual {tempactual}ºC - Media {tempmedia}ºC ({tempmin}-{tempmax})")
    print(f"Viento > Actual {velactual}m/s de {dirviento[hora]} - Media {velmedia}m/s ({velmin}-{velmax})")
    print("----------------------------------------------------------------")