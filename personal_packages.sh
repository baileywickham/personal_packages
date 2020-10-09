#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.
#TODO handle errors, that would probably be good
# - add warning layer
# - copy stderror output to waring output

trap exit SIGINT

if [ "$EUID" -eq "0" ] &&  ! (grep -Fq "docker" /proc/1/cgroup) ; then
    echo "Please do not run as root"
    exit
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
WORKDIR=$(pwd)

function apt_install () {
    for package in $@
    do
        sub_sub "$package"
        sudo apt-get -qq install "$package" > /dev/null
    done
}

function task () {
    echo -e " ${GREEN}[*]${NC} $1"
}

function sub () {
    echo -e "   ${BLUE}[*]${NC} $1"
}
function sub_sub () {
    echo -e "      ${RED}[*]${NC} $1"
}


function dir() {
    task "Creating directories"
    if [ ! -z "$has_sudo" ];
    then
        sudo mkdir -p /etc/udev/rules.d
    fi
    mkdir -p "${HOME}"/.ssh
    mkdir -p "${HOME}"/.config
    mkdir -p "${HOME}"/.builds
    mkdir -p "${HOME}"/.emacs.d
    ln -s "${PWD}/bin/" "${HOME}"
}
# Move dotfiles
function move_dotfiles() {
    # Create directories
    dir
    task "Replacing config files"
    source ./declares.sh
    for i in ${!dotFile[@]}; do
        sub "copying ${dotFile[i]}"
        ln -sf "${PWD}/config/${dotFile[i]}" "${HOME}/${dotFile[i]}"
    done
    sub "copying nvim"
    ln -sf "${PWD}/config/nvim" "${HOME}/.config/"
    sub "copying emacs config"
    ln -sf "${PWD}/config/init.el" "${HOME}/.emacs.d/"
    sub "copying fish configs"
    ln -sf "${PWD}/config/omf" "${HOME}/.config/"
    ln -sf "${PWD}/config/fish" "${HOME}/.config/"

}


function addSSHLink() {
    if [ ! -f  "~/.ssh/config" ]
    then
        ./sshconfig/link.sh
    else
        echo "SSH Config already exists"
    fi
}

function add2FA() {
    task "copying 2fa"
    sudo cp ./files/70-u2f.rules /etc/udev/rules.d/
}

function keyboard() {
    task "copying keyboard"
    sudo cp ./files/keyboard /etc/default
}

function initialize() {
    # get the packages that will be used for other packages
    task "Initializing install"
    sub "Installing packages"
    sudo apt-get update > /dev/null
    apt_install apt-utils \
        gcc \
        build-essential \
        dialog \
        curl \
        git \
        wget   \
        gnupg  \
        gnupg1 \
        gnupg2 \
        software-properties-common \
        python3-dev \
        python3-pip \
        apt-transport-https \
        ca-certificates \
        gnupg-agent # this is bad, don't do this.

    git submodule update
}

function superuser () {
    task "Getting sudo permissions"
    sudo echo -n
    sub "sudo successful"
    has_sudo=true
}

function main() {
    neoneofetch
    superuser
    initialize
    dir
    add2FA
    keyboard
    addSSHLink
    move_dotfiles
    # This sources all files in modules
    # running the function with the filename
    # ex: in modules/test.sh, the test function will be called
    for file in modules/*.sh
    do
        source $file
        _name=${file%.*}
        #name=${x%%.*}
        name=$(basename $_name)
        eval $name
    done
}


function help() {
    printf "personal_packages.sh a dotfiles install script\n"
    printf  "\t-a : all, Install all features including all configs, docker, zsh, go...\n"
    printf  "\t-p : plug, Install plug.vim and plug.nvim\n"
    printf  "\t-c : configs, Install just config files\n"
}

function whichos() {
    awk -F= '$1=="PRETTY_NAME" { print $2 ;}' /etc/os-release
}
function whichcpu() {
    awk -F: '$1=="model name\t" {print $2;exit;}' /proc/cpuinfo
}
function whichrepo(){
    awk -F@ '"\turl = git"==$1 {print $2;exit;}' ./.git/config
}

function neoneofetch() {
    echo "----------------------------------------------------------------------------------------------------------------"
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e ""
    echo -e "     ┈┈╱▔▔▔▔▔╲┈┈      ${BLUE}User:${NC}           $(whoami)"
    echo -e "     ┈▕╋╋╋╋╋╋╋▏┈      ${BLUE}Hostname:${NC}       $(hostname)"
    echo -e "     ┈▕╳╳╳╳╳╳╳▏┈      ${BLUE}Distro:${NC}         $(whichos)"
    echo -e "     ┈┈╲╳╳╳╳╳╱┈┈      ${BLUE}Kernel:${NC}         $(uname -r)"
    echo -e "     ┈┈┈╲╋╋╋╱┈┈┈      ${BLUE}Shell:${NC}          $SHELL"
    echo -e "     ┈┈┈┈╲▂╱┈┈┈┈      ${BLUE}CPU:${NC}           $(whichcpu)"
    echo -e "     ┈┈┈┈▕▅▏┈┈┈┈      ${BLUE}Dotfiles:${NC}       $(whichrepo)"
    echo -e "   "
    echo -e ""
    echo -e "   "
    echo ""
    echo "----------------------------------------------------------------------------------------------------------------"
    echo ""

}


while getopts "pcadh:" OPT; do
    case "${OPT}" in
        a)
            main
            ;;
        c)
            move_dotfiles
            ;;
        h)
            help
            ;;
        *)
            echo "${OPT}"
            echo "Incorrect option provided"
            help
            exit 1
            ;;
    esac
done

if [[ $1 == "" ]]; then
    help
    exit
fi
