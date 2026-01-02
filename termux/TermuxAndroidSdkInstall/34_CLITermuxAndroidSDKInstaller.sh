#!/data/data/com.termux/files/usr/bin/bash
termux-setup-storage
yes | apt update -y
yes | apt upgrade -y
yes | apt install wget -y
yes | apt install openjdk-17 -y
yes | apt install kotlin -y
yes | apt install gradle -y
yes | apt install aapt2
yes | apt install unzip -y


rm -rf /data/data/com.termux/files/home/AndroidSdk
wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
mkdir /data/data/com.termux/files/home/AndroidSdk
mkdir /data/data/com.termux/files/home/latest
unzip /data/data/com.termux/files/home/commandlinetools-linux*.zip -d /data/data/com.termux/files/home/AndroidSdk/
mv /data/data/com.termux/files/home/AndroidSdk/cmdline-tools/* /data/data/com.termux/files/home/latest/
mv /data/data/com.termux/files/home/latest /data/data/com.termux/files/home/AndroidSdk/cmdline-tools/



# Path to .bashrc
BASHRC_PATH="/data/data/com.termux/files/home/.bashrc"

# Marker to detect previous addition
MARKER="# === Android SDK & Java Environment ==="

# Android environment values
ANDROID_HOME="/data/data/com.termux/files/home/AndroidSdk"
JAVA_HOME="/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk"
CMDLINE_TOOLS="$ANDROID_HOME/cmdline-tools/latest/bin"
PLATFORM_TOOLS="$ANDROID_HOME/platform-tools"

# Create .bashrc if not exists
if [ ! -f "$BASHRC_PATH" ]; then
    echo "📄 Creating $BASHRC_PATH..."
    touch "$BASHRC_PATH"
fi

# Only add environment block if marker not found
if ! grep -qF "$MARKER" "$BASHRC_PATH"; then
    echo "🔧 Appending Android environment variables to .bashrc..."

    cat <<EOF >> "$BASHRC_PATH"

$MARKER
# Restore core Termux system paths first
export PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:\$PATH

export ANDROID_HOME=$ANDROID_HOME
export JAVA_HOME=$JAVA_HOME

# Safely append cmdline-tools path if not already in PATH
case ":\$PATH:" in
  *":$CMDLINE_TOOLS:"*) ;;
  *) export PATH="\$PATH:$CMDLINE_TOOLS" ;;
esac

# Safely append platform-tools path if not already in PATH
case ":\$PATH:" in
  *":$PLATFORM_TOOLS:"*) ;;
  *) export PATH="\$PATH:$PLATFORM_TOOLS" ;;
esac
# === End of Android SDK & Java Environment ===

EOF

    echo "✅ Added Android SDK paths to $BASHRC_PATH"
else
    echo "ℹ️ Environment already set — skipping."
fi

# Source .bashrc
echo "🔁 Sourcing $BASHRC_PATH..."
# No need to chmod .bashrc — it's a sourced file, not an executable
source "$BASHRC_PATH"



echo $ANDROID_HOME
echo $JAVA_HOME
echo $PATH


mkdir -p /data/data/com.termux/files/home/AndroidSdk/cmdline-tools/latest/lib
wget https://repo1.maven.org/maven2/com/google/guava/guava/27.1-jre/guava-27.1-jre.jar -O /data/data/com.termux/files/home/AndroidSdk/cmdline-tools/latest/lib/guava.jar
chmod +x /data/data/com.termux/files/home/AndroidSdk/cmdline-tools/latest/lib/guava.jar

sdkmanager
sdkmanager --sdk_root=/data/data/com.termux/files/home/AndroidSdk --update
sdkmanager --sdk_root=/data/data/com.termux/files/home/AndroidSdk --list
yes | sdkmanager --sdk_root=/data/data/com.termux/files/home/AndroidSdk --licenses
yes | sdkmanager --sdk_root=/data/data/com.termux/files/home/AndroidSdk --licenses
sdkmanager "platform-tools" "build-tools;35.0.1" "platforms;android-35"
rm -rf commandlinetools-linux*



#sdkmanager "platform-tools" "build-tools;35.0.1" "platforms;android-35"

# move to project root dir

# create local.properties file in project module of your project and add below line:
# sdk.dir=/data/data/com.termux/files/home/AndroidSdk

# add below line in gradle.properties file of your app project module
#android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2

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