#!/usr/bin/env bash

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
    v yay -S --needed aylurs-gtk-shell

    # Install additional dependencies that AGS might need
    echo "Installing additional dependencies..."
    v yay -S --needed typescript npm gjs gtk3 gtk-layer-shell gnome-bluetooth-3.0 upower networkmanager gobject-introspection libdbusmenu-gtk3 libsoup3

    # Configure AGS
    echo "Configuring AGS..."
    
    # Check if the ags directory already exists
    if [ -d "$HOME/.config/ags" ]; then
        echo "Existing AGS configuration found. Creating backup..."
        v mv "$HOME/.config/ags" "$HOME/.config/backup-ags"
    fi

    # Copy the new AGS configuration
    v cp -r ".config/ags" "$HOME/.config/ags"

    if [ -d "$HOME/.config/fuzzel" ]; then
        echo "Existing AGS configuration found. Creating backup..."
        v mv "$HOME/.config/fuzzel" "$HOME/.config/backup-fuzzel"
    fi
    
    v cp -r ".config/fuzzel" "$HOME/.config/fuzzel"

    if [ -d "$HOME/.local/bin/fuzzel-emoji" ]; then
        echo "Existing AGS configuration found. Creating backup..."
        v mv "$HOME/.local/bin/fuzzel-emoji" "$HOME/.local/bin/fuzzel-emoji"
    fi
    v cp "./local/bin/fuzzel-emoji" "~/.local/bin"  
    if [ -d "$HOME/.local/bin/rubyshot" ]; then
        echo "Existing AGS configuration found. Creating backup..."
        v mv "$HOME/.local/bin/rubyshot" "$HOME/.local/bin/rubyshot"
    fi
    v cp "./local/bin/rubyshot" "~/.local/bin"

    echo "AGS installation completed!"
}

# Run the installation
install_ags

echo "You can now start AGS by running 'ags' in the terminal."

clear

echo "Only install the packages from the following options dont coppy the dot files"
echo "Only install the packages from the following options dont coppy the dot files"
echo "Only install the packages from the following options dont coppy the dot files"
echo "Only install the packages from the following options dont coppy the dot files"
echo "Only install the packages from the following options dont coppy the dot files"

clear

bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)
