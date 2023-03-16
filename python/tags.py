#!/usr/bin/python3



import requests
from bs4 import BeautifulSoup

# import OS module
import os

# Get the list of all files and directories
path = "/home/pi/sherblog/content/post"
dir_list = os.listdir(path)

print("Archivos en '", path, "' :")

# prints all files
files = os.listdir(path)
files = [f for f in files if os.path.isfile(path+'/'+f)]

# Filtering only the files.
# print(*files, sep="\n")

y = 1
for x in files:
    if x.endswith(".md"):
        # Prints only text file present in My Folder
        print(str(y) + ".-" + str(x))
        y = y + 1




# URL del sitio web
url = "https://sherblog.pro"

# Descarga el contenido del sitio web
response = requests.get(url)

# Parsea el contenido HTML usando BeautifulSoup
soup = BeautifulSoup(response.content, "html.parser")

# Encuentra todos los tags en el sitio web
tags = soup.findAll(class_="widget-taglist__link widget__link btn")

lista_tags = []

for tag in tags:
    lista_tags.append(tag.get('title'))

print(lista_tags)
