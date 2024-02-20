import os
import sys
import gpxpy
from geopy.distance import great_circle
import folium
import shutil

centro = (41.323915, -0.372230)
max_dist = 35000
bar_length = 50

root_dir = "/home/sherlockes/strava/"

# Directorio donde se encuentran los archivos GPX
gpx_dir = root_dir + "tracks"
# Directorio donde se moverán los archivos GPX analizados
analyzed_dir = root_dir + "tracks_analizados"

# Lista para almacenar los puntos filtrados y archivo de respaldo
filtered_gpx_points = []
file_name_filtered = root_dir + "filtered_points.txt"

# Ubicación para general el mapa
map_file = root_dir + "points_map.html"

# Lista para almacenar todos los puntos de los archivos GPX
gpx_points = []

################################################
# Cargar el archivo de los puntos ya filtrados #
################################################
print("Cargando los datos ya filtrados existentes...")
if os.path.exists(file_name_filtered):
    with open(file_name_filtered, "r") as file:
        for line in file:
            # Divide la línea en latitud y longitud, suponiendo que están separadas por una coma
            lat_str, lon_str = line.strip().split(",")
            # Convierte las cadenas en números de punto flotante
            latitude = float(lat_str)
            longitude = float(lon_str)
            filtered_gpx_points.append((latitude, longitude))
    print(f"Se han cargado {len(filtered_gpx_points)} puntos ya filtrados.")
else:
    print(f"El archivo {file_name_filtered} no existe.")

#####################################################
# Carga los puntos de los archivo gpx en gpx_points #
#####################################################
print("Cargando los archivos gpx...")
i=1
total = len(os.listdir(gpx_dir))

for gpx_file in os.listdir(gpx_dir):
    # Barra de porcentaje
    progress = i/total
    arrow = '#' * int(progress * bar_length)
    spaces = ' ' * (bar_length - len(arrow))
    sys.stdout.write('\rProgreso: [{0}] {1}%'.format(arrow + spaces, int(progress * 100)))
    sys.stdout.flush()
    i+=1

    if gpx_file.endswith(".gpx"):
        gpx_file_path = os.path.join(gpx_dir, gpx_file)
        with open(gpx_file_path, "r") as gpx_file:
            gpx_data = gpxpy.parse(gpx_file)
            for track in gpx_data.tracks:
                for segment in track.segments:
                    points = [(point.latitude, point.longitude) for point in segment.points]
                    gpx_points.extend(points)

        # Mueve el archivo GPX a la carpeta "tracks_analyzed"
        gpx_file_name = os.path.basename(gpx_file_path)
        shutil.move(gpx_file_path, os.path.join(analyzed_dir, gpx_file_name))
        #print(f"El archivo {gpx_file_name} ha sido archivado")

print(f" - Puntos importados: {len(gpx_points)}")

############################################################
# Si no existe la lista de filtrados añade el primer punto #
############################################################
if len(filtered_gpx_points) == 0:
    print("No hay puntos ya filtrados")
    filtered_gpx_points.append((gpx_points[0][0], gpx_points[0][1]))


#######################################################
# Función para calcular la distancia entre dos puntos #
#######################################################
def calculate_distance(point1, point2):
    return great_circle(point1, point2).meters


################################################################
# Añadir a filtered_gpx_points los puntos con distancia mínima #
################################################################
i = 1


for new_point in gpx_points:
    # Barra de porcentaje
    progress = i/len(gpx_points)
    arrow = '#' * int(progress * bar_length)
    spaces = ' ' * (bar_length - len(arrow))
    sys.stdout.write('\rProgreso: [{0}] {1}%'.format(arrow + spaces, int(progress * 100)))
    sys.stdout.flush()
    
    add_point = True  # Suponemos que se añadirá el punto

    i += 1
    for existing_point in filtered_gpx_points:
        # Distancia desde el centro del mapa < max_dist
        distancia = calculate_distance(new_point, centro)
        if distancia > max_dist:
            add_point = False  # No añadir el punto si está demasiado cerca de otro punto existente
            #print(f"Eliminado punto lejano {new_point}, analizado un {round((i*100)/len(gpx_points))}%")
            break
        
        # Calcular la distancia entre el nuevo punto y los puntos existentes < 15 m
        distance = calculate_distance(new_point, existing_point) 
        if distance < 15:
            add_point = False  # No añadir el punto si está demasiado cerca de otro punto existente
            #print(f"Eliminado punto {new_point}, analizado un {round((i*100)/len(gpx_points))}%")
            break
    if add_point:
        #print(f"Añadido punto {new_point}, analizado un {round((i*100)/len(gpx_points))}%")
        filtered_gpx_points.append(new_point)  # Añadir el punto si cumple con la distancia mínima

# Lista de puntos filtrados llamada "filtered_gpx_points"
print(f"Puntos tras filtrar: {len(filtered_gpx_points)}")


#####################################################
# Guardar la lista de puntos en un archivo de texto #
#####################################################
with open(file_name_filtered, "w") as file:
    for point in filtered_gpx_points:
        file.write(f"{point[0]}, {point[1]}\n")

print(f"Se han guardado {len(filtered_gpx_points)} puntos en el archivo {file_name_filtered}")

##########################################
# Crear un mapa con los puntos filtrados #
##########################################
print("Generando el mapa con los puntos...")
latitud, longitud = centro
m = folium.Map(location=[latitud, longitud], zoom_start=12)

for coord in filtered_gpx_points:
    folium.CircleMarker(
        location=[coord[0], coord[1]],
        radius=0.5,  # Tamaño del punto rojo
        color='blue',  # Color del punto rojo
    ).add_to(m)

# Guardar el mapa como un archivo HTML
m.save(map_file)
