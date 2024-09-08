#!/bin/ash

# Define constants
PROFILE_FILE="$HOME/.profile"

# Ensure .profile exists
if [ ! -f "$PROFILE_FILE" ]; then
    touch "$PROFILE_FILE"
    echo "* Created '$PROFILE_FILE'."
fi

# Function to add or update an environment variable in .profile
set_env_variable() {
    local var_name="$1"
    local var_value="$2"

    if [ -z "$var_name" ] || [ -z "$var_value" ]; then
        echo "* Usage: set_env_variable VAR_NAME VAR_VALUE"
        return 1
    fi

    # Remove existing entries for the variable to avoid duplicates
    awk '!/^export '"$var_name"'=/' "$PROFILE_FILE" > "$PROFILE_FILE.tmp" && mv "$PROFILE_FILE.tmp" "$PROFILE_FILE"
    
    # Add or update the environment variable
    echo "export $var_name=\"$var_value\"" >> "$PROFILE_FILE"
    echo "* Added/Updated environment variable '$var_name' in '$PROFILE_FILE'."
    source "$PROFILE_FILE"
}
