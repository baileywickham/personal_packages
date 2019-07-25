#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.

trap exit SIGINT

if [ "$EUID" -e 0 ] &&  ! (grep -Fq "docker" /proc/1/cgroup) ; then
    echo "Please do not run as root"
    exit
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

function plug () {
    # install vim-plug
    echo -e "${GREEN}Installing plug${NC}"
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    }

function install_nvim() {
    echo -e "${GREEN}Installing nvim${NC}"

    sudo apt-get install -qq cmake \
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
    git clone https://github.com/neovim/neovim.git ${HOME}/.builds
    (cd ${HOME}/.builds && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install)
    pip3 install --user neovim
    nvim +PlugInstall +qa
    sudo npm i -g bash-language-server
}

function dir() {
    echo -e "${GREEN}Creating dirs${NC}"
    mkdir -p /etc/udev/rules.d
    mkdir -p ${HOME}/.ssh
    mkdir -p ${HOME}/.config
    mkdir -p ${HOME}/.builds
}
# Move dotfiles
function replace() {
    echo -e "${GREEN}Replacing config files${NC}"
    source ./declares.sh
    for i in ${!dotFile[@]}; do
        echo "copying ${dotFile[i]}"
        ln -sf "${PWD}/config/${dotFile[i]}" "${HOME}/${dotFile[i]}"
    done
    ln -sf "${PWD}/nvim" "${HOME}/.config/"
    ln -sf "${PWD}/config/.baileyShell" "${HOME}/"
    ln -sf "${PWD}/.gitignore_global" "${HOME}/"
    ln -sf "${PWD}/files/.gitignore_global" "${HOME}/"

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
    echo "copying 2fa"
    cp ./files/70-u2f.rules /etc/udev/rules.d/
}

function addKeyboard() {
    echo "copying keyboard"
    sudo cp ./files/keyboard /etc/default
}

function initialize() {
    # get the packages that will be used for other packages
    sudo apt-get update -qq && sudo apt-get install -qq curl \
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
        gnupg-agent > /dev/null

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
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update -q
    sudo apt-get install -qq docker-ce docker-ce-cli containerd.io

}

function help() {
    echo "-a : all"
    echo "-p : plug"
    echo "-d : docker"
    echo "-c : configs"

}


while getopts "adhpc:" OPT; do
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
