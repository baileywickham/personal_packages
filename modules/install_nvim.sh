#!/bin/bash

function plug () {
    # install vim-plug
    sub "Installing plug"
    curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    }

function bashlangserver() {
    sub_sub "Installing bash language server"
    sudo npm i -g bash-language-server &> /dev/null
}

function install_nvim() {
    task "Installing nvim"

    plug

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
        npm &> /dev/null


    (git clone https://github.com/neovim/neovim.git "${HOME}"/.builds/neovim) &> /dev/null
    sub "Building nvim"
    (cd "${HOME}/.builds/neovim" && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install) &> /dev/null
    sub "Installing nvim sub packages"
    sub_sub "Installing neovim python support"
    pip3 install --user neovim &> /dev/null
}

