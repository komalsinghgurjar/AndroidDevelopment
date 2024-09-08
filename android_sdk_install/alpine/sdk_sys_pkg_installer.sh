#!/bin/ash

# Source the install_packages.sh script to use its functions
source alpine_pkgs_install_helper.sh

# Define the packages you want to install
packages_to_install=(
    wget
    unzip
    openjdk21-jdk
    kotlin
    gradle
)

# Call the install function with the packages
install "${packages_to_install[@]}"