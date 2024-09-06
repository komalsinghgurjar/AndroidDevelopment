#!/bin/bash
yes | termux-setup-storage
yes | apt update -y
yes | apt upgrade -y


#yes | apt install x11-repo
#yes | apt install tur-repo
#yes | apt install root-repo




# Source the install_packages.sh script to use its functions
source termux_pkgs_install_helper.sh

# Define the packages you want to install
packages_to_install=(
tur-repo
x11-repo
    root-repo
)

# Call the install function with the packages
install "${packages_to_install[@]}"
