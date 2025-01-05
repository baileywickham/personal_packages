#!/usr/bin/env bash

set -euo pipefail

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

function help() {
    cat << EOF
personal_packages.sh a dotfiles install script
   --install : Install all features including all configs, docker, zsh, go...
   --configs : configs, Install just config files
EOF
}

if [[ $# -le 0 ]]; then
    help
    exit
fi

source utils.sh


trap exit SIGINT

if [ "$EUID" -eq "0" ] &&  ! (grep -Fq "docker" /proc/1/cgroup) ; then
    echo "Please do not run as root"
    exit
fi

PPACKAGES=$(pwd)
BUILDS="${HOME}/builds"

function setupMac() {
    chflags nohidden ~/Library
    # show hidden files
    defaults write com.apple.finder AppleShowAllFiles YES

    # add pathbar to title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # restart finder
    killall Finder;
}

function whichos() {
    awk -F= '$1=="PRETTY_NAME" { print $2 ;}' /etc/os-release | tr -d \"
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
    echo -e "     ┈▕╳╳╳╳╳╳╳▏┈      ${BLUE}Distro:${NC}         ${MACHINE}"
    echo -e "     ┈┈╲╳╳╳╳╳╱┈┈      ${BLUE}Kernel:${NC}         $(uname -r)"
    echo -e "     ┈┈┈╲╋╋╋╱┈┈┈      ${BLUE}Shell:${NC}          $SHELL"
    echo -e "     ┈┈┈┈╲▂╱┈┈┈┈      ${BLUE}CPU:${NC}            "
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
    # sed -i "s/PPACKAGES=/PPACKAGES=${PPACKAGES//\//\\/}/g" ./config/.env
    for i in ${!dotFiles[@]}; do
        sub "copying ${dotFiles[i]}"
        ln -sf "${PWD}/config/${dotFiles[i]}" "${HOME}/${dotFiles[i]}"
    done
    sub "copying nvim"
    ln -sf "${PWD}/config/nvim" "${HOME}/.config/"
    sub "copying emacs config"
    # ln -sf "${PWD}/config/init.el" "${HOME}/.emacs.d/"
    # ln -sf "${PWD}/config/init.el" "${HOME}"

}


function addSSHLink() {
    if [ ! -f  "~/.ssh/config" ]
    then
        ./sshconfig/link.sh
    else
        echo "SSH Config already exists"
    fi
}

function install_packages_linux() {
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
}

function install_packages_osx() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install fzf fd ripgrep gnu-sed autojump direnv
}

function install_omz() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function main() {
    git submodule init
    git submodule update
    neoneofetch
    create_directories
    if [[ $MACHINE == "Linux" ]]; then
        install_packages_linux
    elif [[ $MACHINE == "Mac" ]]; then
        install_packages_osx
    fi
    addSSHLink
    move_dotfiles
    # This sources all files in modules
    # running the function with the filename
    # ex: in modules/test.sh, the test function will be called
    # this must be done because we only have a global scope, so we can't just use main
    # for file in modules/*.sh
    # do
    #     source $file
    #     _name=${file%.*}
    #     #name=${x%%.*}
    #     name=$(basename $_name)
    #     eval $name
    # done
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


