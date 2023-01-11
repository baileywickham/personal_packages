#!/bin/bash

function install_tmux() {
    task "Installing tmux"
    sub "Installing Packages"
    apt_install libncurses-dev
    install_libevent

    sub "Building tmux"
    git clone https://github.com/tmux/tmux.git "${BUILDS}/tmux"
    (cd "${BUILDS}/tmux"
    sh ./autogen.sh
    ./configure && make && sudo make install) &>/dev/null
}

function install_libevent() {
    git clone https://github.com/libevent/libevent.git "${BUILDS}/libevent"
    (cd "${BUILDS}/libevent"
    ./autogen.sh
    ./configure
    make
    sudo make install) &> /dev/null
}
