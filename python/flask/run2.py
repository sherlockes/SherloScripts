from flask import Flask
from flask import request
from flask import render_template

app = Flask(__name__)

@app.route('/user/<name>')
def user(name="Eduardo"):
    lista=[1,2,3,4]
    edad = 20
    return render_template('user.html', nombre=name,lista=lista,edad=edad)

if __name__ == '__main__':
    app.run( debug = True, port = 8000)