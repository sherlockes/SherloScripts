#!/bin/bash

###################################################################
#Script Name: linux_min_post_install.sh
#Description: Archivo a ejecutar tras la instalación de Linux Mint
#Args: N/A
#Creation/Update: 20230827/20230827
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

# El primer paso es instalar Insync y sincronizar "dotfiles" y "sherloscripts"
# en la carpeta "~/Gdrive"

# Actualizar el sistema
sudo apt update

# Crear el enlace a los Dotfiles
ln -si ~/GDrive/dotfiles ~/dotfiles

# Eliminar el compilador cd c gcc e instalar clang (problemas Sqlite)
sudo apt remove gcc
sudo apt install clang

# Instalación de Emacs y corrección ortográfica
sudo apt install emacs
sudo apt install ispell
sudo apt install aspell-es
ln -si ~/dotfiles/emacs/.emacs ~/.emacs
ln -si ~/dotfiles/emacs/.emacs.d/bookmarks ~/.emacs.d/bookmarks

# Instalación de Hugo
sudo apt install hugo

# Instalación del cliente para Wireguard
sudo apt install wireguard
sudo apt install resolvc

# Instalación y configuración de git
sudo apt install git
git config --global user.email sherlockes@yahoo.es
git config --global user.name sherlockes

# Instalación de Zerotier y adhesión a red personal
curl -s https://install.zerotier.com/ | sudo bash
sudo zerotier-cli join 83048a0632dad18a

# Instala Rclone y crea el directorio de configuración
sudo -v ; curl https://rclone.org/install.sh | sudo bash
mkdir -p ~/.config/rclone
ln -si ~/dotfiles/rclone/rclone.conf ~/.config/rclone/rclone.conf

# Configuración de bash
ln -si ~/dotfiles/bash/.bash_aliases ~/.bash_aliases
ln -si ~/dotfiles/ssh/config ~/.ssh/config
ssh-keygen

# Eliminar paquetes sobrantes
sudo apt autoremove



