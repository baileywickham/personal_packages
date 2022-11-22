#!/bin/bash

function install_zsh() {
    task "Installing zsh"
    sub "Installing Packages"
    apt_install zsh
    sub "Installing oh-my-zsh"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        sub_sub "oh-my-zsh already installed"
    else
        sub_sub "linking oh-my-zsh"
        ln -s "${PPACKAGES}/oh-my-zsh/" "${HOME}/.oh-my-zsh"
    fi
}

