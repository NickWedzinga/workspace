#!/bin/bash

echo "Installing Homebrew..."

# Check if Homebrew is already installed
if command -v brew &>/dev/null; then
    echo "Homebrew is already installed!"
else
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if Homebrew is working
if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew installation failed!"
    exit 1
fi

echo "Homebrew installation complete!"
brew update && brew upgrade
