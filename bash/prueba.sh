#echo "Creando la carpeta contenedora $GPhotos_dir ..."
#mkdir ~/gphotos-sync



#echo "Montando la carpeta contenedora $GPhotos_dir mediante sshfs ..."
# Monta la carpeta del nas "gphotos-sync" como una unidad en la carpeta local "gphotos-sync"
#sudo sshfs sherlockes@192.168.1.200:../../home/gphotos-sync ~/gphotos-sync -o allow_other



rclone mount nas-lan:/home/gphotos-sync ~/gphotos-sync --allow-other --daemon

# Ejecuta el script en python gphotos-sync
sleep 5

echo "Ejecutando el script gphotos-sync mediante pipenv ..."
pipenv run gphotos-sync ~/gphotos-sync 
echo "Desmontando Google Photos ..."
fusermount -u ~/gphotos-sync
#sleep 1
# echo "Borrando la carpeta $Gphotos_dir ..."
# rm -rf ~/gphotos-sync
echo "Terminado !!!" 
