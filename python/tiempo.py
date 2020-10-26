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

estaciones = [["Zaragoza","9434P"],["Aeropuerto","9434"],["Quinto","9510"],["Valmadrid","9501"]]

for i in estaciones:

    url="http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_"+i[1]+"_datos-horarios.csv?k=arn&l=9434&datos=det&w=0&f=temperatura&x=h24"
    lectura = requests.get(url, allow_redirects=True)
    print(lectura.url)
    print(lectura.text)

    """open('./datos'+i[0]+'.csv', 'wb').write(lectura.content)
    del(lectura)

    with open(r'./datos'+i[0]+'.csv',encoding="ISO-8859-1") as f:
        data = f.readlines()[4]

        data = data.replace('"', "")
        datos = data.split(",")
        dia=datos[0].split(" ")[0]
        hora = datos[0].split(" ")[1]

        

        print(f"Los datos de {i[0]} del {dia} a las {hora}")
        print("Temperatura:",datos[1])
        print("Velocidad:",datos[2])
        print("Dirección:", datos[3])

    f.close()
    #time.sleep(65)"""