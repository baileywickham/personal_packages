#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.

trap exit SIGINT

if [ "$EUID" -eq "0" ] &&  ! (grep -Fq "docker" /proc/1/cgroup) ; then
    echo "Please do not run as root"
    exit
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

function apt_install () {
    for package in "$@"
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

function plug () {
    # install vim-plug
    task "Installing plug"
    curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    }

function install_nvim() {
    task "Installing nvim"
    sub "Installing packages"

    apt_install cmake \
        pkg-config \
        libtool \
        m4 \
        unzip \
        libtool-bin \
        gettext \
        automake \
        nodejs \
        yarn \
        npm


    plug
    (git clone https://github.com/neovim/neovim.git ${HOME}/.builds) &> /dev/null
    sub "Building nvim"
    (cd ${HOME}/.builds && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install) &> /dev/null
    sub "Installing nvim sub packages"
    pip3 install --user neovim &> /dev/null
    nvim +PlugInstall +qa &> /dev/null
    sudo npm i -g bash-language-server &> /dev/null
}

function dir() {
    task "Creating directories"
    mkdir -p /etc/udev/rules.d
    mkdir -p ${HOME}/.ssh
    mkdir -p ${HOME}/.config
    mkdir -p ${HOME}/.builds
    mkdir -p ${HOME}/.config
}
# Move dotfiles
function replace() {
    # Create directories
    dir
    task "Replacing config files"
    source ./declares.sh
    for i in ${!dotFile[@]}; do
        sub "copying ${dotFile[i]}"
        ln -sf "${PWD}/config/${dotFile[i]}" "${HOME}/${dotFile[i]}"
    done
    sub "copying nvim"
    ln -sf "${PWD}/nvim" "${HOME}/.config/"

}


function addSSHLink() {
    if [ ! -f  "~/.ssh/config" ]
    then
        ln -s $PWD/sshconfig ~/.ssh/config
    else
        echo "SSH Config already exists"
    fi
}

function add2FA() {
    task "copying 2fa"
    cp ./files/70-u2f.rules /etc/udev/rules.d/
}

function addKeyboard() {
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
        gnupg-agent

    }

function main() {
    initialize
    dir
    add2FA
    replace
    addSSHLink
    install_nvim
    addKeyboard
    docker
}

function docker() {
    task "Installing docker"
    sub "Adding keys"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null
    sudo apt-get update -qq > /dev/null
    apt_install docker-ce docker-ce-cli containerd.io

}

function help() {
    echo "-a : all, Install all features including all configs, docker, zsh, go..."
    echo "-p : plug, Install plug.vim and plug.nvim"
    echo "-d : docker"
    echo "-c : configs"

}

function whichos() {
    awk -F= '$1=="PRETTY_NAME" { print $2 ;}' /etc/os-release
}



while getopts "pcadh:" OPT; do
    case "${OPT}" in
        a)
            main
            ;;
        p)
            plug
            ;;
        d)
            docker
            ;;
        c)
            replace
            ;;
        h)
            help
            ;;
        *)
            echo ${OPT}
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
