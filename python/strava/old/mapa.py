import os
import gpxpy
import folium
from folium.plugins import HeatMap

gpx_dir = "tracks"
heat_data = []

for gpx_file in os.listdir(gpx_dir):
    if gpx_file.endswith(".gpx"):
        gpx_file_path = os.path.join(gpx_dir, gpx_file)
        with open(gpx_file_path, "r") as gpx_file:
            gpx_data = gpxpy.parse(gpx_file)
            for track in gpx_data.tracks:
                for segment in track.segments:
                    for point in segment.points:
                        heat_data.append([point.latitude, point.longitude])

# Crea un mapa
m = folium.Map(location=[heat_data[0][0], heat_data[0][1]])

# Agrega los datos al mapa de calor
HeatMap(heat_data, radius=6, blur=0, min_opacity=10).add_to(m)

# Guarda el mapa como un archivo HTML
m.save("heatmap.html")
