#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.
vundle () {
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    }
nvim() {
    add-apt-repository ppa:neovim-ppa/stable
    apt-get update
    apt-get install neovim
}
packages () {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |   apt-key add -

    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub |   apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' |   tee /etc/apt/sources.list.d/google-chrome.list

    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
    echo deb http://repository.spotify.com stable non-free |   tee /etc/apt/sources.list.d/spotify.list

    apt install -y software-properties-common software-properties-common python3-dev python3-pip
    add-apt-repository ppa:pypa/ppa
    apt update -qq
    apt install git  spotify-client google-chrome
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
    cp 70-u2f.rules /etc/udev/rules.d/
}

main() {
    apt update -qq && apt install -y curl wget gnupg gnupg1 gnupg2
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
