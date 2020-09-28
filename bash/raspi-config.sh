#!/bin/bash
# -*- ENCODING: UTF-8 -*-

###################################################################
# Script Name: raspi-config.sh
# Description: Init Raspberry after OS install
# Args: N/A
# Creation/Update: 20181106/20200928
# Author: www.sherblog.pro
# Email: sherlockes@gmail.com
# Location: github.com/sherlockes/SherloScripts/blob/master/bash/
###################################################################

# Change Pi password
cfg_pass=false
new_password="contraseña"
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
cfg_git_repos_names=('SherloScripts' 'sherlockes.github.io' 'sherblog')
# Configure Crontabs Jobs
cfg_cron=true
# Install Hugo
cfg_hugo=false
# Install Rclone
cfg_rclone=true
rclone_config_path=sherlockes@192.168.1.22:/home/sherlockes/.config/rclone/rclone.conf
# Install Pivpn server
cfg_pivpn=false
# Install Pi-Hole
cfg_pihole=false


# -------------------------------------------------------
# Change user Pi Password
# -------------------------------------------------------
if [ "$cfg_pass" = true ]; then
    echo "Cambiando la contraseña del usuario Pi..."
    sudo echo -e "raspberry\n$new_password\n$new_password" | passwd pi
fi

# -------------------------------------------------------
# Updating system
# -------------------------------------------------------
if [ "$cfg_update" = true ]; then
    echo "Actualizando el sistema..."
    sudo apt-get update
    sudo apt-get upgrade -y
fi

# -------------------------------------------------------
# Network Config
# -------------------------------------------------------
if [ "$cfg_network" = true ]; then
    echo "Configurando la conexión de red..."
    sudo echo "interface eth0" >> /etc/dhcpcd.conf
    sudo echo "static ip_address=$ipadress/24" >> /etc/dhcpcd.conf
    sudo echo "static routers=$gateway" >> /etc/dhcpcd.conf
    sudo echo "static domain_name_servers=$gateway 8.8.8.8" >> /etc/dhcpcd.conf
fi

# -------------------------------------------------------
# Change Timezone & Locale
# -------------------------------------------------------
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

# ---------------------------------------------------------
# Installing Git & GitHub Repos (also Public key)
# ---------------------------------------------------------
if [ "$cfg_git" = true ]; then
    echo "Installing Git..."
    sudo apt-get install git -y
    sudo apt-get install jq -y

    git config --global user.email $cfg_git_email
    git config --global user.name $cfg_git_name

    echo 'Generando la llave publico-privada...'
    ssh-keygen -t rsa -b 4096 -C $cfg_git_email
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    # Copy Public key to GitHub.com
    clear
    cat ~/.ssh/id_rsa.pub
    read -p "Ves a https://github.com/settings/keys y copia la llave de arriba. Pulsa una tecla pra continuar"

    # Clone & configure Github repos
    for i in "${cfg_git_repos_names[@]}"
    do
        echo "Instalando el repositorio $i"
        cd ~    
        url="git+ssh://git@github.com/$cfg_git_name/$i.git"
        git clone $url
        cd ~/$i
        git init

    done
fi

# ---------------------------------------------------------
# Configuring Crontab Jobs
# ---------------------------------------------------------
if [ "$cfg_cron" = true ]; then
    # Haciendo ejecutables los archivos de la carpeta bash
    cd ~/SherloScripts/bash
    sudo chmod +x *.sh

    # Programando la actualización diaria
    echo "@daily ~/SherloScripts/bash/sherloscripts_push.sh" | cat > cron
    echo "@daily ~/SherloScripts/bash/radares.sh" | cat >> cron
    echo "@daily ~/SherloScripts/bash/hugo.sh" | cat >> cron
    echo "@hourly ~/SherloScripts/bash/publish.sh" | cat >> cron
    sudo crontab -u pi cron
    rm cron

    echo "00 04 * * * /sbin/reboot" | cat > cron
    sudo crontab cron
    rm cron
    
    # Daily reboot al 4:00 AM
    echo "00 04 * * * /sbin/reboot" | cat > cron
    sudo crontab cron
    rm cron
fi

# ---------------------------------------------------------
# Installing latest version of Hugo
# ---------------------------------------------------------
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

# ---------------------------------------------------------
# Installing Rclone
# ---------------------------------------------------------
if [ "$cfg_rclone" = true ]; then
    echo "Instalando Rclone..."
    curl -s https://api.github.com/repositories/17803236/releases/latest \
	| grep "browser_download_url.*rclone-[^extended].*-linux-arm\.deb" \
	| cut -d ":" -f 2,3 \
	| tr -d \" \
	| wget -qi -
	installer="$(find . -name "*linux-arm.deb")"
	sudo dpkg -i $installer
	rm $installer
    
    # Copia el archivo de configuración si hay un path
    if [ -z "$rclone_config_path" ]; then 
        echo "No se ha especificado la ruta de configuración"
    else       
        scp $rclone_config_path /home/pi/.config/rclone/rclone.conf
    fi
fi

# ---------------------------------------------------------
# Installing vpn server
# ---------------------------------------------------------
if [ "$cfg_pivpn" = true ]; then
    # Para WireGuard abrir el puerto 51820 udp
    curl -L https://install.pivpn.io | bash
fi

# ---------------------------------------------------------
# Installing Pi-hole
# ---------------------------------------------------------
if [ "$cfg_pivpn" = true ]; then
    # Web interface http://ip/admin
    curl -sSL https://install.pi-hole.net | bash
fi


### Raspberry Reboot
#sudo reboot
