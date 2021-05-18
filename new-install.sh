#!/usr/bin/env sh
set -euo pipefail

red="\e[0;91m"
blue="\e[0;94m"
green="\e[0;92m"
bold="\e[1m"
reset="\e[0m"

# better echo
notice() {
    echo -e "${red}[!]${reset} $1";
}
okay() {
    echo -e "[${green}OK${reset}] $1";
}
doing() {
    echo -e "${green}-${2:-""}->${reset} $1";
}
skipping() {
    echo -e "${blue}-${2:-""}->${reset} $1";
}

install() {
    doing "Checking for ${1}..."
    if ! command -v ${1} 1>/dev/null; then
        notice "'${1}' not found. Installing it now..."
        doing "Fetching ${1}..." "-"
        git clone https://github.com/$OWNER/$1 $SRC/$1
        cd $SRC/$1
        doing "Installing ${1}..." "-"
        doas make install 1>/dev/null
    else
        skipping "${1} is already installed, skipping..." "-"
    fi
    okay "Finished actions for ${1}"
    echo ""
}
package_install() {
    doing "Checking for ${1}..."
    if ! command -v ${1} 1>/dev/null; then
        if [ $TARGET == "FreeBSD" ]; then
            pkg install $1 -y
        fi
    else
        skipping "${1} is already installed, skipping..." "-"
    fi
    okay "Finished actions for ${1}"
    echo ""
}
check_folder() {
    if [ ! -d $1 ]; then
        doing "Creating ${1} folder..."
        mkdir -p $1
    else
        skipping "Folder ${1} already exists, skipping..."
    fi
}
check_folder_git() {
    doing "Checking for '$2'..."
    if [ ! -d $2 ]; then
        doing "Fetching '$2'..." "-"
        git clone $1 $2
    else
        skipping "'$2' already exists, skipping..." "-"
    fi
}
file_symlink() {
    doing "Checking file '${1}'..."
    if [ ! -x "~/."$1 ]; then
        doing "Creating symlink for '${1}'" "-"
        ln -sf ~/.dotfiles/$1 ~/.$1
    else
        skipping "File already exists, skipping..." "-"
    fi
}
folder_symlink() {
    doing "Checking folder '${1}'..."
    if [ ! -d "~/."$1 ]; then
        doing "Creating symlink for '${1}'" "-"
        ln -sf ~/.dotfiles/$1 ~/.$1
    else
        skipping "Folder already exists, skipping..." "-"
    fi
}

clear
echo "New Install POSIX Script"
echo "Get it at: https://github.com/paulo-e/new-install"
echo ""
OWNER="paulo-e"
notice "Repository owner set to ${OWNER} (https://github.com/${OWNER}/)"
SRC="$HOME/.local/src"
notice "Default source folder set to ${SRC}"
echo ""

notice "Only FreeBSD is currently supported"
if [ ! $(uname -s) == FreeBSD ]; then
    exit;
else
    notice "Running script as FreeBSD"
    TARGET=FreeBSD
fi
echo ""

# install basic graphics stuff
#doas pkg install xorg xf86-video-intel kmod-drm -y

# dotfiles
check_folder_git https://github.com/$OWNER/dotfiles ~/.dotfiles

# creates $SRC folder
check_folder $SRC

# dwm
install dwm

# tabbed
install tabbed

# surf TODO
# (most of it being handled by ports as of now)
doing "Checking for surf..."
if ! command -v surf 1>/dev/null; then
    notice "'surf' not found. Installing it now..."
    doing "Checking for portmaster..." "-"
    if ! command -v portmaster 1>/dev/null; then
        notice "'portmaster' not found. Installing it now..."
        cd /usr/ports/ports-mgmt/portmaster
        doing "Installing portmaster..." "-"
        doas make install       # delete later
    else
        skipping "'portmaster' is already installed, skipping..." "--"
    fi

    doing "Installing surf from ports..." "-"
    cd /usr/ports/www/surf
    doas portmaster         # delete later

    doing "Installing surf..." "-"
    git clone https://github.com/${OWNER}/surf ~/.local/src/surf/
else
    skipping "'surf' is already installed, skipping..." "-"
fi
okay "Finished actions for 'surf'"
echo ""

# zsh
file_symlink zshrc
folder_symlink zsh
package_install zsh

# tmux
file_symlink tmux.conf
folder_symlink tmux
check_folder_git ~/.tmux/plugins/tpm https://github.com/tmux-plugins/tmp
package_install tmux

# profiles, etc
file_symlink profile
file_symlink xprofile
file_symlink xinirc

folder_symlink local/bin
folder_symlink config

okay "Done"
