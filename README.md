# SherloScripts #
Una cajón desastre para mis scripts en bash, python, elisp...

## [Mi diario en Org-Mode](https://github.com/sherlockes/SherloScripts/blob/master/mi_diario.org) (org-mode) ##
En este archivo en formato org-mode voy escribiendo lo que día a día aprendo y utilizo en cualquiera de las plataformas que empleo. Un cuaderno de bitácora que consultar cuando no me acuerdo de como en su día hice algo

* emacs
* Hugo
* Org-Mode
* Debian y Linux
* Bash
* Markdown
* Python
* Y lo que vaya utilizando...

## [ghotos-sync.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/gphotos-sync.sh)(bash) ##
Tras un tiempo realizando la sincronización de mi galería de Google Photos a mi NAS de forma manual a través de un script que corría en el ordenador de sobremesa ahora he conseguido que el paquete ghotos-sync funcione en la raspberry de forma que cada día hace una sincronización. Los temas que toco en esta script son:

* Comprobación de la instalación de paquetes
* Comprobación de conexión a unidades remotas
* Montaje de unidades remotas mediante sshfs
* Ejecución de gphotos mediante pipenv

Para que el cript funcione de forma autónoma es necesaria tener configurada el acceso ssh de un equipo a otro mediente llave público-privada (ssh-key-gen)

## [Limpieza_gmail.gs](https://github.com/sherlockes/SherloScripts/blob/master/python/limpieza_gmail.gs)(google scripts  ##
Eliminar correos de publicidad e irrelevantes es una tarea que lleva su tiempo. Con este pequeño script que se ejecute cada hora consigo tener la bandeja de entrada mucho más limpia sin esfuerzo. Se tocan los siguientes aspectos:

* Busqueda en Gmail por etiqueta, categoría y tiempo
* Uso de bucle for con contador incremental
* Eliminación de mensajes

