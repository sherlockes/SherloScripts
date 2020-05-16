# SherloScripts #
Una cajón desastre para mis scripts en bash, python, elisp...

## [Mi diario en Org-Mode](https://github.com/sherlockes/SherloScripts/blob/master/mi_diario.org) (org-mode) ##
En este archivo en formato org-mode voy escribiendo lo que día a día aprendo y utilizo en cualquiera de las plataformas que empleo. Un cuaderno de bitácora que consultar cuando no me acuerdo de como en su día hice algo

* emacs
* Org-Mode
* Debian y Linux
* Bash
* Markdown
* Python
* Y lo que vaya utilizando...


## [parse_gpx.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/parse_gpx.sh) ##
Este sencillo script recorre todos los archivos de la web de la carpeta donde ubico los vértices geodésicos para extraer de ellos los parámetros suficientes para generar una archivo *.gpx con el que poder representarlos en un mapa.


## [rclone.sh](https://github.com/sherlockes/SherloScripts/blob/master/bash/rclone.sh) (Bash)
Por el método de instalación que tiene, [Rclone](https://rclone.org/) no se actualiza automáticamente, por esto he creado este pequeño script que instala la utilidad para conectar con nubes en caso de que no la tengamos instalada o comprueba (e instala) las posibles actualizaciones que haya de la misma.

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


