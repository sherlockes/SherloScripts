import requests

estacion_aemet = "9434P"
url_aemet = "http://www.aemet.es/es/eltiempo/observacion/ultimosdatos_" + estacion_aemet + "_datos-horarios.csv?k=arn&l=" + estacion_aemet + "&datos=det&w=0&f=temperatura&x=h24"


aemet_datos = requests.get(url_aemet, allow_redirects=True).text.replace('"', "").splitlines()
aemet_temp = float(aemet_datos[4].split(",")[1])



for i in range(4,len(aemet_datos)):
    temp += float(aemet_datos[i].split(",")[1])
    num += 1

aemet_media = round(temp / num,1)
print(aemet_media)