Toda la info sobre la creación y funcionamiento del script la puedes encontrar en este [artículo](https://sherblog.pro/automatizando-la-limpieza-de-gmail/) de mi blog.

## [Renamer.py](https://github.com/sherlockes/SherloScripts/blob/master/python/renamer.py)(python) ##
Fruto de una necesidad de un renombraro rápido de unos cuantos cientos de fotografías. Nada pretencioso ni complicado simplemente rápido y efectivo que toca los siguientes aspectos:

* Chequeo de ruta y nombre de directorio actual
* Sustitución de caracteres en cadenas con "replace"
* Listar archivos de un directorio con "os.listdir"
* Manejo de bucles for y while
* Uso del condicional "if" para la comprobación de archivo
* Uso del paquete "exif" para extracción de info de las fotos
* Manejo del metodo "datetime"
* Creación de rutas a aprtir de cadenas con "os.path.join"
* Renombrado de archivos con "os.rename"

## [Tiempo.py](https://github.com/sherlockes/SherloScripts/blob/master/python/tiempo.py)(python)
Mi primer Script en Python. Este realiza un pequeño resumen de las condiciones meteorológicas diarias extrayendo la información de la web de AEMET, no a través de su API sino que a través de su "*.csv" y "*.xml" públicos. Toca unos cuantos palos entre los que podemos encontar:

* Manejo de listas (Creación, lectura, añadir elementos, trasposición, reemplazar valores...)
* Manejo de fechas y horas
* Elementos matemáticos. Conversión a entero y flotante, redondeo, máximos, minimos, medio
* Uso de condicionales "IF" y bucles "FOR" y "WHILE"
* Extracción de datos de un archivo "*.csv" externo
* Extracción de información de un archivo "*.xml" ubicado en la red
* Manejo de cadenas (Definir, añadir, reemplazar...)
* Almacenamiento de variables en un archivo de configuración externo
* Envío de mensajes de Telegram a través de un bot

## [Post.sh](https://github.com/sherlockes/SherloScripts/blob/master/hugo/shortcodes/post.sh)(bash) ##
Con este script doy de más funcionalidad a [Publish.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/publish.sh) para que los Post en Hugo sean automáticamente formateados con la correspondiente cabecera haciendo uso de varias funciones de Bash. Está obsoleto por haber introducido las funciones dentro del archivo "Publish.sh"
* Cálculo de líneas con `wc`
* Extracción de la 1ª linea con `head`
* Extracción de la segunda línea con `sed`
* Extracción de las últimas líneas con `tail`
* Separación de líneas en compos con `cut`
* Cálculo del tiemo desde la última modificación con `date`
* Buscar arcivos sin cabecera con `grep`

## [lista_vertices.html](https://github.com/sherlockes/SherloScripts/blob/master/hugo/shortcodes/lista_vertices.html) (Hugo Shortcodes)##
Gracias a este [Shortcode](https://gohugo.io/content-management/shortcodes/) que utilizo en mi blog desarrollado en [Hugo](https://gohugo.io/) consigo de una forma sencilla incluir una lista con todos los enlaces a las distintas páginas de una determinada categoría. En mi aso lo utilizo para listar todos los Vértices geodésicos que estan inluidos en la categoría "vertices". Su uso es tan sencillo como copiarlo dentro de la carpeta "layouts/shortcodes/" y llamarlo desde donde queramos incluri la lista con "{{< lista_vertices >}}". Hace uso de:
* Filtrado de páginas por el contenido de una "section" (Carpeta)
* Uso de la función "Range"
* Acceso a parámetros de las páginas
* Determinación de la existencia de un parámetro.

## [mapa_vertice.html](https://github.com/sherlockes/SherloScripts/blob/master/hugo/shortcodes/mapa_vertice.html) (Hugo Shortcodes)##
Con este [Shortcode](https://gohugo.io/content-management/shortcodes/) que utilizo en mi blog desarrollado en [Hugo](https://gohugo.io/) introducto en cada página de la sección "vertices" toda la información relativa al mismo estrayendola de los parámetros de la propia página:
* Cálculo del total de vértices
* Introducir la información del vértice
* Introducir la foto del vértice
* Creación del mapa con [Openlayers](https://openlayers.org/)
* Inclusión de la vista panorámica
* Inclusión de la ruta para gps


## [parse_gpx.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/parse_gpx.sh) (Bash)##
Este sencillo script recorre todos los archivos de la web de la carpeta donde ubico los vértices geodésicos para extraer de ellos los parámetros suficientes para generar una archivo *.gpx con el que poder representarlos en un mapa.


## [rclone.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/rclone.sh) (Bash)
Por el método de instalación que tiene, [Rclone](https://rclone.org/) no se actualiza automáticamente. Este script comenzó siendo una pequeña utilidad para actualizarlo automáticamente pero poco a poco ha ido ganando funcionalidades:

* Comprueba la arquitectura del procesador
* Comprueba la instalación de Rclone
* Comprueba la actualización de Rclone
* Lista las nubes disponibles en .config
* Monta y desmonta cualquiera de las nubes

## [mover_archivos.gs](https://github.com/sherlockes/SherloScripts/blob/master/google%20scripts/20191219_mover_archivos.gs) (Google Scripts) ##
En mi lucha por descargar los archivos de Telegram al NAS he necesitado un pequeño script que corre dentro de la nube de google y cuya finalidad es mover los archivos que hay en la raiz de la unidad y meterlos dentro de una carpeta compartida que sincronizo con ni Synology. Todos los días esta utilidad vacía la carpeta y borra la papelera para poder mover más archivos.

Entre otras cosas, lo que he utilizado para su desarrollo es:
* Listar los archivos de un directorio - Método "getFiles()
* Seleccionar un directorio por "Id" - Método "getFolderById(id)"
* Añadir un nuevo archivo - Método "addFile(file)"
* Eliminar un archivo - Método "removeFile(file)"
* Seleccionar archivos por fecha de modificación - Método "getLastUpdated()"
* Vaciar la papelera de reciclaje

Este script y el resto de utilidades necesarias para mover los archivos de Telegram al NAS lo puedes encontrar en [Sherblog](https://sherblog.pro/archivos-de-telegram-al-nas/)

## [hugo_update.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/hugo_update.sh) (Bash) ##
Para la creación y mantenimiento de [Sherblog)(www.sherblog.pro) utilizo [Hugo](https://gohugo.io) sobre mi equipo local con linux mint o la Raspberry Pi 3B+. Este script, que tengo programado para ejecutarse a diario, se encarga de realizar una actualización de versión de Hugo en caso de que sea necesario.

Entre otras cosas, lo que he utilizado para su desarrollo es:

* Uso del comando "getconf" para los bits de la máquina
* Extracción de cadenas con Regex y Perl
* Descarga de páginas web con "curl"
* Extracción de cadenas con "grep", "cut" y "tr"
* Instalación de paquetes con "dpkg"

## [Sherlomenu](https://github.com/sherlockes/SherloScripts/blob/master/bash/sherlomenu) (Bash) ##
Un pequeño lanzador para montar el local las distintas nubes que uso a diario tanto en Google Drive como en Mega gracias a Rclone. Tambien está incluido un apartado para realizar la copia de seguridad de Google Photos y el Push automático de este repositorio.

* Uso básico de Rclone (mount)
* Montaje mediante sshfs
* Git commit y push básico
* Montaje de Google photos mediante gphotos-sync
* Condiionales en Bash (En una o varias líneas)
* Uso de variables indirectas en Bash
* Uso del comando "case"

## [Radares.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/radares.sh) (Bash) ##
Por que estar pendiente de cuando se actualiza la base de datos de radares de tráfico de www.laradiobbs.net, descomprimirla combinarla y renombrarla es un poco latoso he creado este pequeño script en Bash que lo hace de forma completamente desatendida.  Inluido en el crontab de la Raspberry Pi, ella sola se encarga de "acondicionar" los ficheros y guardarlos en una nube de Google Drive (Mediante Rclone) para poder acceder con cualquier terminal.

* Descarga de archivos con "curl"
* Descomprimir archivos zip con "unzip"
* Renombrado y borrado de archivos con "mv" y "rm"
* Uso básico de expresiones regulares
* Sincronización con una carpeta de Google Drime mediante Rclone
* Fusión de archivos con el comando "cat"

## [Publish.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/publish.sh) (Bash) ##
Al usar un generador de páginas estáticas como es Hugo para la administración de www.sherblog.pro, guardar los archivos fuente en Google Drive y usar como alojamiento a Github la publicación de un nuevo artículo se vuelve en algo laborioso. Por esto he creado este script que realiza los siguientes pasos

* Actualiza Hugo
* Sincroniza Google Drive con las carpetas locales
* Añade una cabecera a los archivos que no la tienen
* Actualiza los archivos de la nube a los nuevos con cabecera
* Genera la web estática
* Sube la web a GitHub

Para ello he utilizado, entre otros, los siguientes conceptos
* Uso de "rclone" para sincronizar carpetas
* Uso de "fname" para extraer nombres de archivos
* Uso de la propiedad "date" para calculos del tiempo de modificación
* Uso de "cat" para añadir texto a archivos existentes
* Uso de "git push"

## [sherblog_db_backup](https://github.com/sherlockes/SherloScripts/blob/master/google%20scripts/20171210_sherblog_db_backup.gs) (Google Scripts) ##

Cuando la web estaba en WordPress, este es el script que utilizaba para realizar una copia de seguriadd versionada de la base de datos de forma manual.  El script busca todos los archivos de una carpeta determinada y sólo guarda un número determinado en función de su antigüedad.

Toda la información la puedes encontrar en [Sherblog](https://sherblog.pro/copia-de-seguridad-de-la-base-de-datos-de-wordpress/)

Entre otras cosas, los métodos que utiizo con los siguientes:

* Creación de fechas con el método "Date()"
* Creación de matrices con el método "Array()"
* Listar los archivos de una carpeta con el método "getFiles()"
* Comparación de antigüedad de los archivos mediante "getLastUpdated()"
* Eliminación de elementos de una matriz mediante "splice()"


