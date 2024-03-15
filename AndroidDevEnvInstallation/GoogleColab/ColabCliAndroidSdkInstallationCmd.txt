### cli sdk installation in colab env
cd /content
!apt update
!apt upgrade
!wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
!mkdir Android
!unzip commandlinetools-linux-11076708_latest.zip -d Android/
ls Android/cmdline-tools
mkdir latest
!mv Android/cmdline-tools/* latest/
!mv latest Android/cmdline-tools/
!apt install openjdk-21-jdk-headless
!apt install openjdk-21-jre-headless
!apt install kotlin
!apt install gradle
!apt install git
ls Android/cmdline-tools/latest/bin
%env ANDROID_HOME=/content/Android
!echo $ANDROID_HOME
%env PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/content/Android/cmdline-tools/latest/bin:/content/Android/platform-tools
!sdkmanager
!sdkmanager --update
!sdkmanager --list
!yes | sdkmanager --licenses
!yes | sdkmanager --licenses
!sdkmanager "platform-tools" "platforms;android-34"
!sdkmanager "build-tools;34.0.0"


#### Cloning the demo project
!git clone https://github.com/FossifyOrg/Music-Player.git
cd Music-Player


### generating debug version of apk
!bash gradlew assembleDebug
cd /content/Music-Player/app/build/outputs/apk/core/debug
from google.colab import files
files.download('musicplayer-1-core-debug.apk')

### generating release version of apk
!bash gradlew assembleRelease
cd /content/Music-Player/app/build/outputs/apk/core/release
from google.colab import files
files.download('musicplayer-1-core-release-unsigned.apk')


### generating bundle .aab file pkg
!bash gradlew bundleRelease