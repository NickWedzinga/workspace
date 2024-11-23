#!/bin/bash

# Main setup script
SCRIPT_DIR="$(cd "$(dirname "$0")/scripts" && pwd)"
SCRIPT_LIST_FILE="$(cd "$(dirname "$0")" && pwd)/script-list.txt"

display_help() {
    echo "Usage: ./setup.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  help       Show this help message and list available scripts"
    echo "  all        Run all scripts in the order listed in script-list.txt"
    while IFS= read -r line || [ -n "$line" ]; do
        # Ignore empty lines and comments
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        script_name=$(echo "$line" | cut -d':' -f1)
        script_desc=$(echo "$line" | cut -d':' -f2-)
        echo "  $script_name: $script_desc"
    done < "$SCRIPT_LIST_FILE"
}

run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"

    if [ -f "$script_path" ]; then
        echo "Running script: $script_name"
        chmod +x "$script_path"
        "$script_path"
    else
        echo "Script not found: $script_name"
    fi
}

run_all() {
    echo "Running all scripts in order..."
    while IFS= read -r line || [ -n "$line" ]; do
        # Ignore empty lines and comments
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        script_name=$(echo "$line" | cut -d':' -f1)
        run_script "$script_name"
    done < "$SCRIPT_LIST_FILE"
    echo "All scripts executed successfully!"
}

if [ ! -f "$SCRIPT_LIST_FILE" ]; then
    echo "Error: script-list.txt not found!"
    exit 1
fi

validate_scripts() {
    local missing_scripts=0

    for script_file in "$SCRIPT_DIR"/*.sh; do
        script_name=$(basename "$script_file")
        if ! grep -q "^$script_name:" "$SCRIPT_LIST_FILE"; then
            echo "Error: Script '$script_name' is not listed in script-list.txt."
            missing_scripts=1
        fi
    done

    if [ "$missing_scripts" -eq 1 ]; then
        echo "Please add all missing scripts to script-list.txt before running the setup."
        exit 1
    fi
}

validate_scripts

if [ "$#" -eq 0 ]; then
    display_help
    exit 0
fi

case "$1" in
    help)
        display_help
        ;;
    all)
        run_all
        ;;
    *)
        run_script "$1"
        ;;
esac
