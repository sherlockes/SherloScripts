#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# Raspberry custom init config script
# Updated on 20200926
# Created on 20181106
# Developed by Sherlockes
# www.sherblog.pro/files/raspiconfig.sh
# Description & config parameters
# Change Pi password
cfg_pass=false
new_password="tu_contraseña"
# Firmware & Packages update
cfg_update=false
# Configure local network
cfg_network=false
ipadress=192.168.1.203
gateway=192.168.1.1
# Configure timezone & locale
cfg_timezone=false
# Install Git & GitHub
cfg_git=false
cfg_git_email='sherlockes@yahoo.es'
cfg_git_name='sherlockes'
# Clone & configure SherloScripts repo
cfg_sherloscripts=false
cfg_sherloscripts_url='git+ssh://git@github.com/sherlockes/SherloScripts.git'
# Clone & configure Sherblog repo
cfg_sherblog=true
cfg_sherblog_url='git+ssh://git@github.com/sherlockes/sherlockes.github.io.git'
# Install Hugo
cfg_hugo=false
# Install Rclone
cfg_rclone=false
rclone_config_host=sherlockes@192.168.1.22
rclone_config_path=sherlockes@192.168.1.22:/home/sherlockes/.config/rclone/rclone.conf
# Schedule daily restart
cfg_restart=false
#   - Installing pivpn server
#	- Install Pi-Hole



# Modificamos el password para el usuario pi
if [ "$cfg_pass" = true ]; then
    echo "Cambiando la contraseña del usuario Pi..."
    #sudo echo -e "raspberry\n$new_password\n$new_password" | passwd pi
fi

### Actualización del sistema
if [ "$cfg_update" = true ]; then
    echo "Actualizando el sistema..."
    #sudo apt-get update
    #sudo apt-get upgrade -y
    #sudo apt-get install rpi-update
    #sudo rpi-update
fi

### Network Config
if [ "$cfg_network" = true ]; then
    echo "Configurando la conexión de red..."
    sudo echo "interface eth0" >> /etc/dhcpcd.conf
    sudo echo "static ip_address=$ipadress/24" >> /etc/dhcpcd.conf
    sudo echo "static routers=$gateway" >> /etc/dhcpcd.conf
    sudo echo "static domain_name_servers=$gateway 8.8.8.8" >> /etc/dhcpcd.conf
fi

### Change Timezone & Locale
if [ "$cfg_timezone" = true ]; then
    echo "Configurando la zona horaria..."
    #sudo dpkg-reconfigure tzdata
    sudo timedatectl set-timezone Europe/Madrid
    timedatectl
    echo "Configurando locales..."
    #sudo dpkg-reconfigure locales
    sudo sed -i 's/^# *\(es_ES.UTF-8\)/\1/' /etc/locale.gen && sudo locale-gen
    sudo update-locale
fi

### Installing Git & GitHub
if [ "$cfg_git" = true ]; then
    echo "Instalando Git..."
    sudo apt-get install git -y
    sudo apt-get install jq -y

    git config --global user.email $cfg_git_email
    git config --global user.name $cfg_git_name

    echo 'Generando la llava publico-privada...'
    ssh-keygen -t rsa -b 4096 -C $cfg_git_email
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    # copiar la llave pública
    clear
    cat ~/.ssh/id_rsa.pub
    read -p "Ves a https://github.com/settings/keys y copia la llave de arriba. Pulsa una tecla pra continuar"

fi

### Clone SherloScripts repo
if [ "$cfg_sherloscripts" = true ]; then
    repo=$(echo $cfg_sherloscripts_url | rev | cut -d'/' -f 1 | cut -c 5- | rev)
    echo "Instalando el repositorio $repo"
    git clone $cfg_sherloscripts_url
    cd ~/$repo
    git init

    # Inicializa el repositorio
    git add --all
    git commit -m "Inicializando..."
    git push

    # Programando la actualización diaria
    echo "@daily /SherloScripts/bash/sherloscripts_push.sh" | cat > cron
    sudo crontab -u pi cron
    rm cron

    # Haciendo ejecutables los archivos de la carpeta bash
    cd ~/SherloScripts/bash
    sudo chmod +x *.sh
fi

### Clone Sherblog repo
if [ "$cfg_sherblog" = true ]; then
    repo=$(echo $cfg_sherblog_url | rev | cut -d'/' -f 1 | cut -c 5- | rev)
    echo "Instalando el repositorio $repo"
    git clone $cfg_sherblog_url
    cd ~/$repo
    git init

    # Inicializa el repositorio
    git add --all
    git commit -m "Inicializando..."
    git push

    # Programando la actualización horaria
    echo "@hourly /SherloScripts/bash/publish.sh" | cat > cron
    sudo crontab -u pi cron
    rm cron
fi


### Installing latest version of Hugo
if [ "$cfg_hugo" = true ]; then
    echo "Instalando Hugo..."
    curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
    | grep "browser_download_url.*hugo_[^extended].*_Linux-ARM\.deb" \
    | cut -d ":" -f 2,3 \
    | tr -d \" \
    | wget -qi -
    installer="$(find . -name "*Linux-ARM.deb")"
    sudo dpkg -i $installer
    rm $installer
fi


### Installing Rclone
if [ "$cfg_rclone" = true ]; then
    echo "Instalando Rclone..."
    curl -s https://api.github.com/repositories/17803236/releases/latest \
	| grep "browser_download_url.*rclone-[^extended].*-linux-arm\.deb" \
	| cut -d ":" -f 2,3 \
	| tr -d \" \
	| wget -qi -
	installer="$(find . -name "*linux-arm.deb")"
	#sudo dpkg -i $installer
	rm $installer
    
    # Copia el archivo de configuración si hay un path
    if [ -z "$rclone_config_path" ]; then 
        echo "No se ha especificado la ruta de configuración"
    else 
        ssh $rclone_config_host        
        scp $rclone_config_path /home/pi/.config/rclone/rclone.conf
    fi
fi

### Schedule Raspberry reboot at 4 A.M.
if [ "$cfg_restart" = true ]; then
    echo "00 04 * * * /sbin/reboot" | cat > cron
    sudo crontab cron
    rm cron
fi




### Installing vpn server
#curl -L https://install.pivpn.io | bash

### Installing Pi-hole Web interface http://ip/admin
#curl -sSL https://install.pi-hole.net | bash
#sudo echo -e "$password1\n$password1" | pihole -a -p




### Raspberry Reboot
#sudo reboot
