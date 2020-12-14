from aemet import Aemet

alum = Aemet("9434P",20)
print(alum.temp_actual)
print(alum.temp_media)
