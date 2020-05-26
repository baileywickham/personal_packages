# Personal Packages
My dotfiles and install scripts

![img](https://raw.githubusercontent.com/baileywickham/personal_packages/master/files/screencap.png)

## Use
Run `./personal_packages.sh -h` to see the options available.

### Running
There should be as few dependencies as possible to the actual script, bash and git are all you need
```
sudo apt install git
git clone https://github.com/baileywickham/personal_packages.git ~/workspace/personal_packages && \
cd ~/workspace/personal_packages && ./personal_packages.sh -a
```
To install the packages and move the dotfiles.

### 'Features'
This installs my custom keyboard, bashrc, vimrc, tmux.conf, 2fa files and all packages I want.

### Docker
Use:
```bash
./dock.sh
```
This repo includes a dockerfile and a script, ```dock.sh``` which runs the dockerfile. I am using docker as a test enviroment for making changes to the os, without breaking my configs.

## One liners
```curl https://raw.githubusercontent.com/baileywickham/personal_packages/master/files/keyboard > /etc/default/keyboard```
