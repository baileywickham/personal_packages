function install_docker() {
    task "Installing docker"

    apt_install apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    if command -v docker > /dev/null;
    then
        sub "Docker already installed";
    else
        sub "Adding keys"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | with_sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        if [[ "$(lsb_release -cs)" == "ulyssa" ]]; then
            local name="focal"
        else
            local name="$(lsb_release -cs)"
        fi
        echo  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            ${name} stable" | with_sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        with_sudo apt-get update -qq > /dev/null
        apt_install docker-ce docker-ce-cli containerd.io

        sub "Creating docker group"
        if grep -q "^docker:" /etc/group; then
            echo "docker group exists"
        else
            with_sudo groupadd docker
            with_sudo usermod -aG docker "$(whoami)"
        fi
    fi

}
