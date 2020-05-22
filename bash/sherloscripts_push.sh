#Sube los cambios generados en la web a GitHub
rclone copy -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/

cd ~/SherloScripts
git add --all
git commit -m "Update"
git push
exit 0
