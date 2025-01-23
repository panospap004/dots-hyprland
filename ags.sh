#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"

# Define helper functions
v() {
    echo "Executing: $@"
    "$@"
}

showfun() {
    echo "Function to be executed: $1"
}

install-yay() {
    echo "Installing yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
}

prevent_sudo_or_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script should not be run as root or with sudo. Aborting."
        exit 1
    fi
}

#####################################################################################
if ! command -v pacman >/dev/null 2>&1; then 
  printf "\e[31m[$0]: pacman not found, it seems that the system is not ArchLinux or Arch-based distros. Aborting...\e[0m\n"
  exit 1
fi
prevent_sudo_or_root

startask () {
  printf "\e[34m[$0]: Hi there! This script will install AGS (Advanced GNOME Shell) and its dependencies.\n"
  printf "\e[31m"
  
  printf '\n'
  printf 'Do you want to confirm every time before a command executes?\n'
  printf '  y = Yes, ask me before executing each of them. (DEFAULT)\n'
  printf '  n = No, just execute them automatically.\n'
  printf '  a = Abort.\n'
  read -p "====> " p
  case $p in
    n) ask=false ;;
    a) exit 1 ;;
    *) ask=true ;;
  esac
}

startask

set -e
#####################################################################################
printf "\e[36m[$0]: 1. Installing AGS and its dependencies\n\e[0m"

# Use yay for AUR packages
if ! command -v yay >/dev/null 2>&1;then
  echo -e "\e[33m[$0]: \"yay\" not found.\e[0m"
  showfun install-yay
  v install-yay
fi

# Install AGS meta-package
metapkg="./arch-packages/illogical-impulse-ags"
metainstallflags="--needed"
$ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
v yay -S $metainstallflags $metapkg

#####################################################################################
printf "\e[36m[$0]: 2. Configuring AGS\n\e[0m"

# Create necessary directories
v mkdir -p $XDG_CONFIG_HOME

# Copy AGS configuration
v rsync -av --delete --exclude '/user_options.js' .config/ags/ "$XDG_CONFIG_HOME"/ags/
t="$XDG_CONFIG_HOME/ags/user_options.js"
if [ -f $t ]; then
  echo -e "\e[34m[$0]: \"$t\" already exists.\e[0m"
  existed_ags_opt=y
else
  echo -e "\e[33m[$0]: \"$t\" does not exist yet.\e[0m"
  v cp .config/ags/user_options.js $t
  existed_ags_opt=n
fi

#####################################################################################
printf "\e[36m[$0]: Finished installing and configuring AGS.\e[0m\n"
printf "\n"
printf "\e[36mTo start AGS, you can run 'ags' from the command line.\e[0m\n"
printf "\n"

case $existed_ags_opt in
  y) printf "\n\e[33m[$0]: Note: \"$XDG_CONFIG_HOME/ags/user_options.js\" already existed before and we didn't overwrite it. \e[0m\n"
     printf "\e[33mYou may want to review and update it manually if necessary.\e[0m\n"
;;
esac
