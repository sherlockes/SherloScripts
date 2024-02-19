import os
import gpxpy
import folium

# Directorio donde se encuentran los archivos GPX
gpx_dir = "tracks"

# Crea un mapa
m = folium.Map(location=[41.34, -0.37], zoom_start=12)

# Personaliza el estilo de las rutas
route_style = {
    'color': 'blue',    # Color de las rutas
    'weight': 2,        # Ancho de las rutas (ajusta este valor para hacerlas más estrechas)
}

# Itera a través de los archivos GPX y agrega las rutas y puntos al mapa
for gpx_file in os.listdir(gpx_dir):
    if gpx_file.endswith(".gpx"):
        gpx_file_path = os.path.join(gpx_dir, gpx_file)
        with open(gpx_file_path, "r") as gpx_file:
            gpx_data = gpxpy.parse(gpx_file)
            for track in gpx_data.tracks:
                for segment in track.segments:
                    points = [(point.latitude, point.longitude) for point in segment.points]
                    folium.PolyLine(points, **route_style).add_to(m)

# Guarda el mapa como un archivo HTML
m.save("segments_map.html")
