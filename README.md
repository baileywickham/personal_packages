# Personal Packages
Soon to be dotfiles

## Use
The goal of this is to make my, and only my, life easier. What I mean by this is that I make assumptions about running Mint and wanting to install all the same packages as I do.

### Running
There should be as few dependencies as possible to the actual script, bash is all you need
```
apt install git
git clone https://github.com/baileywickham/personalPackages.git ~/workspace/personalPackages && \ 
./personal_packages.sh
``` 
To install the packages and move the dotfiles.

The -c flag is depricated now that all configs are sys links


### 'Features'
This installs my custom bashrc, vimrc, tmux.conf, 2fa files and all packages I want.
