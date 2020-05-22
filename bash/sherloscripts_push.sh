#Sube los cambios generados en la web a GitHub
rclone sync -v Sherlockes_GD:/SherloScripts/bash/ /home/pi/SherloScripts/bash

cd ~/SherloScripts
git add --all
git commit -m "Update"
git push -u origin master
exit 0
