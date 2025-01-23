#!/usr/bin/env bash

# Get the directory where the script is located (in case it's run from anywhere)
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Clone the Arch-Hyprland repo to the home directory
git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh

# Set error handling
set -e

# Function to execute commands verbosely
v() {
    echo "Executing: $@"
    "$@"
}

# Function to install yay if not present
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "Installing yay..."
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
}

# Main installation function
install_ags() {
    # Install yay if not present
    install_yay

    # Install AGS and its dependencies
    echo "Installing AGS and its dependencies..."
    v cd "$SCRIPT_DIR/arch-packages/illogical-impulse-ags"
    v makepkg -si 
    v cd "$SCRIPT_DIR"  # Go back to the script's directory

    # Install additional dependencies that AGS might need
    echo "Installing additional dependencies..."
    v yay -S --needed ddcutil i2c-tools typescript npm gjs gtk3 gtk-layer-shell gnome-bluetooth-3.0 upower networkmanager gobject-introspection libdbusmenu-gtk3 libsoup3

    # Configure AGS
    echo "Configuring AGS..."
    
    # Check if the ags directory already exists
    if [ -d "$HOME/.config/ags" ]; then
        echo "Existing AGS configuration found. Creating backup..."
        v mkdir "$HOME/.config/backup-ags"
        v cp -r "$HOME/.config/ags/" "$HOME/.config/backup-ags"
        v rm -rf "$HOME/.config/ags"
    fi

    # Copy the new AGS configuration
    v cp -r "$SCRIPT_DIR/.config/ags" "$HOME/.config/"

    if [ -d "$HOME/.config/fuzzel" ]; then
        echo "Existing fuzzel configuration found. Creating backup..."
        v mkdir "$HOME/.config/backup-fuzzel"
        v cp -r "$HOME/.config/fuzzel/*" "$HOME/.config/backup-fuzzel"
        v rm -rf "$HOME/.config/fuzzel"
    fi
    
    v cp -r "$SCRIPT_DIR/.config/fuzzel/" "$HOME/.config/"

    if [ -d "$HOME/.local/bin/fuzzel-emoji" ]; then
        echo "Existing fuzzel-emoji found. Creating backup..."
        v mv "$HOME/.local/bin/fuzzel-emoji" "$HOME/.local/bin/fuzzel-emoji"
    fi
    v cp "$SCRIPT_DIR/.local/bin/fuzzel-emoji" "$HOME/.local/bin"

    if [ -d "$HOME/.local/bin/rubyshot" ]; then
        echo "Existing rubyshot found. Creating backup..."
        v mv "$HOME/.local/bin/rubyshot" "$HOME/.local/bin/rubyshot"
    fi
    v cp "$SCRIPT_DIR/.local/bin/rubyshot" "$HOME/.local/bin"

    echo "AGS installation completed!"
}

# Run the installation
install_ags

echo "You can now start AGS by running 'ags' in the terminal."

clear

echo "Only install the packages from the following options, don't copy the dot files."

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)
