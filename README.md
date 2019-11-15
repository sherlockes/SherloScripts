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

## [hugo_update.sh](https://github.com/sherlockes/SherloScripts/blob/master/hugo_update.sh) (Bash) ##
Para la creación y mantenimiento de [Sherblog)(www.sherblog.pro) utilizo [Hugo](https://gohugo.io) sobre mi equipo local con linux mint o la Raspberry Pi 3B+. Este script, que tengo programado para ejecutarse a diario, se encarga de realizar una actualización de versión de Hugo en caso de que sea necesario.

Entre otras cosas, lo que he utilizado para su desarrollo es:

* Uso del comando "getconf" para los bits de la máquina
* Extracción de cadenas con Regex y Perl
* Descarga de páginas web con "curl"
* Extracción de cadenas con "grep", "cut" y "tr"
* Instalación de paquetes con "dpkg"

## [Sherlomenu](https://github.com/sherlockes/SherloScripts/blob/master/sherlomenu) (Bash) ##
Un pequeño lanzador para montar el local las distintas nubes que uso a diario tanto en Google Drive como en Mega gracias a Rclone. Tambien está incluido un apartado para realizar la copia de seguridad de Google Photos y el Push automático de este repositorio.

* Uso básico de Rclone (mount)
* Montaje mediante sshfs
* Git commit y push básico
* Montaje de Google photos mediante gphotos-sync
* Condiionales en Bash (En una o varias líneas)
* Uso de variables indirectas en Bash
* Uso del comando "case"

## [Radares.sh](https://github.com/sherlockes/SherloScripts/blob/master/radares.sh) (Bash) ##
Por que estar pendiente de cuando se actualiza la base de datos de radares de tráfico de www.laradiobbs.net, descomprimirla combinarla y renombrarla es un poco latoso he creado este pequeño script en Bash que lo hace de forma completamente desatendida.  Inluido en el crontab de la Raspberry Pi, ella sola se encarga de "acondicionar" los ficheros y guardarlos en una nube de Google Drive (Mediante Rclone) para poder acceder con cualquier terminal.

* Descarga de archivos con "curl"
* Descomprimir archivos zip con "unzip"
* Renombrado y borrado de archivos con "mv" y "rm"
* Uso básico de expresiones regulares
* Sincronización con una carpeta de Google Drime mediante Rclone
* Fusión de archivos con el comando "cat"

## [Publish.sh](https://github.com/sherlockes/SherloScripts/blob/master/publish.sh) (Bash) ##
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

