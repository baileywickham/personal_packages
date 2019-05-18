#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'

plug () {
    # install vim-plug
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    }
install_nvim() {
    echo -e "${BLUE}Installing nvim$"

    plug
    git clone https://github.com/neovim/neovim.git ${HOME}/.builds
    (cd ${HOME}/.builds && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install)
}

dir() {
    mkdir -p ${HOME}/workspace/builds
    mkdir -p /etc/udev/rules.d
    mkdir -p ${HOME}/.ssh
    mkdir -p ${HOME}/.config
    mkdir -p ${HOME}/.builds
}
# Move dotfiles
replace() {
    source ./declares.sh
    for i in ${!dotFile[@]}; do
        echo "copying ${dotFile[i]}"
        yes | ln -sf "${PWD}/config/${dotFile[i]}" "${HOME}/${dotFile[i]}"
    done
    ln -sf "${PWD}/nvim" "${HOME}/.config/"
    ln -sf "${PWD}/config/.baileyShell" "${HOME}/"
}


addSSHLink() {
    if [ ! -f  "~/.ssh/config" ]
    then
        ln -s $PWD/sshconfig ~/.ssh/config
    else
        echo "SSH Config already exists"
    fi
}

add2FA() {
    echo "copying 2fa"
    cp ./files/70-u2f.rules /etc/udev/rules.d/
}

initialize() {
    # get the packages that will be used for other packages
    apt-get update -qq && apt-get install -qq -y curl \
        wget   \
        gnupg  \
        gnupg1 \
        gnupg2 \
        git \
        software-properties-common \
        python3-dev \
        python3-pip \
        cmake

    add-apt-repository -y ppa:pypa/ppa
}

main() {
    initialize
    dir
    add2FA
    replace
    addSSHLink
    install_nvim
}

if [ $# -gt 0 ] && [ $1 = "-c" ];
then
    replace
    plug
else
    main
fi
