#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.
packages () {
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

	echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	
	apt install -y software-properties-common python-software-properties python3-dev python3-pip 
	add-apt-repository ppa:pypa/ppa
    apt update
    apt install git  spotify-client google-chrome
}

main() {
    packages
    dir
    add2FA
    replace
    addSSHlink
}

dir() {
    mkdir -p ${HOME}/workspace/builds
    mkdir -p ${HOME}/.config/nvim
}
# Move
replace() {
    source ./declares.sh
    for i in ${!dotFile[@]}; do
        echo "copying " 
        yes | ln -sf "../config/${dotFile[i]}" "${HOME}/.${dotFile[i]}"
    done
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
add2FA
replaceBash
addSSHLink
packages
