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

repo="mylinuxforwork/dotfiles"

# Get latest tag from GitHub
get_latest_release() {
  curl --silent "https://api.github.com/repos/$repo/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# Check if package is installed
_isInstalled() {
    package="$1";
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ; then
        echo 0; #'0' means 'true' in Bash
        return; #true
    fi;
    echo 1; #'1' means 'false' in Bash
    return; #false
}

# Install required packages
_installPackages() {
    toInstall=();
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed.";
            continue;
        fi;
        toInstall+=("${pkg}");
    done;
    if [[ "${toInstall[@]}" == "" ]]; then
        return;
    fi;
    printf "Package not installed:\n%s\n" "${toInstall[@]}";
    sudo pacman --noconfirm -S "${toInstall[@]}";
}

# install yay if needed
_installYay() {
    _installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay.git ~/Downloads/yay
    cd ~/Downloads/yay
    makepkg -si
    cd $temp_path
}

# Required packages for the installer
packages=(
    "wget"
    "unzip"
    "gum"
    "rsync"
    "git"
)

latest_version=$(get_latest_release)

# Some colors
GREEN='\033[0;32m'
NONE='\033[0m'

# Header
echo -e "${GREEN}"
cat <<"EOF"
   ____         __       ____       
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/   
                                    
EOF
echo "ML4W Dotfiles for Hyprland"
echo -e "${NONE}"

# Start installation prompt
while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo ":: Installation started."
            break;;
        [Nn]* ) 
            echo ":: Installation canceled"
            exit;
        break;;
        * ) 
            echo ":: Please answer yes or no."
        ;;
    esac
done

# Create Downloads folder if not exists
if [ ! -d ~/Downloads ]; then
    mkdir ~/Downloads
    echo ":: Downloads folder created"
fi 

# Synchronizing package databases
sudo pacman -Sy
echo

# Install required packages
echo ":: Checking that required packages are installed..."
_installPackages "${packages[@]}";

# Install yay if needed
if _checkCommandExists "yay"; then
    echo ":: yay is already installed"
else
    echo ":: The installer requires yay. yay will be installed now"
    _installYay
fi
echo

# Select the dotfiles version
echo "Please choose between: "
echo "- ML4W Dotfiles for Hyprland $latest_version (latest stable release)"
echo "- ML4W Dotfiles for Hyprland Rolling Release (main branch including the latest commits)"
echo
version=$(gum choose "main-release" "rolling-release" "CANCEL")
if [ "$version" == "main-release" ]; then
    echo ":: Installing Main Release"
    yay -S --noconfirm ml4w-hyprland
elif [ "$version" == "rolling-release" ]; then
    echo ":: Installing Rolling Release"
    yay -S ml4w-hyprland-git
elif [ "$version" == "CANCEL" ]; then
    echo ":: Setup canceled"
    exit 130    
else
    echo ":: Setup canceled"
    exit 130
fi

echo ":: Main package (ml4w-hyprland) installed."

# Now, run the setup script that configures everything (including extra packages)
echo ":: Running setup for extra packages (SDDM theme, wallpapers, etc.)"
ml4w-hyprland-setup

echo ":: Installation complete."
