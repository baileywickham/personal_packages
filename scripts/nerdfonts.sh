#!/bin/bash
# Incosada regualr
if [ -d "~/.builds/nerdfonts" ]; then
    echo "nerdfonts directory already exists"
else
    git clone https://github.com/ryanoasis/nerd-fonts.git ~/.builds/nerdfonts
    bash ~/.builds/nerdfonts/install.sh
fi
