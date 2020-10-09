#!/bin/bash

function install_zsh() {
    task "Installing zsh"
    sub "Installing Packages"
    apt_install zsh
    sub "Installing oh-my-zsh"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        sub_sub "oh-my-zsh already installed"
    else
        git submodule init
        sub_sub "linking oh-my-zsh"
        ln -s "${WORKDIR}/oh-my-zsh/" "${HOME}/.oh-my-zsh"
        #ln -s "${HOME}/.oh-my-zsh" "${PWD}/oh-my-zsh/"
    fi
}

