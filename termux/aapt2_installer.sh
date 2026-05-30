#!/bin/sh

## Run via:
## source setup-android-sdk.sh
## OR
## . setup-android-sdk.sh

set -e

echo "======================================"
echo " Android SDK + Custom AAPT2 Installer"
echo "======================================"

### Update packages
yes | pkg update -y
yes | pkg upgrade -y

### Required packages
yes | pkg install wget unzip curl tar -y
yes | pkg install openjdk-21 -y
yes | pkg install kotlin -y

### Storage permission
termux-setup-storage

cd ~

########################################
## Detect architecture for static aapt2
########################################

ARCH="$(uname -m)"

case "$ARCH" in
    aarch64)
        SDK_ARCH="aarch64"
        ;;
    armv7l|arm)
        SDK_ARCH="arm"
        ;;
    x86_64)
        SDK_ARCH="x86_64"
        ;;
    i686|i386)
        SDK_ARCH="i686"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected architecture: $ARCH"
echo "Using SDK tools build: $SDK_ARCH"

########################################
## Remove old SDK if exists
########################################

rm -rf AndroidSdk
rm -f commandlinetools-linux-*.zip
rm -f android-sdk-tools-static-*.zip

########################################
## Download Android commandline tools
########################################

echo "Downloading Android commandline tools..."

wget -O commandlinetools.zip \
https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip

########################################
## Setup Android SDK
########################################

mkdir -p AndroidSdk
mkdir -p latest

unzip commandlinetools.zip -d AndroidSdk/

mv AndroidSdk/cmdline-tools/* latest/
mkdir -p AndroidSdk/cmdline-tools
mv latest AndroidSdk/cmdline-tools/

########################################
## Environment variables
########################################

export ANDROID_HOME=$HOME/AndroidSdk
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-21-openjdk

export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo ""
echo "ANDROID_HOME=$ANDROID_HOME"
echo "JAVA_HOME=$JAVA_HOME"
echo ""

########################################
## Android SDK packages
########################################

sdkmanager --update

yes | sdkmanager --licenses

sdkmanager "platform-tools" \
           "platforms;android-36" \
           "build-tools;36.0.0"

########################################
## Download static aapt2
########################################

AAPT2_URL="https://github.com/lzhiyong/android-sdk-tools/releases/download/35.0.2/android-sdk-tools-static-${SDK_ARCH}.zip"

echo ""
echo "Downloading static aapt2..."
echo "$AAPT2_URL"
echo ""

wget -O android-sdk-tools-static.zip "$AAPT2_URL"

########################################
## Extract static tools
########################################

mkdir -p static-tools

unzip android-sdk-tools-static.zip -d static-tools

########################################
## Find aapt2 binary
########################################

AAPT2_PATH=$(find static-tools -type f -name aapt2 | head -n 1)

if [ -z "$AAPT2_PATH" ]; then
    echo "aapt2 binary not found!"
    exit 1
fi

echo "Found aapt2:"
echo "$AAPT2_PATH"

########################################
## Install custom aapt2
########################################

cp "$AAPT2_PATH" "$HOME/aapt2"

chmod +x "$HOME/aapt2"

echo ""
echo "Custom aapt2 installed at:"
echo "$HOME/aapt2"
echo ""

########################################
## Cleanup
########################################

rm -rf static-tools
rm -f commandlinetools.zip
rm -f android-sdk-tools-static.zip

########################################
## Final info
########################################

echo "======================================"
echo " Setup completed successfully"
echo "======================================"

echo ""
echo "Add this to local.properties:"
echo ""
echo "sdk.dir=$HOME/AndroidSdk"
echo ""

echo "Add this to gradle.properties:"
echo ""
echo "android.aapt2FromMavenOverride=$HOME/aapt2"
echo ""

echo "Example builds:"
echo ""
echo "bash gradlew assembleDebug"
echo "bash gradlew assembleRelease"
echo "bash gradlew bundleRelease"
echo ""
