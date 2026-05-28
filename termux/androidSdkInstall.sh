#!/bin/sh

## Run via source script.sh OR . script.sh

### cli android sdk installation in termux env
yes | apt update -y
yes | apt upgrade -y
yes | apt install wget -y
yes | apt install openjdk-21 -y
yes | apt install kotlin -y
#yes | apt install gradle -y
#yes | apt install aapt2
termux-setup-storage
cd ~
# To remove previously installed Android Sdk
rm -rf AndroidSdk
wget https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip
mkdir AndroidSdk
mkdir latest
unzip commandlinetools-linux-14742923_latest.zip -d AndroidSdk/
mv AndroidSdk/cmdline-tools/* latest/
mv latest AndroidSdk/cmdline-tools/
cd ~ && export ANDROID_HOME=$(pwd)/AndroidSdk
cd ~ && export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk
#cd ~ && export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk
ls $ANDROID_HOME
cd ~ && export PATH=$PATH:$(pwd)/AndroidSdk/cmdline-tools/latest/bin:$(pwd)/AndroidSdk/platform-tools
sdkmanager
sdkmanager --update
sdkmanager --list
yes | sdkmanager --licenses
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36"
sdkmanager "build-tools;36.0.0"
rm -rf commandlinetools-linux*




# move to project root dir

# create local.properties file in project module of your project and add below line:
# sdk.dir=/data/data/com.termux/files/home/AndroidSdk

# add below line in gradle.properties file of your app project module
#android.aapt2FromMavenOverride=/data/data/com.termux/files/home/aapt2
###android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2

# generate unsigned bundle .aab fike
# bash gradlew bundleRelease

# generate signed debug apk .apk
# bash gradlew assembleDebug

# generate unsigned release .apk
# bash gradlew assembleRelease

# For signing unsigned apk file
# apksigner sign --ks your_release_key.jks your_app.apk
# OR
# apksigner sign --ks your_release_key.keystore your_app.apk
