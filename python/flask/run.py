from flask import Flask
from flask import request

app = Flask(__name__)

@app.route('/')
def index():
    return "Hola Mundo y los aledaños de la comarca..."

# Pasar parámetros en la url modo 1
""" 
@app.route('/params')
def params():
    param = request.args.get('params1', 'No contien este parámetro')
    #return 'El parámetro es {}'.format(param)
    return 'El parámetro es ' + param
"""

# Pasar parámetros en la url modo 2
@app.route('/params')
@app.route('/params/<name>')
@app.route('/params/<name>/<int:num>')
def params(name = "Valor por defecto",num=5):
    return 'El parámetro es ' + name + str(num * 5)

if __name__ == '__main__':
    app.run( debug = True, port = 8000 )