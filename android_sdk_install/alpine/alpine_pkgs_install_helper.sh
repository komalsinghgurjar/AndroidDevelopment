#!/bin/ash

# Function to install and verify the package installation
install_and_verify_package() {
    local package=$1
    local attempts=0
    local max_attempts=4

    while [ $attempts -lt $max_attempts ]; do
        yes | apk add "$package"
        if apk info "$package" >/dev/null 2>&1; then
            echo "* $package installed successfully."
            return 0
        else
            echo "* Failed to install $package. Retrying... ($((attempts + 1))/$max_attempts)"
            if [ $attempts -eq $((max_attempts - 1)) ]; then
                echo "* Executing additional steps on final attempt."
                yes | apk update
                yes | apk upgrade
            fi
            attempts=$((attempts + 1))
        fi
    done

    echo "* Error: Could not install $package after $max_attempts attempts."
    return 1
}

# Function to install a list of packages passed as arguments
install() {
    local packages="$*"
    echo "* Packages to be installed:"
    for pkg in "${packages[@]}"; do
        echo "* - $pkg"
    done

    for pkg in "${packages[@]}"; do
        install_and_verify_package "$pkg"
    done
}
