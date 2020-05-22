#!/bin/bash
# -*- encoding: utf-8 -*-

###################################################################
#Script Name: sherloscripts_push.sh
#Description: Sube los cambios en Sherloscript al repositorio
#Args: N/A
#Creation/Update: 20200521/20200522
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

# ---------------------------------------------------------
# Copia la carpeta de Google Drive a /home/pi/SherloScripts
# ---------------------------------------------------------
rclone copy -v Sherlockes_GD:/SherloScripts/ /home/pi/SherloScripts/
rclone sync -v Sherlockes_GD:/SherloScripts/bash/ /home/pi/SherloScripts/bash/
rclone sync -v Sherlockes_GD:/SherloScripts/emacs/ /home/pi/SherloScripts/emacs/
rclone sync -v Sherlockes_GD:/SherloScripts/hugo/ /home/pi/SherloScripts/hugo/
rclone sync -v Sherlockes_GD:/SherloScripts/'google scripts'/ /home/pi/SherloScripts/'google scripts'/

# ---------------------------------------------------------
# Actualiza el repositorio de GitHub
# ---------------------------------------------------------
cd ~/SherloScripts
git add --all
git commit -m "Update"
git push
exit 0
