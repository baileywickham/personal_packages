function install_docker() {
    task "Installing docker"
    if command -v docker > /dev/null;
    then
        sub "Docker already installed";
    else
        sub "Adding keys"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null
        sudo apt-get update -qq > /dev/null
        apt_install docker-ce docker-ce-cli containerd.io

        sub "Creating docker group"
        if grep -q "^docker:" /etc/group; then
            echo "docker group exists"
        else
            sudo groupadd docker
            sudo usermod -aG docker "$(whoami)"
        fi
        # Why this line?
        sudo rm -rf ~/.docker
    fi

}
