#!/usr/bin/env bash
#TODO handle errors, that would probably be good
# - add warning layer
# - copy stderror output to waring output

function help() {
    cat << EOF
personal_packages.sh a dotfiles install script
   --install : Install all features including all configs, docker, zsh, go...
   --configs : configs, Install just config files
   --minimal : minimal, Install just files needed for a server
EOF
}

if [[ $# -le 0 ]]; then
    help
    exit
fi

source utils.sh

set -uo pipefail

trap exit SIGINT

if [ "$EUID" -eq "0" ] &&  ! (grep -Fq "docker" /proc/1/cgroup) ; then
    echo "Please do not run as root"
    exit
fi

PPACKAGES=$(pwd)
BUILDS="${HOME}/builds"

function whichos() {
    awk -F= '$1=="PRETTY_NAME" { print $2 ;}' /etc/os-release | tr -d \"
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


function create_directories() {
    task "Creating directories"
    with_sudo mkdir -p /etc/udev/rules.d

    directories=(".ssh"
        ".config"
        $BUILDS
        ".emacs.d"
    )
    for d in ${directories[@]}; do
        sub_sub "creating ${d}"
        mkdir -p "${HOME}/${d}"
    done

    if [[ ! -a "${HOME}/bin" ]]; then
        sub_sub "Linking bin"
        ln -s "${PPACKAGES}/bin" "${HOME}"
    fi
}
# Move dotfiles
function move_dotfiles() {
    # Create directories
    dotFiles=(".zshrc"
        ".aliases"
        ".bashrc"
        ".vimrc"
        ".gitignore_global"
        ".gitconfig"
        ".env"
        ".tmux.conf"
        ".tmux.conf.local"
        ".p10k.zsh"
    )
    create_directories
    task "Replacing config files"
    sub "Updating env with new PPACKAGES"
    sed -i "s/PPACKAGES=/PPACKAGES=${PPACKAGES//\//\\/}/g" ./config/.env
    for i in ${!dotFiles[@]}; do
        sub "copying ${dotFiles[i]}"
        ln -sf "${PWD}/config/${dotFiles[i]}" "${HOME}/${dotFiles[i]}"
    done
    sub "copying nvim"
    ln -sf "${PWD}/config/nvim" "${HOME}/.config/"
    sub "copying emacs config"
    ln -sf "${PWD}/config/init.el" "${HOME}/.emacs.d/"
    ln -sf "${PWD}/config/init.el" "${HOME}"
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
    with_sudo cp ./files/70-u2f.rules /etc/udev/rules.d/
}

function install_packages() {
    # get the packages that will be used for other packages
    task "Initializing install"
    sub "Installing packages"
    apt_install apt-utils \
        gcc \
        build-essential \
        dialog \
        curl \
        git \
        wget   \
        software-properties-common \
        python3-dev \
        python3-pip \

        sub_sub "Update Submodules"
    git submodule init
    git submodule update
}




function main() {
    neoneofetch
    install_packages
    create_directories
    add2FA
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

function minimal() {
    local dotFiles=(".zshrc"
    ".aliases"
    ".vimrc"
    ".env")

    create_directories
    task "Replacing config files"
    sub "Updating env with new PPACKAGES"
    sed -i "s/PPACKAGES=/PPACKAGES=${PPACKAGES//\//\\/}/g" ./config/.env
    for i in ${!dotFiles[@]}; do
        sub "copying ${dotFiles[i]}"
        ln -sf "${PWD}/config/${dotFiles[i]}" "${HOME}/${dotFiles[i]}"
    done

    source modules/install_zsh.sh
    install_zsh

}

while [[ $# -gt 0 && ${1} ]]; do
    case "${1}" in
        --install)
            main
            shift
            ;;

        --configs)
            move_dotfiles
            shift
            ;;
        --neoneofetch | -n)
            neoneofetch
            shift
            ;;
        --minimal)
            minimal
            shift
            ;;

        --help | -h)
            help
            break;
            ;;
        *)
            echo "Incorrect option provided: ${1}"
            break
            ;;
    esac
done


