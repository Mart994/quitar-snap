#!/bin/bash -e

# Syntax Derived from script Copyright (C) 2019 madaidan under GPL
# Snap disable forked from https://github.com/BryanDollery
# 2022 script panzerlop under GPLv3

set -eu -o pipefail # fail on error and report it, debug all lines


script_checks() {

 sudo apt-get update
 
echo ""
    if [[ "$(id -u)" -ne 0 ]]; then
      echo "Seamos SuperAdmins primero (sudo)."
      exit 1
    fi
}


disable_snap() {

read -r -p "¿Desabilitar y quitar snap del sistema? (y/n) " disable_snap
	  if [ "${disable_snap}" = "y" ]; then

echo "Deteniendo daemon..."

# Stop the daemon
sudo systemctl stop snapd && sudo systemctl disable snapd

echo "Desinstalando snapd..."
# Uninstall
sudo apt purge -y snapd
sudo apt-mark hold snapd

sudo apt autoremove -y

echo "Limpiando mugre (carpetas de snap)..."
# Tidy up dirs
rm -rf ~/snap
sudo rm -rf /root/snap
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd

echo "Ahora evitaré la reinstalación de snaps futuros..."
# Stop it from being reinstalled by 'mistake' when installing other packages
sudo cat << EOF > /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

sudo chown root:root /etc/apt/preferences.d/no-snap.pref

  fi
}


install_flatpak() {

read -r -p "¿Instalo Flatpak y agrego el repositorio de Flathub? (y/n) " install_flatpak
	  if [ "${install_flatpak}" = "y" ]; then

        sudo apt update
      
        sudo apt install flatpak -y

        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
}


install_firefox() {
echo "Existe la posibilidad de instalar Firefox de dos maneras "
echo " "
echo "1- Como flatpak desde Flathub "
echo "2- Desde repositorio PPA de Mozilla Team - https://launchpad.net/~mozillateam/+archive/ubuntu/ppa"
echo " "
read -r -p "¿Desde donde desea hacer la instalación? (1/2/n - No instalar Firefox) " option
    if [[ "${option}" == "1" ]]; then
        install_firefox_flatpak
    elif [[ "${option}" == "2" ]]; then
        install_firefox_ppa
    else
        echo "No se instalará firefox"
    fi
}


install_firefox_flatpak() {

flatpak install flathub org.mozilla.firefox

echo " To run Firefox from Terminal type the following: "
echo " "
echo " flatpak run org.mozilla.firefox "
echo " "
echo " Restart session if Firefox doesn't appear in Applications menu "
echo " "

}


install_firefox_ppa() {
echo "Agregando repositorio PPA"

    sudo add-apt-repository ppa:mozillateam/ppa -y
    sudo apt update
echo "instalando Firefox desde PPA"
    sleep 2
    sudo apt install -t 'o=LP-PPA-mozillateam' firefox -y

#evitar que se instale nuevamente snap al momento de instalar o actualizar firefox
sudo cat << EOF > /etc/apt/preferences.d/mozillateamppa.pref
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501
EOF

#sudo mv no-snap.pref /etc/apt/preferences.d/
sudo chown root:root /etc/apt/preferences.d/mozillateamppa.pref
}


#crear opcion para instalar la tienda de gnome
install_gnome_Software() {
echo "Instalando Gnome Software"
sudo apt install -y gnome-software gnome-software-plugin-flatpak
read -r -p "Instalo Synaptic?? (y/n) " r
  if [ "${r}" = "y" ]; then
    sudo apt install -y synaptic
    
  fi
}


ending() {
  ## Reboot
echo ""
echo " https://github.com/Mart994/quitar-snap"
echo ""
echo "Hemos terminado"
echo ""
echo ""
read -r -p "Es recomendable reiniciar el sistema, ¿reiniciar ahora? (y/n) " reboot
  if [ "${reboot}" = "y" ]; then
    reboot
    
  fi
}

clear
echo ""
echo "22.04 Disable Snap & Install Flatpak/PPA & Firefox Script"
echo ""
cat << "EOF"
               .-.
         .-'``(|||)
      ,`\ \    `-`.
     /   \ '``-.   `
   .-.  ,       `___:
  (:::) :        ___
   `-`  `       ,   :
     \   / ,..-`   ,
      `./ /    .-.`
         `-..-(   ) 
               `-`
EOF

echo ""
echo ""
echo "Usando este script aceptas que cualquier malfuncionamiento/ daño/ blabla/ en el sistema es tu responsabilidad"
# "By using this script you accept any break in system function/ damage / blabla is your own fault..."
echo "Si estas deacuero.."
# "So if you also agree with that you may..."
echo ""
read -r -p "...iniciar script? (y/n) " start
if [ "${start}" = "n" ]; then

echo ""

  exit 1
elif ! [ "${start}" = "y" ]; then
  echo ""
  echo "You did not enter a correct character."
  echo ""
  echo "Be careful when reading through this script..."
  exit 1
fi

disable_snap
clear
install_flatpak
clear
install_firefox
clear
install_gnome_Software
clear
ending 
