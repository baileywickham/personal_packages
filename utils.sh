#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
has_sudo=false


function task () {
    echo -e " ${GREEN}[*]${NC} $1"
}

function sub () {
    echo -e "   ${BLUE}[*]${NC} $1"
}
function sub_sub () {
    echo -e "      ${RED}[*]${NC} $1"
}
function err () {
    echo -e " ${ORANGE}[x] $1 ${NC}"
}


function with_sudo () {
    if [ -z "$has_sudo" ]; then
        get_sudo_permissions
    fi
    sudo "$@"
}

function apt_install () {
    sub "Installing packages with APT"
    if [ -z "$apt_updated" ]; then
        apt_update
    fi

    for package in $@
    do
        sub_sub "$package"
        DEBIAN_FRONTEND=noninteractive
        with_sudo -E apt-get -qqq install -y "$package" > /dev/null
    done
}

function apt_update () {
    sub "Updating APT"
    with_sudo apt-get update -qq
    apt_updated=true
}


function get_sudo_permissions () {
    task "Getting sudo permissions"
    sudo echo -n
    sub "sudo successful"
    has_sudo=true
}

