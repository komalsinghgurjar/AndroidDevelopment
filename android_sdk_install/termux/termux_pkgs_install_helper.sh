#!/bin/bash


# Function to install and verify the package installation
install_and_verify_package() {
    local package=$1
    local attempts=0
    local max_attempts=4

    while [ $attempts -lt $max_attempts ]; do
        yes | apt install "$package" -y
        if dpkg -s "$package" >/dev/null 2>&1; then
            echo "* $package installed successfully."
            return 0
        else
            yes | apt update -y
            yes | apt upgrade -y
            yes | pkg update -y
            yes | pkg upgrade -y
            echo "* Failed to install $package. Retrying... ($((attempts + 1))/$max_attempts)"
            if [ $attempts -eq $((max_attempts - 1)) ]; then
                echo "* Executing termux-change-repo on attempt $attempts."
                termux-change-repo
                yes | apt install x11-repo
yes | apt install tur-repo
yes | apt install root-repo
yes | apt update -y
            yes | apt upgrade -y
            yes | pkg update -y
            yes | pkg upgrade -y
            fi
            attempts=$((attempts + 1))
        fi
    done

    echo "* Error: Could not install $package after $max_attempts attempts."
    return 1
}

# Function to install a list of packages passed as an argument
install() {
    local packages=("$@")
    echo "* Packages should be installed:"
for pkg in "${packages[@]}"; do
    echo "* - $pkg"
done

    for pkg in "${packages[@]}"; do
        install_and_verify_package "$pkg"
    done
}


