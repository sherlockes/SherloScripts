# Ubicación de la carpeta local
Carpeta_local=~/clouds/gphotos-sync

# Crea la carpeta gphotos-sync
echo "Creando la carpeta contenedora $GPhotos_dir ..."
mkdir $Carpeta_local

# Monta la carpeta del nas "gphotos-sync" como una unidad en la carpeta local "gphotos-sync"
echo "Montando la carpeta contenedora $GPhotos_dir mediante sshfs ..."
sshfs sherlockes@192.168.1.200:../../home/gphotos-sync $Carpeta_local
cd $Carpeta_local

# Ejecuta el script en python gphotos-sync
echo "Ejecutando el script gphotos-sync mediante pipenv ..."
pipenv run gphotos-sync $Carpeta_local 
sleep 5

# Desmonta la unidad
echo "Desmontando Google Photos ..."
fusermount -u $Carpeta_local

# Borra la carpeta
#echo "Borrando la carpeta $Gphotos_dir ..."
#rm -rf $Carpeta_local

echo "Terminado !!!" 
