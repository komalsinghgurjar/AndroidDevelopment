#!/bin/bash

# Define constants
BASHRC_FILE="$HOME/.bashrc"

# Ensure .bashrc exists
if [ ! -f "$BASHRC_FILE" ]; then
    touch "$BASHRC_FILE"
    echo "Created '$BASHRC_FILE'."
fi

# Function to add or update an environment variable in .bashrc
set_env_variable() {
    local var_name="$1"
    local var_value="$2"

    if [ -z "$var_name" ] || [ -z "$var_value" ]; then
        echo "Usage: set_env_variable VAR_NAME VAR_VALUE"
        return 1
    fi

    # Remove existing entries for the variable to avoid duplicates
    remove_duplicate_entries "$var_name"

    # Add or update the environment variable
    echo "export $var_name=\"$var_value\"" >> "$BASHRC_FILE"
    echo "Added/Updated environment variable '$var_name' in '$BASHRC_FILE'."
    source "$BASHRC_FILE"
}

# Function to remove duplicate entries for a variable
remove_duplicate_entries() {
    local var_name="$1"
    if [ -n "$var_name" ]; then
        awk '!/^export '"$var_name"'=/' "$BASHRC_FILE" > "$BASHRC_FILE.tmp" && mv "$BASHRC_FILE.tmp" "$BASHRC_FILE"
        echo "Removed duplicate entries for '$var_name'."
    fi
    source "$BASHRC_FILE"
}

# Check if the script is being run directly from the command line
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check script arguments and call appropriate functions
    case "$1" in
        set_env_variable)
            set_env_variable "$2" "$3"
            ;;
        remove_duplicate_entries)
            remove_duplicate_entries "$2"
            ;;
        *)
            echo "Invalid command. Use 'set_env_variable' or 'remove_duplicate_entries'."
            ;;
    esac
else
    echo "Env Script is being sourced."
fi


# Source the updated .bashrc to apply changes
source "$BASHRC_FILE"
