#!/bin/bash

# Define constants with uppercase letters
SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
#testSDK_URL="https://github.com/komalsinghgurjar/Klooni1010/archive/refs/heads/master.zip"

SDK_ZIP_FILENAME="${SDK_URL##*/}"
SDK_CHECKSUM_FILENAME="${SDK_ZIP_FILENAME}.sha256"
SDK_ZIP_FILE_PATH="$HOME/$SDK_ZIP_FILENAME"
SDK_CHECKSUM_FILE_PATH="$HOME/$SDK_CHECKSUM_FILENAME"
SDK_VERSION=$(echo "$SDK_ZIP_FILENAME" | grep -oP '\d+')
ANDROID_SDK_DIR_NAME="android-sdk-$SDK_VERSION"
ANDROID_SDK_DIR="$HOME/$ANDROID_SDK_DIR_NAME"

SETUP_COMPLETE_STATUS_FILE="$ANDROID_SDK_DIR/setup_complete.txt"
MAX_RETRIES=2
RETRY_COUNT=0

# Extract numerical part from the filename
SDK_VERSION=$(echo "$SDK_ZIP_FILENAME" | grep -oP '\d+')

# Check if the Android SDK directory exists
if [ -d "$ANDROID_SDK_DIR" ]; then
    ANDROID_SDK_DIR_EXIST=true
    echo "SDK directory '$ANDROID_SDK_DIR' exist."
else
    ANDROID_SDK_DIR_EXIST=false
    echo "SDK directory '$ANDROID_SDK_DIR' not exist."
fi


# Function to download the SDK command line tools ZIP and checksum
download_sdk_cmdline_tools_zip_if_needed() {
    if [ -f "$SDK_ZIP_FILE_PATH" ]; then
        echo "File '$SDK_ZIP_FILENAME' already exists."
        if [ -f "$SDK_CHECKSUM_FILE_PATH" ]; then
            echo "Checksum file '$SDK_CHECKSUM_FILENAME' exists."
            # Verify the checksum
            local CHECKSUM=$(sha256sum "$SDK_ZIP_FILE_PATH" | awk '{ print $1 }')
            local EXPECTED_CHECKSUM=$(cat "$SDK_CHECKSUM_FILE_PATH")
            if [ "$CHECKSUM" = "$EXPECTED_CHECKSUM" ]; then
                echo "Checksum is correct. File is valid."
                SDK_ZIP_FILE_EXIST=true
                return
            else
                echo "Checksum verification failed. Removing corrupted file..."
                rm -f "$SDK_ZIP_FILE_PATH" "$SDK_CHECKSUM_FILE_PATH"
            fi
        else
            echo "Checksum file '$SDK_CHECKSUM_FILENAME' is missing."
        fi
    fi

    # Retry download up to MAX_RETRIES times
    while [ "$RETRY_COUNT" -le "$MAX_RETRIES" ]; do
        wget "$SDK_URL" -O "$SDK_ZIP_FILE_PATH"
        if [ $? -eq 0 ]; then
            echo "Downloaded '$SDK_ZIP_FILENAME'."
            # Generate checksum for the downloaded file
            sha256sum "$SDK_ZIP_FILE_PATH" | awk '{ print $1 }' > "$SDK_CHECKSUM_FILE_PATH"
            echo "Generated checksum file '$SDK_CHECKSUM_FILENAME'."
            SDK_ZIP_FILE_EXIST=true
            return
        else
            echo "Failed to download '$SDK_ZIP_FILENAME'. Retrying..."
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
    done

    echo "Failed to download '$SDK_ZIP_FILENAME' after $MAX_RETRIES attempts."
    exit 1
}



# Function to set up the Android SDK directory
setup_android_sdk_dir() {
    if [ "$ANDROID_SDK_DIR_EXIST" = false ]; then
        rm -rf "$ANDROID_SDK_DIR"
        mkdir -p "$ANDROID_SDK_DIR"
        echo "Directory '$ANDROID_SDK_DIR' created."
        
        

        if [ "$SDK_ZIP_FILE_EXIST" = true ]; then
            unzip "$SDK_ZIP_FILE_PATH" -d "$ANDROID_SDK_DIR/"
            echo "Unzipped '$SDK_ZIP_FILENAME' into '$ANDROID_SDK_DIR'."
            echo "Listing $ANDROID_SDK_DIR/cmdline-tools/bin"
            ls "$ANDROID_SDK_DIR/cmdline-tools/bin"
            
            add_latest_version_dir_to_sdk_cmdline-tools
            ## not needed because no build tool folder comes in zip
            ##add_latest_version_dir_to_sdk_build-tools
            echo "Restructured the sdk"
            
            chmod +x "$ANDROID_SDK_DIR/cmdline-tools/latest/bin/"*
            echo "Listing $ANDROID_SDK_DIR/cmdline-tools/latest/bin"
            ls "$ANDROID_SDK_DIR/cmdline-tools/latest/bin"
            
        else
            echo "Cannot unzip. File '$SDK_ZIP_FILENAME' does not exist."
            exit 1
        fi
    else
        if [ -f "$SETUP_COMPLETE_STATUS_FILE" ]; then
            echo "Setup already complete. Status file found at '$SETUP_COMPLETE_STATUS_FILE'."
        else
            echo "Directory '$ANDROID_SDK_DIR' already exists from old setup but setup incomplete! Removing and restarting..."
            rm -rf "$ANDROID_SDK_DIR"
            setup_android_sdk_dir
        fi
    fi
}


