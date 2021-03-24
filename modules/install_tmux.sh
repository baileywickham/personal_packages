#!/bin/bash

function install_tmux() {
    task "Installing tmux"
    sub "Installing Packages"
    apt_install libncurses-dev
    install_libevent

    sub "Building tmux"
    git clone https://github.com/tmux/tmux.git "${HOME}/.builds/tmux"
    (cd "${HOME}/.builds/tmux"
    sh ./autogen.sh
    ./configure && make && sudo make install)
    apt_install zsh
}

function install_libevent() {
    git clone https://github.com/libevent/libevent.git "${HOME}/.builds/libevent"
    (cd "${HOME}/.builds/libevent"
    ./autogen.sh
    ./configure
    make
    sudo make install)
}
