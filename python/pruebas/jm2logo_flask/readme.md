https://j2logo.com/leccion-1-la-primera-aplicacion-flask/

* Crear entorno virtual - virtualenv env
* arrancar virtualenv - source env/bin/activate
* Instalar Flask - pip install flask
* Editar "env/bin/activate" añadiendo el fichero de la aplicación 'export FLASK_APP="run.py"'
* Desactivar el entorno virtual (deactivate) y volverlo a activar (source env/bin/activate)
* Lanzar el servidor - flask run (para aceptar conexiones de otros pc's "flask run --host 0.0.0.0")
* Para cambiar el puerto, editar "activate" y añadir "flask run --port 6000"
* Para activar el modo debug , editar "activate" y añadir "export FLASK_ENV="development""

https://j2logo.com/tutorial-flask-leccion-2-plantillas/

* Importar la funcion render_template - from flask import Flask, render_template


https://j2logo.com/tutorial-flask-leccion-3-formularios-wtforms/


