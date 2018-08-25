#!/bin/bash
# This whole file is a really bad idea. DO NOT copy any of this code.
packages () {
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

	echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	
	apt install software-properties-common python-software-properties python3-dev -y
	add-apt-repository ppa:pypa/ppa
}

main() {
	packages
        apt-get update
        apt-get install -y git gpp python3-pip spotify-client sublime-text discord vim vlc htop pipenv python3-dev python-dev build-essential cmake
	pip3 install pipenv

	echo "dont forget pia"
    replaceBash
    addSSHlink
}

replaceBash() {
        if [ ! -f "~/.bashrc" ]
        then
            rm ~/.bashrc
        fi 
            ln -s $PWD/bashrc ~/.bashrc
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
    cp 70-u2f.rules /etc/udev/rules.d/
}
add2FA
replaceBash
addSSHLink
packages