add_latest_version_dir_to_sdk_cmdline-tools(){
mkdir "$ANDROID_SDK_DIR/cmdline-tools/latest/"
for item in "$ANDROID_SDK_DIR/cmdline-tools/"*; do
  if [ "$(basename "$item")" != "latest" ]; then
    mv "$item" "$ANDROID_SDK_DIR/cmdline-tools/latest/"
  fi
done
}

#add_latest_version_dir_to_sdk_build-tools(){
#mkdir "$ANDROID_SDK_DIR/build-tools/latest/"
#for item in "$ANDROID_SDK_DIR/build-tools/"*; do
#  if [ "$(basename "$item")" != "latest" ]; then
#    mv "$item" "$ANDROID_SDK_DIR/build-tools/latest/"
#  fi
#done
#}




### Setting Environment Variable Section

# Get the current directory
    CURRENT_DIR=$(pwd)

    # Source the set_env.sh script from the current directory
    source "$CURRENT_DIR/set_termux_env_var.sh"


# Function to set ANDROID_HOME environment variable
set_android_home_env_var() {
    
    # Set the ANDROID_HOME environment variable
    echo "Setting up ANDROID_HOME environment variable..."
    set_env_variable "ANDROID_HOME" "$ANDROID_SDK_DIR"

    # Verify if ANDROID_HOME is set
    if [ -z "$ANDROID_HOME" ]; then
        echo "Error: ANDROID_HOME environment variable is not set."
        return 1
    fi

    # Optionally, check the updated .bashrc
    echo ".bashrc content during HOME env var:"
    cat "$HOME/.bashrc"

    # Verify the ANDROID_HOME directory
    echo "ANDROID_HOME env var set: $ANDROID_HOME"
    if [ ! -d "$ANDROID_HOME" ]; then
        echo "Error: ANDROID_HOME directory does not exist."
        return 1
    fi

    echo "Listing ANDROID_HOME directory contents:"
    ls "$ANDROID_HOME"

    echo "ANDROID_HOME environment variable set successfully."
    return 0
}


# Function to set PATH environment variable for Android SDK tools
set_android_sdk_path_env_var() {

    # Define the paths to add based on the current ANDROID_HOME
    CMDLINE_TOOLS_PATH="$ANDROID_HOME/cmdline-tools/latest/bin"
    ##PLATFORM_TOOLS_PATH="$ANDROID_HOME/platform-tools/latest"

    # Remove any entries in PATH that contain cmdline-tools/latest/bin or platform-tools/latest
    ##PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "cmdline-tools/latest/bin" | grep -v "platform-tools/latest" | tr '\n' ':')
    # Remove any entries in PATH that contain cmdline-tools/latest/bin
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "cmdline-tools/latest/bin" | tr '\n' ':')


    # Add new paths if not already in PATH
    if ! echo "$PATH" | grep -q "$CMDLINE_TOOLS_PATH"; then
        echo "Adding $CMDLINE_TOOLS_PATH to PATH."
        PATH="$PATH:$CMDLINE_TOOLS_PATH"
    fi

    ##if ! echo "$PATH" | grep -q "$PLATFORM_TOOLS_PATH"; then
        ##echo "Adding $PLATFORM_TOOLS_PATH to PATH."
        ##PATH="$PATH:$PLATFORM_TOOLS_PATH"
   ## fi

    # Remove any trailing colon and adjacent double colons from PATH
    PATH=$(echo "$PATH" | sed 's/:$//' | sed 's/::/:/g')

    # Prepare the new PATH export line for .bashrc
    BASHRC_ENTRY="export PATH=$PATH"

# Remove all PATH entries in .bashrc
sed -i '/^export PATH=/d' "$HOME/.bashrc"
 ##sed -i '/^export PATH=.*platform-tools\/latest/d' "$HOME/.bashrc"

    # Append the new PATH export line to .bashrc
    echo "$BASHRC_ENTRY" >> "$HOME/.bashrc"

    # Source the updated .bashrc to set the new PATH for the current session
    source "$HOME/.bashrc"

    # Verify if PATH is updated correctly
    ##if ! echo "$PATH" | grep -q "$CMDLINE_TOOLS_PATH" || ! echo "$PATH" | grep -q "$PLATFORM_TOOLS_PATH"; then
        ##echo "Error: PATH environment variable was not updated correctly."
        ##return 1
   ## fi
# Verify if PATH is updated correctly
if ! echo "$PATH" | grep -q "$CMDLINE_TOOLS_PATH"; then
    echo "Error: PATH environment variable was not updated correctly."
    return 1
fi

    echo "PATH environment variable updated successfully."
    return 0
}









bootstrap_sdkmanager(){
sdkmanager
yes | sdkmanager --update
yes | sdkmanager --list
yes | sdkmanager --licenses
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34"
sdkmanager "build-tools;34.0.0"
}

clean_clutter(){
#rm -rf commandlinetools-linux*
echo " "
}

add_setup_completed_status_file(){
# Create a setup complete status file
            touch "$SETUP_COMPLETE_STATUS_FILE"
            echo "Status file created at '$SETUP_COMPLETE_STATUS_FILE'."
}


setup_android_sdk(){
# Execute the functions
download_sdk_cmdline_tools_zip_if_needed
setup_android_sdk_dir
## env var execution
set_android_home_env_var
set_android_sdk_path_env_var

#starting sdkmanager
bootstrap_sdkmanager
add_setup_completed_status_file
# Clean method
clean_clutter
echo "SDK INSTALLED SUCCESSFULLY"
}




#export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk
#export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

#Running script
setup_android_sdk




