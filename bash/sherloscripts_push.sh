#Sube los cambios generados en la web a GitHub
rclone sync -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/

cd ~/SherloScripts
git add --all
git commit -m "Update"
git push -u origin master
exit 0
