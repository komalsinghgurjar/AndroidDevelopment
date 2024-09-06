#!/bin/bash

# Source the install_packages.sh script to use its functions
source termux_pkgs_install_helper.sh

# Define the packages you want to install
packages_to_install=(
    wget
    unzip
    openjdk-17
    kotlin
    gradle
    apksigner
    aapt2
)

# Call the install function with the packages
install "${packages_to_install[@]}"