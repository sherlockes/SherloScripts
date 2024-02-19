import gpxpy
import gpxpy.gpx
from geopy.distance import geodesic
from geopy.distance import great_circle

centro = (41.323915, -0.372230)
max_dist = 35000

# Ruta para guardar los archivos
ruta_strava='/home/sherlockes/strava/'

#######################################################
# Función para calcular la distancia entre dos puntos #
#######################################################
def calculate_distance(point1, point2):
    return round(great_circle(point1, point2).meters)

#######################################################
# Carga el archivo "filtered_points.txt con los datos #
#######################################################
with open("filtered_points.txt", "r") as file:
    content = file.read()

# Obtiene las coordenadas de cada línea y crea la matriz "coordenadas"
lines = content.split("\n")
coordenadas = []
coordenadas_filtradas = []

for line in lines:
    values = line.split(",")
    if len(values) == 2:
        # Asegúrate de que haya dos valores (latitud y longitud) en cada línea
        latitud, longitud = map(float, values)
        coordenadas.append((latitud, longitud))

print(f"Tenemos {len(coordenadas)} puntos para ordenar.")

# Eliminamos los puntos que están lejos para crear la matriz "coordenadas_filtradas"
for punto in coordenadas:
    # Distancia desde el centro
    distancia = calculate_distance(punto, centro)

    if distancia < max_dist:
        coordenadas_filtradas.append(punto)

print(f"Tenemos {len(coordenadas_filtradas)} puntos para ordenar.")


# Creando el track y segmento
gpx = gpxpy.gpx.GPX()
track = gpxpy.gpx.GPXTrack()
gpx.tracks.append(track)
segmento = gpxpy.gpx.GPXTrackSegment()
track.segments.append(segmento)

'''
# Añade el primer punto al segmento
if coordenadas:
    primer_punto = coordenadas[0]
    segmento.points.append(gpxpy.gpx.GPXTrackPoint(primer_punto[0], primer_punto[1]))
    coordenadas.remove(primer_punto)
    print(f"Tenemos {len(coordenadas)} puntos para ordenar")
'''

# Verifica si hay puntos en la lista 'coordenadas' y si el segmento no está vacío


print(f"Han quedado {len(coordenadas)} puntos.")
'''
with open("filtrados_35.txt", "w") as file:
                for point in coordenadas:
                    file.write(f"{point[0]}, {point[1]}\n")
'''

# Añade el primer punto.
if coordenadas_filtradas:
    primer_punto = coordenadas_filtradas[0]
    segmento.points.append(gpxpy.gpx.GPXTrackPoint(primer_punto[0], primer_punto[1]))
    coordenadas_filtradas.remove(primer_punto)

while coordenadas_filtradas:
    last_point = segmento.points[-1]  # Último punto del segmento
    min_distance = float('inf')  # Inicializa la distancia mínima con un valor infinito
    closest_point = None

    for coordinate in coordenadas_filtradas:
        distance = calculate_distance((last_point.latitude, last_point.longitude),
                                      (coordinate[0], coordinate[1]))
        if distance < min_distance:
            min_distance = distance
            closest_point = coordinate

    # Agrega el punto más cercano al segmento y elimínalo de 'coordenadas'
    if closest_point:
        segmento.points.append(gpxpy.gpx.GPXTrackPoint(closest_point[0], closest_point[1]))
        coordenadas_filtradas.remove(closest_point)
        print(f"Quedan {len(coordenadas)} puntos. Este estaba a {min_distance}")
        if(len(segmento.points) > 400):
            with open("segmento_35.gpx", "w") as f:
                f.write(gpx.to_xml())
            break
