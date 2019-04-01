#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.
plug () {
    # install vim-plug
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    }
nvim() {
    add-apt-repository ppa:neovim-ppa/stable
    apt-get update
    apt-get install neovim
}
packages () {
    apt install -y software-properties-common software-properties-common python3-dev python3-pip
    add-apt-repository ppa:pypa/ppa
    apt update -qq
}

dir() {
    mkdir -p ${HOME}/workspace/builds
    mkdir -p ${HOME}/.config/nvim
}
# Move dotfiles
replace() {
    source ./declares.sh
    for i in ${!dotFile[@]}; do
        echo "copying ${dotFile[i]}"
        yes | ln -sf "${PWD}/config/${dotFile[i]}" "${HOME}/${dotFile[i]}"
    done
    ln -sf "${PWD}/config/init.vim" "${HOME}/.config/nvim/"
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
    apt update -qq && apt install -y curl
    \ wget
    \ gnupg
    \ gnupg1
    \ gnupg2
    \ git
}

main() {
    packages
    dir
    add2FA
    replace
    addSSHLink
}

if [ $# -gt 0 ] && [ $1 = "-c" ];
then
    replace
else
    main
fi
