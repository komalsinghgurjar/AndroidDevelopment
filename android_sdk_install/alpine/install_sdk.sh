#!/bin/ash
echo "* BOOTSTRAPPING"
source initial_bootstrap.sh
echo "* INSTALLING SDK"
source sdk_sys_pkg_installer.sh
source sdk_installer.sh