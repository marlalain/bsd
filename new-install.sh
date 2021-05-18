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
        skipping "${1} is already installed, skipping..."
    fi
    okay "Finished actions for ${1}"
    echo ""
}

echo "New Install Script"
echo "Get it at: https://github.com/paulo-e/new-install"
echo ""
notice "Only FreeBSD is currently supported"
notice "Running FreeBSD script"
OWNER="paulo-e"
notice "Repository owner set to ${OWNER} (https://github.com/${OWNER}/)"
SRC="$HOME/.local/src"
notice "Default source folder set to ${SRC}"
echo ""

# install basic graphics stuff
#doas pkg install xorg xf86-video-intel kmod-drm -y

# creates $SRC folder
[ ! -d $SRC ] && doing "Creating ${SRC} folder..." && mkdir -p $SRC
[ -d $SRC ] && skipping "${SRC} already exists, skipping..."
echo ""

# dwm
# doing "Checking for dwm..."
# if ! command -v dwm &> /dev/null; then
#     doing "Fetching dwm..." "-"
#     git clone https:/github.com/${OWNER}/dwm ~/.local/src/dwm
#     cd $SRC/dwm
#     doing "Installing dwm..." "-"
#     doas make install 1>/dev/null
# fi
install dwm

# tabbed
install tabbed

# surf TODO
# (most of it being handled by ports as of now)
doing "Checking for surf..."
if ! command -v surf 1>/dev/null; then
    notice "'surf' not found. Installing it now..."
    doing "Checking for portmaster..."
    if ! command -v portmaster 1>/dev/null; then
        notice "'portmaster' not found. Installing it now..."
        cd /usr/ports/ports-mgmt/portmaster
        doing "Installing portmaster..." "-"
        doas make install       # delete later
    else
        skipping "'portmaster' is already installed, skipping..."
    fi

    doing "Installing surf from ports..." "-"
    cd /usr/ports/www/surf
    doas portmaster         # delete later

    doing "Installing surf..." "-"
    git clone https://github.com/${OWNER}/surf ~/.local/src/surf/
fi
