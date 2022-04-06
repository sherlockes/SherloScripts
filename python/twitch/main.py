import subprocess
import json
from lista import Lista

CANAL = "jordillatzer"

lista = Lista(CANAL)

# Comprueba que hay para descargar
if not lista.no_vistos():
    print ("No hay nada para descargar")
else:
    for i in lista.no_vistos():
        print(i['id'])
        subprocess.run("python3 twitch-dl.pyz download -q audio_only " + str(i['id']), shell=True)

#lista.grabar()


#grabar_lista()
#print(leer_lista()[1])

#print("Este es el ultimo vídeo")
#print(ULTIMOS_VIDEOS['videos'][0]['id'])